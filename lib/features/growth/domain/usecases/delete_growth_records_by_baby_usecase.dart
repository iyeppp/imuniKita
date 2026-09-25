import '../repositories/i_growth_repository.dart';

/// Hapus seluruh rekam pertumbuhan satu bayi (cascade delete profil bayi).
class DeleteGrowthRecordsByBabyUseCase {
  const DeleteGrowthRecordsByBabyUseCase(this._repository);

  final IGrowthRepository _repository;

  Future<void> execute(String babyId) =>
      _repository.deleteRecordsByBaby(babyId);
}
