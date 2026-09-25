import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_storage_service.dart';
import '../models/user_model.dart';

/// Sumber data lokal autentikasi: akun di Hive CE (`userBox`) + sesi di
/// `SharedPreferences` (lewat [LocalStorageService]).
class AuthLocalDatasource {
  const AuthLocalDatasource();

  Future<Box<UserModel>> _userBox() =>
      Hive.openBox<UserModel>(AppConstants.usersBox);

  Future<List<UserModel>> getAllUsers() async {
    final box = await _userBox();
    return box.values.toList();
  }

  Future<UserModel?> getById(String localId) async {
    final box = await _userBox();
    return box.get(localId);
  }

  Future<UserModel?> getByEmail(String email) async {
    final box = await _userBox();
    final target = email.trim().toLowerCase();
    for (final user in box.values) {
      if (user.email.trim().toLowerCase() == target) return user;
    }
    return null;
  }

  Future<UserModel> put(UserModel model) async {
    final box = await _userBox();
    await box.put(model.localId, model);
    return model;
  }

  // ── Sesi (SharedPreferences) ─────────────────────────────────────────────

  Future<void> saveSession(UserModel user) async {
    final prefs = await LocalStorageService.instance;
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setString(AppConstants.prefUserId, user.localId);
    await prefs.setString(AppConstants.prefUserName, user.namaLengkap);
  }

  Future<void> clearSession() => LocalStorageService.clearSession();

  Future<bool> isLoggedIn() => LocalStorageService.isLoggedIn();

  Future<String?> currentUserId() => LocalStorageService.getCurrentUserId();

  Future<void> setCurrentUserName(String nama) =>
      LocalStorageService.setCurrentUserName(nama);

  Future<bool> hasSeenOnboarding() async {
    final prefs = await LocalStorageService.instance;
    return prefs.getBool(AppConstants.prefSeenOnboarding) ?? false;
  }

  Future<void> setSeenOnboarding(bool value) async {
    final prefs = await LocalStorageService.instance;
    await prefs.setBool(AppConstants.prefSeenOnboarding, value);
  }
}
