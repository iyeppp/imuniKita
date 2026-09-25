import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

/// Ambil akun yang sedang login (`null` bila belum ada sesi).
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final IAuthRepository _repository;

  Future<UserEntity?> execute() => _repository.getCurrentUser();
}
