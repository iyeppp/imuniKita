import '../entities/growth_record_entity.dart';
import '../repositories/i_growth_repository.dart';

/// Ambil seluruh rekam pertumbuhan milik satu bayi (terurut lama → baru).
class GetGrowthRecordsUseCase {
  const GetGrowthRecordsUseCase(this._repository);

  final IGrowthRepository _repository;

  Future<List<GrowthRecordEntity>> execute(String babyId) =>
      _repository.getRecordsByBaby(babyId);
}
