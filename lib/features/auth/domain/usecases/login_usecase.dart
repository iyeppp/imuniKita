import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Hasil percobaan login.
enum LoginStatus {
  /// Akun ditemukan dan sesi dibuat.
  sukses,

  /// Belum ada akun sama sekali di perangkat ini (mode lokal tanpa Firebase).
  belumAdaAkun,

  /// Email yang dimasukkan tidak terdaftar.
  emailTidakDitemukan,

  /// Email terdaftar, tetapi password tidak cocok.
  sandiSalah,
}

class LoginResult {
  const LoginResult(this.status, [this.user]);

  final LoginStatus status;
  final UserEntity? user;

  bool get berhasil => status == LoginStatus.sukses;
}

/// Masuk memakai **email + password**.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<LoginResult> execute(String email, String password) async {
    try {
      final user = await _repository.login(email, password);
      return LoginResult(LoginStatus.sukses, user);
    } on NoAccountFailure {
      return const LoginResult(LoginStatus.belumAdaAkun);
    } on UserNotFoundFailure {
      return const LoginResult(LoginStatus.emailTidakDitemukan);
    } on InvalidCredentialsFailure {
      return const LoginResult(LoginStatus.sandiSalah);
    }
  }
}
