import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../env/env_config.dart';
import '../firebase/firebase_bootstrap.dart';
import 'local_storage_service.dart';
import 'notification_service.dart';

/// Kontrak layanan push (FCM) agar mudah diganti pada unit test.
///
/// Implementasi nyata adalah [PushService]. Use case hanya bergantung pada
/// [isPushActive] untuk deduplikasi (B9-4), sehingga test tidak perlu
/// menyentuh Firebase sama sekali.
abstract class IPushService {
  /// Inisialisasi minimal: minta izin, daftarkan token, dan pantau perubahan
  /// sesi/token. Aman dipanggil walau Firebase tidak aktif atau FCM dimatikan.
  Future<void> init();

  /// `true` bila pengiriman lewat FCM sedang aktif di perangkat ini.
  ///
  /// Saat `true`, pengingat lokal H-7/H-1 tidak perlu dijadwalkan karena
  /// server (GitHub Actions) yang mengirimkannya. Saat `false` (FCM tidak
  /// diaktifkan, izin ditolak, atau offline saat registrasi), pengingat lokal
  /// tetap berjalan sebagai fallback.
  Future<bool> isPushActive();

  /// Samakan status preferensi notifikasi dengan dokumen perangkat di
  /// Firestore (`users/{uid}/devices/{token}`).
  Future<void> syncNotificationsPreference(bool enabled);

  /// Hapus token perangkat sebelum sesi Firebase diakhiri.
  Future<void> onLogout();

  /// Lepas listener (dipakai saat pengujian/aplikasi dibongkar).
  Future<void> dispose();
}

/// Layanan token FCM opsional untuk pengingat H-7/H-1 lintas perangkat.
///
/// Fitur ini **opt-in** lewat `--dart-define=ENABLE_PUSH=true`. Default
/// nonaktif supaya jalur wajib (notifikasi lokal) tetap berjalan tanpa
/// ketergantungan server. Bila aktif:
///
/// 1. Minta izin notifikasi ke OS.
/// 2. Simpan token ke `users/{uid}/devices/{token}` (rules sudah owner-only).
/// 3. Perbarui token saat berubah dan hapus saat logout.
/// 4. Batalkan pengingat lokal agar tidak dobel dengan FCM (B9-4).
///
/// API key/service account FCM **tidak pernah** ada di APK; pengiriman
/// dilakukan GitHub Actions (lihat `.github/workflows/vaccine-reminder.yml`).
class PushService implements IPushService {
  PushService._();

  /// Singleton — disamakan dengan pola [NotificationService] yang statis.
  static final PushService instance = PushService._();

  static const String _devicesCollection = 'devices';

  bool _initialized = false;
  bool _active = false;
  String? _token;
  String? _lastSyncedToken;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;

  /// Platform yang didukung FCM native pada fase UAS.
  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String get _platformName =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  @override
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Jalur wajib (lokal) tidak boleh bergantung pada FCM. Bila fitur tidak
    // diminta secara eksplisit, seluruh langkah di bawah dilewati.
    if (!EnvConfig.pushEnabled) {
      debugPrint(
        'PushService: ENABLE_PUSH tidak aktif — memakai notifikasi lokal.',
      );
      return;
    }

    if (!FirebaseBootstrap.isInitialized || !_isSupportedPlatform) {
      debugPrint(
        'PushService: Firebase/platform tidak mendukung FCM — dilewati.',
      );
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!_isAuthorized(settings.authorizationStatus)) {
        debugPrint('PushService: izin notifikasi ditolak — memakai lokal.');
        _active = false;
        await LocalStorageService.setPushRegistered(false);
        return;
      }

      // firebase_messaging 17 menandai `onTokenRefresh`/`getToken` deprecated
      // dan mengarahkan ke API FID (`register`/`onRegistered`). Server kita
      // (FCM HTTP v1 multicast) masih memakai registration token, jadi API
      // lama dipertahankan sampai migrasi target pengiriman selesai.
      // ignore: deprecated_member_use
      _tokenSubscription = messaging.onTokenRefresh.listen((token) {
        _token = token;
        unawaited(_registerForCurrentUser());
      });

      _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
        user,
      ) {
        if (user == null) {
          unawaited(_clearActive());
        } else {
          unawaited(_registerForCurrentUser());
        }
      });

      if (FirebaseAuth.instance.currentUser != null) {
        await _registerForCurrentUser();
      }
    } catch (error) {
      // Non-fatal: FCM opsional. Fallback lokal tetap berjalan.
      debugPrint('PushService: inisialisasi FCM gagal — $error');
      _active = false;
      await LocalStorageService.setPushRegistered(false);
    }
  }

  @override
  Future<bool> isPushActive() async {
    if (!EnvConfig.pushEnabled) return false;
    if (_active) return true;
    _active = await LocalStorageService.isPushRegistered();
    return _active;
  }

  @override
  Future<void> syncNotificationsPreference(bool enabled) async {
    if (!EnvConfig.pushEnabled ||
        !FirebaseBootstrap.isInitialized ||
        !_isSupportedPlatform) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (!enabled) {
        await _deleteDeviceDoc(user.uid);
        await _clearActive();
        return;
      }

      await _registerForCurrentUser();
    } catch (error) {
      debugPrint('PushService: gagal menyinkronkan preferensi — $error');
    }
  }

  @override
  Future<void> onLogout() async {
    if (!FirebaseBootstrap.isInitialized || !_isSupportedPlatform) {
      await _clearActive();
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await _deleteDeviceDoc(uid);
      } catch (error) {
        debugPrint('PushService: gagal menghapus token saat logout — $error');
      }
    }

    await _clearActive();
  }

  @override
  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _authSubscription = null;
    _tokenSubscription = null;
    _initialized = false;
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static bool _isAuthorized(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  Future<void> _registerForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final notificationsEnabled =
        await LocalStorageService.isNotificationEnabled();
    if (!notificationsEnabled) {
      // Preferensi perangkat mematikan pengingat: hapus token agar server
      // tidak mengirim push ke perangkat ini.
      await _deleteDeviceDoc(user.uid);
      await _clearActive();
      return;
    }

    // ignore: deprecated_member_use
    final token = _token ?? await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    // Token lama bisa basi setelah `onTokenRefresh`; pastikan tidak ada dua
    // dokumen perangkat untuk perangkat yang sama.
    if (_lastSyncedToken != null && _lastSyncedToken != token) {
      try {
        await _deviceDoc(user.uid, _lastSyncedToken!).delete();
      } catch (_) {
        // Abaikan: token lama akan kedaluwarsa sendiri di sisi FCM.
      }
    }

    await _deviceDoc(user.uid, token).set({
      'platform': _platformName,
      'notificationsEnabled': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _token = token;
    _lastSyncedToken = token;
    _active = true;
    await LocalStorageService.setPushRegistered(true);

    // B9-4: FCM kini menjadi kanal pengiriman. Hentikan pengingat lokal yang
    // mungkin sudah terjadwal agar user tidak menerima notifikasi ganda.
    try {
      await NotificationService.cancelAllNotifications();
    } catch (_) {
      // Non-fatal: pembatalan lokal hanya relevan bila FCM aktif.
    }
  }

  Future<void> _deleteDeviceDoc(String uid) async {
    final token = _token ?? _lastSyncedToken;
    if (token == null || token.isEmpty) return;
    await _deviceDoc(uid, token).delete();
  }

  DocumentReference<Map<String, dynamic>> _deviceDoc(
    String uid,
    String token,
  ) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection(_devicesCollection)
      .doc(token);

  Future<void> _clearActive() async {
    _active = false;
    _token = null;
    _lastSyncedToken = null;
    await LocalStorageService.setPushRegistered(false);
  }
}
