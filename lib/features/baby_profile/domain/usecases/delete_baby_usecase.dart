import '../repositories/i_baby_repository.dart';

/// Hapus profil bayi berdasarkan [babyId].
///
/// Hanya menghapus **profilnya**; pembersihan data turunan (jadwal imunisasi,
/// rekam pertumbuhan, jurnal kesehatan) diorkestrasi lapisan presentation
/// karena setiap fitur memiliki box/provider sendiri — lihat `BabyDetailScreen`.
/// Bila nanti dipindahkan ke domain, buat `BabyDataService` yang menyatukan
/// keempat repository.
class DeleteBabyUseCase {
  const DeleteBabyUseCase(this._repository);

  final IBabyRepository _repository;

  Future<void> execute(String babyId) => _repository.deleteBaby(babyId);
}
