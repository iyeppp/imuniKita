import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Perbarui profil akun (menolak email duplikat milik akun lain).
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final IAuthRepository _repository;

  Future<UserEntity> execute(UserEntity user) =>
      _repository.updateProfile(user);
}
