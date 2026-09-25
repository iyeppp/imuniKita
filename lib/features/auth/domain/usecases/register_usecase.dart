import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Daftarkan akun baru (sekaligus membuat sesi login).
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final IAuthRepository _repository;

  Future<UserEntity> execute(UserEntity user) => _repository.register(user);
}
