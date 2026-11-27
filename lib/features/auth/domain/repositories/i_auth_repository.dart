import '../entities/user_entity.dart';

/// Kontrak repository autentikasi.
abstract class IAuthRepository {
  /// Akun yang sedang login (`null` bila sesi kosong/tidak valid).
  Future<UserEntity?> getCurrentUser();

  /// Perubahan sesi (login, logout, atau token tidak valid).
  Stream<UserEntity?> authStateChanges();

  /// Daftarkan akun baru (sekaligus membuat sesi login).
  Future<UserEntity> register(UserEntity user, String password);

  /// Masuk memakai email + password.
  Future<UserEntity> login(String email, String password);

  /// Kirim tautan atur ulang password ke email terdaftar.
  Future<void> sendPasswordReset(String email);

  /// Perbarui profil akun.
  Future<UserEntity> updateProfile(UserEntity user);

  /// Hapus sesi login (data domain tetap tersimpan).
  Future<void> logout();

  /// Status sesi & onboarding untuk routing awal (splash).
  Future<bool> isLoggedIn();

  Future<bool> hasSeenOnboarding();

  Future<void> markOnboardingSeen();
}
