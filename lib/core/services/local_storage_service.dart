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
}
