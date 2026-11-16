import '../entities/user_entity.dart';

/// Kontrak repository autentikasi.
///
/// Fase UAS: implementasi utama memakai Firebase Auth (email + password) dan
/// Firestore `users/{uid}`, dengan Hive CE sebagai cache profil offline.
/// Bila Firebase tidak tersedia (platform desktop atau bootstrap gagal),
/// repository otomatis memakai fallback lokal ala UTS agar aplikasi tetap
/// dapat dibuka — lihat `AuthRepositoryImpl`.
///
/// Method yang gagal melempar `Failure` berbahasa Indonesia:
/// - `InvalidCredentialsFailure` — email/password salah
/// - `UserNotFoundFailure`        — email belum terdaftar
/// - `EmailAlreadyInUseFailure`   — email sudah dipakai
/// - `WeakPasswordFailure`        — password terlalu lemah
/// - `NetworkFailure`             — tidak ada koneksi
abstract class IAuthRepository {
  /// Akun yang sedang login (`null` bila sesi kosong/tidak valid).
  ///
  /// Sumber kebenaran adalah sesi Firebase Auth; cache Hive hanya dipakai
  /// ketika profil cloud tidak dapat dihubungi.
  Future<UserEntity?> getCurrentUser();

  /// Perubahan sesi (login, logout, atau token tidak valid).
  ///
  /// Mode lokal mengembalikan stream kosong karena perubahan sesi selalu
  /// melewati use case yang diikuti `invalidateSelf`.
  Stream<UserEntity?> authStateChanges();

  /// Daftarkan akun baru (sekaligus membuat sesi login).
  ///
  /// `password` hanya diteruskan ke Firebase Auth dan **tidak pernah**
  /// disimpan di Hive/SharedPreferences.
  Future<UserEntity> register(UserEntity user, String password);

  /// Masuk memakai email + password.
  Future<UserEntity> login(String email, String password);

  /// Kirim tautan atur ulang password ke email terdaftar.
  Future<void> sendPasswordReset(String email);

  /// Perbarui profil akun.
  ///
  /// Profil disimpan lebih dulu ke cache lokal (agar tetap terbaca offline),
  /// lalu disinkronkan ke `users/{uid}` secara best-effort sampai antrean
  /// outbox Tahap 5 tersedia.
  Future<UserEntity> updateProfile(UserEntity user);

  /// Hapus sesi login (data domain tetap tersimpan).
  Future<void> logout();

  /// Status sesi & onboarding untuk routing awal (splash).
  Future<bool> isLoggedIn();

  Future<bool> hasSeenOnboarding();

  Future<void> markOnboardingSeen();
}
