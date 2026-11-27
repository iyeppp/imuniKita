/// Konstanta global aplikasi ImuniKita.
abstract class AppConstants {
  static const String appName = 'ImuniKita';

  // ── Nama Box Hive CE ──────────────────────────────────────────────────
  /// Box user — nama sudah dipakai (login/register), jangan diubah.
  static const String usersBox = 'userBox';
  static const String babiesBox = 'babyBox';
  static const String vaccineSchedulesBox = 'vaccineScheduleBox';
  static const String growthRecordsBox = 'growthRecordsBox';
  static const String healthJournalsBox = 'healthJournalsBox';
  static const String educationQuizScoresBox = 'educationQuizScoresBox';
  static const String syncOutboxBox = 'syncOutboxBox';
  static const String apiCacheBox = 'apiCacheBox';

  // ── Key SharedPreferences ─────────────────────────────────────────────
  /// Cermin sesi untuk fitur non-auth.
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';

  /// Penanda Onboarding sudah pernah dilewati/dituntaskan.
  static const String prefSeenOnboarding = 'seen_onboarding';

  /// ID bayi yang sedang dipilih — dipakai lintas screen sebagai "bayi aktif".
  static const String prefActiveBabyId = 'active_baby_id';

  /// Preferensi notifikasi pengingat (diatur di layar Profil & Pengaturan).
  static const String prefNotificationsEnabled = 'notifications_enabled';

  /// Preferensi tema aplikasi ('system', 'light', 'dark').
  static const String prefThemeMode = 'theme_mode';

  /// Penanda token FCM perangkat sudah terdaftar.
  static const String prefPushRegistered = 'push_registered';

  // ── Info Aplikasi ─────────────────────────────────────────────────────
  static const String appVersion = '1.0.0+1';

  // ── Konfigurasi Notifikasi (H-7 & H-1) ────────────────────────────────
  static const int reminderH7DaysBefore = 7;
  static const int reminderH1DaysBefore = 1;

  /// Jam pengiriman notifikasi pengingat (waktu lokal perangkat).
  static const int reminderHour = 8;
}
