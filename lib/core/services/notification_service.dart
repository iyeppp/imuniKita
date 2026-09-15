import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service terpusat untuk semua operasi notifikasi lokal.
/// Gunakan [NotificationService.init] sekali di main(), lalu panggil
/// [scheduleNotification] dari use case imunisasi.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel ID untuk Android — harus konsisten agar notifikasi tidak duplikat
  static const _channelId   = 'imunikita_reminders';
  static const _channelName = 'Pengingat Imunisasi';
  static const _channelDesc =
      'Notifikasi pengingat jadwal imunisasi H-7 dan H-1';

  /// Inisialisasi plugin. Dipanggil sekali di [main].
  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Minta permission notifikasi (Android 13+ / API 33+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Callback saat user mengetuk notifikasi.
  /// TODO(Sprint 2): navigasi ke VaccineDetailScreen via GoRouter.
  static void _onNotificationTap(NotificationResponse response) {
    // payload berisi vaccineScheduleId
  }

  /// Jadwalkan notifikasi pada [scheduledDate].
  ///
  /// [id]            : ID unik notifikasi (gunakan hash dari vaccineScheduleId)
  /// [title]         : Judul notifikasi
  /// [body]          : Isi pesan notifikasi
  /// [scheduledDate] : Waktu pengiriman (UTC)
  /// [payload]       : Data tambahan (opsional, misal vaccineScheduleId)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Batalkan notifikasi berdasarkan [id].
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Batalkan semua notifikasi yang terjadwal.
  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Daftar semua notifikasi yang masih pending (untuk debugging).
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }
}
