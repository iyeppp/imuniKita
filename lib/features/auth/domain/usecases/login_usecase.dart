import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Hasil percobaan login.
enum LoginStatus {
  /// Akun ditemukan dan sesi dibuat.
  sukses,

  /// Belum ada akun sama sekali di perangkat ini.
  belumAdaAkun,

  /// Ada akun lain, tetapi email yang dimasukkan tidak terdaftar.
  emailTidakDitemukan,
}

class LoginResult {
  const LoginResult(this.status, [this.user]);

  final LoginStatus status;
  final UserEntity? user;

  bool get berhasil => status == LoginStatus.sukses;
}

/// Masuk memakai **email**.
///
/// Catatan fase UTS: autentikasi masih lokal dan mencocokkan email saja
/// (password belum diverifikasi karena belum ada hashing/penyimpanan aman).
/// Fase UAS: ganti isi use case ini dengan Firebase Auth — screen tidak berubah.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final IAuthRepository _repository;

  Future<LoginResult> execute(String email) async {
    if (!await _repository.hasAnyAccount()) {
      return const LoginResult(LoginStatus.belumAdaAkun);
    }

    final user = await _repository.findByEmail(email);
    if (user == null) {
      return const LoginResult(LoginStatus.emailTidakDitemukan);
    }

    // Simpan sesi untuk akun yang cocok.
    await _repository.startSession(user);

    return LoginResult(LoginStatus.sukses, user);
  }
}
