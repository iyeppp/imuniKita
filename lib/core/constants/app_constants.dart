/// Konstanta global aplikasi ImuniKita.
///
/// Kumpulan nilai tetap yang dipakai lintas fitur: nama box Hive CE, key
/// SharedPreferences, dan konfigurasi notifikasi H-7/H-1.
abstract class AppConstants {
  static const String appName = 'ImuniKita';

  // ── Nama Box Hive CE ──────────────────────────────────────────────────
  /// Box user — nama sudah dipakai sejak Sprint 1 (login/register), jangan diubah.
  static const String usersBox = 'userBox';
  static const String babiesBox = 'babyBox';
  static const String vaccineSchedulesBox = 'vaccineScheduleBox';
  static const String growthRecordsBox = 'growthRecordsBox';
  static const String healthJournalsBox = 'healthJournalsBox';
  static const String educationQuizScoresBox = 'educationQuizScoresBox';

  // ── Key SharedPreferences ─────────────────────────────────────────────
  /// Harus identik dengan key yang dipakai `LoginScreen`/`RegisterScreen`.
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';

  /// Penanda Onboarding sudah pernah dilewati/dituntaskan.
  static const String prefSeenOnboarding = 'seen_onboarding';

  /// ID bayi yang sedang dipilih — dipakai lintas screen sebagai "bayi aktif".
  static const String prefActiveBabyId = 'active_baby_id';

  /// Preferensi notifikasi pengingat (diatur di layar Profil & Pengaturan).
  static const String prefNotificationsEnabled = 'notifications_enabled';

  // ── Info Aplikasi ─────────────────────────────────────────────────────
  /// Versi aplikasi — disamakan manual dengan `version:` di `pubspec.yaml`
  /// karena `package_info_plus` belum dipakai pada fase UTS.
  static const String appVersion = '1.0.0+1';

  // ── Konfigurasi Notifikasi (H-7 & H-1) ────────────────────────────────
  static const int reminderH7DaysBefore = 7;
  static const int reminderH1DaysBefore = 1;

  /// Jam pengiriman notifikasi pengingat (waktu lokal perangkat).
  static const int reminderHour = 8;
}
