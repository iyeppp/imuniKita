import '../repositories/i_auth_repository.dart';

/// Kirim email atur ulang password lewat Firebase Auth.
class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> execute(String email) => _repository.sendPasswordReset(email);
}
