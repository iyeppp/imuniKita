/// Konstanta global aplikasi ImuniKita.
///
/// Kumpulan nilai tetap yang dipakai lintas fitur: nama box Hive CE, key
/// SharedPreferences, dan konfigurasi notifikasi H-7/H-1.
abstract class AppConstants {
  static const String appName = 'ImuniKita';

  /// Feature flag fase pengembangan.
  ///
  /// - `false` → **Fase UTS**: data dibaca dari Hive CE / mock lokal.
  /// - `true`  → **Fase UAS**: repository beralih ke Firestore / backend.
  static const bool isUASPhase = false;

  // ── Nama Box Hive CE ──────────────────────────────────────────────────
  /// Box user — nama sudah dipakai sejak Sprint 1 (login/register), jangan diubah.
  static const String usersBox = 'userBox';
  static const String babiesBox = 'babyBox';
  static const String vaccineSchedulesBox = 'vaccineScheduleBox';

  // ── Key SharedPreferences ─────────────────────────────────────────────
  /// Harus identik dengan key yang dipakai `LoginScreen`/`RegisterScreen`.
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';

  // ── Konfigurasi Notifikasi (H-7 & H-1) ────────────────────────────────
  static const int reminderH7DaysBefore = 7;
  static const int reminderH1DaysBefore = 1;

  /// Jam pengiriman notifikasi pengingat (waktu lokal perangkat).
  static const int reminderHour = 8;
}
