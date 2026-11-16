import '../repositories/i_auth_repository.dart';

/// Kirim email atur ulang password lewat Firebase Auth.
///
/// Tidak mengembalikan apa pun (Firebase tidak membocorkan apakah email
/// terdaftar atau tidak) — pesan sukses di UI bersifat netral.
class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> execute(String email) => _repository.sendPasswordReset(email);
}
