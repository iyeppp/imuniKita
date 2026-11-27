import '../repositories/i_auth_repository.dart';

/// Hapus sesi login (data domain tetap tersimpan).
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> execute() => _repository.logout();
}
