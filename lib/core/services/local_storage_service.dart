import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Wrapper tipis untuk `SharedPreferences`.
///
/// Hanya menyimpan data **sesi** (status login, user aktif) — bukan data
/// domain (itu tugas Hive CE). Key yang dipakai identik dengan yang sudah
/// ditulis langsung oleh `LoginScreen`/`RegisterScreen`, sehingga service ini
/// bisa membaca sesi yang sama tanpa migrasi data.
class LocalStorageService {
  LocalStorageService._();

  static SharedPreferences? _prefs;

  /// Ambil instance (di-cache) — aman dipanggil berkali-kali.
  static Future<SharedPreferences> get instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool> isLoggedIn() async =>
      (await instance).getBool(AppConstants.prefIsLoggedIn) ?? false;

  static Future<String?> getCurrentUserId() async =>
      (await instance).getString(AppConstants.prefUserId);

  static Future<String?> getCurrentUserName() async =>
      (await instance).getString(AppConstants.prefUserName);

  static Future<void> setCurrentUserName(String nama) async =>
      (await instance).setString(AppConstants.prefUserName, nama);

  /// ID bayi yang sedang dipilih (bayi aktif).
  static Future<String?> getActiveBabyId() async =>
      (await instance).getString(AppConstants.prefActiveBabyId);

  static Future<void> setActiveBabyId(String babyId) async =>
      (await instance).setString(AppConstants.prefActiveBabyId, babyId);

  static Future<void> clearActiveBabyId() async =>
      (await instance).remove(AppConstants.prefActiveBabyId);

  /// Hapus data sesi login (dipakai tombol "Keluar" di layar Profil).
  ///
  /// Key `seen_onboarding` sengaja **tidak** dihapus agar user yang logout
  /// langsung diarahkan ke Login, bukan mengulang Onboarding. Data domain
  /// (Hive CE) juga tetap tersimpan.
  ///
  /// Fix Bug #41: `active_baby_id` ikut dibersihkan — sebelumnya pilihan bayi
  /// aktif milik akun sebelumnya terbawa ke akun berikutnya di perangkat yang
  /// sama (preferensi antar-akun bocor).
  static Future<void> clearSession() async {
    final prefs = await instance;
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserName);
    await prefs.remove(AppConstants.prefActiveBabyId);
  }

  /// Preferensi notifikasi pengingat H-7 & H-1 — default **aktif**.
  ///
  /// Temuan #19: key disimpan **per pengguna** (`notifications_enabled_<userId>`)
  /// agar preferensi satu akun tidak terbawa ke akun lain di perangkat yang
  /// sama. Bila belum ada sesi login, dipakai key dasar sebagai fallback.
  static Future<String> _notificationPrefKey() async {
    final userId = await getCurrentUserId();
    return userId == null
        ? AppConstants.prefNotificationsEnabled
        : '${AppConstants.prefNotificationsEnabled}_$userId';
  }

  static Future<bool> isNotificationEnabled() async =>
      (await instance).getBool(await _notificationPrefKey()) ?? true;

  static Future<void> setNotificationEnabled(bool enabled) async =>
      (await instance).setBool(await _notificationPrefKey(), enabled);
}
