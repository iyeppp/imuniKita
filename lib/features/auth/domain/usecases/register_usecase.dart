import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Daftarkan akun baru (sekaligus membuat sesi login).
///
/// `password` diteruskan ke Firebase Auth dan tidak disimpan di perangkat.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final IAuthRepository _repository;

  Future<UserEntity> execute(UserEntity user, String password) =>
      _repository.register(user, password);
}
