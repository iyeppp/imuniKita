import '../entities/growth_record_entity.dart';
import '../repositories/i_growth_repository.dart';

/// Simpan satu rekam pengukuran pertumbuhan.
class AddGrowthRecordUseCase {
  const AddGrowthRecordUseCase(this._repository);

  final IGrowthRepository _repository;

  Future<GrowthRecordEntity> execute(GrowthRecordEntity record) =>
      _repository.addRecord(record);
}
