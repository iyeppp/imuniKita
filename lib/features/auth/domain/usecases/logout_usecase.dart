import '../repositories/i_auth_repository.dart';

/// Hapus sesi login (data domain tetap tersimpan).
///
/// Pembatalan notifikasi yang sudah terjadwal dilakukan di lapisan
/// presentasi setelah use case ini berhasil, agar domain tetap bebas dari
/// dependency plugin notifikasi.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<void> execute() => _repository.logout();
}
