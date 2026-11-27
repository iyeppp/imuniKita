import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Wrapper tipis untuk `SharedPreferences`.
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
  static Future<void> clearSession() async {
    final prefs = await instance;
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserName);
    await prefs.remove(AppConstants.prefActiveBabyId);
  }

  /// Preferensi notifikasi pengingat H-7 & H-1 — default **aktif**.
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

  /// Penanda token FCM perangkat sudah terdaftar.
  static Future<bool> isPushRegistered() async =>
      (await instance).getBool(AppConstants.prefPushRegistered) ?? false;

  static Future<void> setPushRegistered(bool registered) async =>
      (await instance).setBool(AppConstants.prefPushRegistered, registered);

  /// Preferensi tema aplikasi (system, light, dark).
  static Future<ThemeMode> getThemeMode() async {
    final modeStr = (await instance).getString(AppConstants.prefThemeMode);
    switch (modeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await (await instance).setString(AppConstants.prefThemeMode, modeStr);
  }

  static String _migrationKey(String uid) => 'migration_done_$uid';

  static Future<bool> isMigrationDone(String uid) async {
    if (uid.isEmpty) return false;
    return (await instance).getBool(_migrationKey(uid)) ?? false;
  }

  static Future<void> markMigrationDone(String uid) async {
    if (uid.isEmpty) return;
    await (await instance).setBool(_migrationKey(uid), true);
  }
}
