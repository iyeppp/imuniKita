import '../../../../core/errors/failures.dart';
import '../../domain/entities/growth_record_entity.dart';
import '../../domain/repositories/i_growth_repository.dart';
import '../datasources/growth_local_datasource.dart';
import '../models/growth_record_model.dart';

/// Implementasi `IGrowthRepository` fase UTS — sepenuhnya di atas Hive CE.
///
/// Menerjemahkan `GrowthRecordModel` (data) ↔ `GrowthRecordEntity` (domain)
/// dan membungkus error Hive menjadi `Failure` yang siap ditampilkan.
class GrowthRepositoryImpl implements IGrowthRepository {
  const GrowthRepositoryImpl(this._localDatasource);

  final GrowthLocalDatasource _localDatasource;

  @override
  Future<List<GrowthRecordEntity>> getRecordsByBaby(String babyId) async {
    try {
      final models = await _localDatasource.getByBaby(babyId);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      throw const LocalStorageFailure(
        'Gagal memuat rekam pertumbuhan dari penyimpanan lokal.',
      );
    }
  }

  @override
  Future<GrowthRecordEntity> addRecord(GrowthRecordEntity record) async {
    try {
      final saved = await _localDatasource.put(
        GrowthRecordModel.fromEntity(record),
      );
      return saved.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan rekam pertumbuhan.');
    }
  }

  @override
  Future<void> deleteRecordsByBaby(String babyId) async {
    try {
      await _localDatasource.deleteByBaby(babyId);
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus rekam pertumbuhan.');
    }
  }
}
