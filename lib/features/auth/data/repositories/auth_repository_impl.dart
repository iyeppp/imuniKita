import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Implementasi `IAuthRepository` fase UTS — Hive CE untuk akun dan
/// SharedPreferences untuk sesi.
///
/// Menerjemahkan `UserModel` (data) ↔ `UserEntity` (domain) dan membungkus
/// error penyimpanan menjadi `Failure` yang siap ditampilkan.
class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._localDatasource);

  final AuthLocalDatasource _localDatasource;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userId = await _localDatasource.currentUserId();
      if (userId == null) return null;

      final model = await _localDatasource.getById(userId);
      return model?.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat data akun.');
    }
  }

  @override
  Future<bool> hasAnyAccount() async {
    try {
      final semua = await _localDatasource.getAllUsers();
      return semua.isNotEmpty;
    } catch (_) {
      throw const LocalStorageFailure('Gagal memeriksa data akun.');
    }
  }

  @override
  Future<UserEntity?> findByEmail(String email) async {
    try {
      final model = await _localDatasource.getByEmail(email);
      return model?.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal mencari akun.');
    }
  }

  @override
  Future<UserEntity> register(UserEntity user) async {
    try {
      final bersih = user.copyWith(email: user.email.trim().toLowerCase());
      final saved = await _localDatasource.put(UserModel.fromEntity(bersih));
      await _localDatasource.saveSession(saved);
      return saved.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan akun baru.');
    }
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    try {
      final email = user.email.trim().toLowerCase();
      final semua = await _localDatasource.getAllUsers();

      // Login mencocokkan akun berdasarkan email, jadi duplikat membuat login
      // ambigu — tolak di sini (aturan bisnis, bukan aturan UI).
      final bentrok = semua.any(
        (u) =>
            u.localId != user.localId && u.email.trim().toLowerCase() == email,
      );
      if (bentrok) {
        throw const ValidationFailure(
          'Email tersebut sudah dipakai akun lain di perangkat ini.',
        );
      }

      final saved = await _localDatasource.put(
        UserModel.fromEntity(user.copyWith(email: email)),
      );
      // Agar sapaan/sesi di layar lain ikut memakai nama terbaru.
      await _localDatasource.setCurrentUserName(saved.namaLengkap);
      return saved.toEntity();
    } on Failure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui profil akun.');
    }
  }

  @override
  Future<void> startSession(UserEntity user) async {
    try {
      await _localDatasource.saveSession(UserModel.fromEntity(user));
    } catch (_) {
      throw const LocalStorageFailure('Gagal membuat sesi login.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _localDatasource.clearSession();
    } catch (_) {
      throw const LocalStorageFailure('Gagal mengakhiri sesi.');
    }
  }

  @override
  Future<bool> isLoggedIn() => _localDatasource.isLoggedIn();

  @override
  Future<bool> hasSeenOnboarding() => _localDatasource.hasSeenOnboarding();

  @override
  Future<void> markOnboardingSeen() => _localDatasource.setSeenOnboarding(true);
}
