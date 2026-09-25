import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service terpusat untuk semua operasi notifikasi lokal.
/// Gunakan [NotificationService.init] sekali di main(), lalu panggil
/// [scheduleNotification] dari use case imunisasi.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel ID untuk Android -- harus konsisten agar notifikasi tidak duplikat
  static const _channelId = 'imunikita_reminders';
  static const _channelName = 'Pengingat Imunisasi';
  static const _channelDesc =
      'Notifikasi pengingat jadwal imunisasi H-7 dan H-1';

  /// GoRouter instance -- di-set dari [app.dart] setelah router dibuat.
  /// Dipakai oleh [_onNotificationTap] untuk navigasi ke VaccineDetailScreen
  /// (Fix Bug #6). Tidak di-set lewat constructor agar tetap kompatibel
  /// dengan static pattern yang sudah ada.
  static GoRouter? _router;

  /// Payload jadwal yang menunggu router siap.
  ///
  /// Bila app dibuka dari notifikasi (kondisi terminated), payload sudah
  /// tersedia di [init] padahal router baru dibuat setelah `runApp`. Payload
  /// disimpan sementara di sini lalu dinavigasikan begitu [setRouter] dipanggil.
  static String? _pendingScheduleId;

  /// `true` bila OS menolak alarm presisi (mis. Android 12+ tanpa izin
  /// `SCHEDULE_EXACT_ALARM`). Penjadwalan berikutnya langsung memakai mode
  /// inexact agar pengingat tetap terjadwal meski jamnya tidak presisi.
  static bool _pakaiInexact = false;

  /// Daftarkan router untuk navigasi dari notifikasi tap.
  static void setRouter(GoRouter router) {
    _router = router;

    final tertunda = _pendingScheduleId;
    if (tertunda != null) {
      _pendingScheduleId = null;
      _navigate(tertunda);
    }
  }

  /// Inisialisasi plugin. Dipanggil sekali di [main].
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_imunikita',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Minta permission notifikasi (Android 13+ / API 33+)
    await android?.requestNotificationsPermission();

    // Fix Bug #29: catat apakah alarm presisi diizinkan. Bila tidak, pengingat
    // tetap didaftarkan dengan mode inexact (perkiraan) alih-alih gagal senyap.
    try {
      _pakaiInexact = !(await android?.canScheduleExactNotifications() ?? true);
    } catch (_) {
      _pakaiInexact = false;
    }

    // Fix Bug #29: tangani app yang dibuka dari ketukan notifikasi saat
    // terminated (router belum ada, jadi payload disimpan dulu).
    try {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        final payload = launch?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          _pendingScheduleId = payload;
        }
      }
    } catch (_) {
      // Non-fatal: hanya memengaruhi navigasi otomatis dari notifikasi.
    }
  }

  /// Callback saat user mengetuk notifikasi.
  /// Fix Bug #6: navigasi ke VaccineDetailScreen menggunakan payload (scheduleId).
  static void _onNotificationTap(NotificationResponse response) {
    final scheduleId = response.payload;
    if (scheduleId == null || scheduleId.isEmpty) return;

    // Router belum siap (mis. notif diterima sebelum app init) → simpan dulu.
    if (_router == null) {
      _pendingScheduleId = scheduleId;
      return;
    }
    _navigate(scheduleId);
  }

  static void _navigate(String scheduleId) {
    try {
      _router?.go('/calendar/detail/$scheduleId');
    } catch (_) {
      // Abaikan jika navigasi gagal
    }
  }

  /// Jadwalkan notifikasi pada [scheduledDate].
  ///
  /// [id]            : ID unik notifikasi (gunakan hash dari vaccineScheduleId)
  /// [title]         : Judul notifikasi
  /// [body]          : Isi pesan notifikasi
  /// [scheduledDate] : Waktu pengiriman
  /// [payload]       : Data tambahan (opsional, misal vaccineScheduleId)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    Future<void> jadwalkan(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          // Temuan #50: ikon status bar monokrom (bukan ikon aplikasi).
          icon: '@drawable/ic_stat_imunikita',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: mode,
      payload: payload,
    );

    // Fix Bug #29: alarm presisi butuh izin khusus. Bila ditolak, jangan
    // menyerah — pakai alarm inexact agar pengingat tetap terkirim (jamnya
    // bisa bergeser sedikit), lalu ingat untuk penjadwalan berikutnya.
    if (_pakaiInexact) {
      await jadwalkan(AndroidScheduleMode.inexactAllowWhileIdle);
      return;
    }

    try {
      await jadwalkan(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException catch (e) {
      if (!e.code.contains('exact_alarms_not_permitted')) rethrow;
      _pakaiInexact = true;
      debugPrint(
        'NotificationService: exact alarm tidak diizinkan, memakai inexact.',
      );
      await jadwalkan(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  /// Batalkan notifikasi berdasarkan [id].
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Batalkan semua notifikasi yang terjadwal.
  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Reset status fallback alarm presisi (khusus test).
  ///
  /// `_pakaiInexact` adalah state statis yang berubah saat OS menolak exact
  /// alarm; tanpa reset, hasil satu test bisa memengaruhi test berikutnya.
  @visibleForTesting
  static void resetScheduleModeForTest() {
    _pakaiInexact = false;
    _pendingScheduleId = null;
    _router = null;
  }
}
