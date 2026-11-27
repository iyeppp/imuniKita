import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/push_service.dart';
import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

// ── Profil user yang sedang login ────────────────────────────────────────

/// Akun yang sedang login, dibaca lewat repository auth (bukan Hive langsung).
class CurrentUserNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final repository = ref.read(authRepositoryProvider);
    final currentUser = await ref.read(getCurrentUserUseCaseProvider).execute();

    // Langganan dipasang setelah pembacaan awal agar state tidak di-set sebelum build selesai.
    var disposed = false;
    final subscription = repository.authStateChanges().listen((user) {
      if (disposed) return;
      state = AsyncData(user);
    });
    ref.onDispose(() {
      disposed = true;
      subscription.cancel();
    });

    return currentUser;
  }

  /// Masuk memakai email + password.
  Future<LoginResult> login(String email, String password) async {
    final hasil = await ref.read(loginUseCaseProvider).execute(email, password);
    if (hasil.berhasil) ref.invalidateSelf();
    return hasil;
  }

  /// Daftarkan akun baru (sekaligus membuat sesi).
  Future<UserEntity> register(UserEntity user, String password) async {
    final saved = await ref
        .read(registerUseCaseProvider)
        .execute(user, password);
    ref.invalidateSelf();
    return saved;
  }

  /// Kirim tautan atur ulang password ke email terdaftar.
  Future<void> sendPasswordReset(String email) =>
      ref.read(sendPasswordResetUseCaseProvider).execute(email);

  /// Simpan perubahan profil dari layar Profil & Pengaturan.
  Future<void> updateProfile(UserEntity updated) async {
    await ref.read(updateProfileUseCaseProvider).execute(updated);
    ref.invalidateSelf();
  }

  /// Keluar dari akun — hanya menghapus sesi; data bayi, jadwal imunisasi, pertumbuhan, dan jurnal **tetap tersimpan** di perangkat.
  Future<void> logout() async {
    // Hapus token FCM perangkat ini sebelum sesi Firebase berakhir.
    try {
      await PushService.instance.onLogout();
    } catch (_) {
      // Diabaikan dengan sengaja.
    }

    await ref.read(logoutUseCaseProvider).execute();

    try {
      await NotificationService.cancelAllNotifications();
    } catch (_) {
      // Non-fatal: plugin notifikasi bisa gagal (mis. izin/kanal belum siap), tetapi logout tetap harus berhasil.
    }

    ref.invalidateSelf();
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, UserEntity?>(
      CurrentUserNotifier.new,
    );

// ── Preferensi notifikasi pengingat ──────────────────────────────────────

/// Status notifikasi pengingat H-7 & H-1 (default aktif).
class NotificationPrefNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => LocalStorageService.isNotificationEnabled();

  Future<void> setEnabled(bool enabled) async {
    await LocalStorageService.setNotificationEnabled(enabled);

    // Samakan status di dokumen perangkat FCM agar server tidak mengirim push saat pengingat dimatikan.
    try {
      await PushService.instance.syncNotificationsPreference(enabled);
    } catch (_) {
      // Non-fatal: preferensi lokal sudah tersimpan.
    }

    // Saat dimatikan, batalkan semua pengingat yang sudah terjadwal agar tidak ada notifikasi "nyasar" setelah user memilih nonaktif.
    if (!enabled) {
      try {
        await NotificationService.cancelAllNotifications();
      } catch (_) {
        // Diabaikan dengan sengaja.
      }
    }

    ref.invalidateSelf();
  }
}

final notificationEnabledProvider =
    AsyncNotifierProvider<NotificationPrefNotifier, bool>(
      NotificationPrefNotifier.new,
    );
