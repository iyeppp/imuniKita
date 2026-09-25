import '../entities/user_entity.dart';

/// Kontrak repository autentikasi.
///
/// Fase UTS diimplementasikan di atas Hive CE + SharedPreferences; fase UAS
/// akan menambah `auth_remote_datasource.dart` (Firebase Auth) di belakang
/// kontrak yang sama tanpa mengubah provider/screen (dev plan §6.1).
abstract class IAuthRepository {
  /// Akun yang sedang login (`null` bila sesi kosong/tidak valid).
  Future<UserEntity?> getCurrentUser();

  /// Apakah perangkat ini sudah punya akun terdaftar (dipakai LoginScreen
  /// untuk mengarahkan ke Register saat belum ada akun).
  Future<bool> hasAnyAccount();

  /// Cari akun berdasarkan email (case-insensitive) — `null` bila tidak cocok.
  Future<UserEntity?> findByEmail(String email);

  /// Simpan akun baru **dan** buat sesi login.
  Future<UserEntity> register(UserEntity user);

  /// Buat sesi login untuk akun yang sudah ada (dipakai `LoginUseCase`).
  Future<void> startSession(UserEntity user);

  /// Perbarui profil akun (menolak email duplikat milik akun lain).
  Future<UserEntity> updateProfile(UserEntity user);

  /// Hapus sesi login (data domain tetap tersimpan).
  Future<void> logout();

  /// Status sesi & onboarding untuk routing awal (splash).
  Future<bool> isLoggedIn();

  Future<bool> hasSeenOnboarding();

  Future<void> markOnboardingSeen();
}
