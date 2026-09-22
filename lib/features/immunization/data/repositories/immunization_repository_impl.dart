import '../../../../core/errors/failures.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';
import '../../domain/repositories/i_immunization_repository.dart';
import '../datasources/vaccine_local_datasource.dart';
import '../models/vaccine_schedule_model.dart';

/// Implementasi `IImmunizationRepository` fase UTS — sepenuhnya di atas
/// Hive CE.
class ImmunizationRepositoryImpl implements IImmunizationRepository {
  const ImmunizationRepositoryImpl(this._localDatasource);

  final VaccineLocalDatasource _localDatasource;

  @override
  Future<List<VaccineScheduleEntity>> getSchedulesByBaby(String babyId) async {
    try {
      final models = await _localDatasource.getByBaby(babyId);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat jadwal imunisasi.');
    }
  }

  @override
  Future<void> saveSchedules(List<VaccineScheduleEntity> schedules) async {
    try {
      await _localDatasource.saveAll(
        schedules.map(VaccineScheduleModel.fromEntity).toList(),
      );
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan jadwal imunisasi.');
    }
  }

  @override
  Future<VaccineScheduleEntity> updateSchedule(
    VaccineScheduleEntity schedule,
  ) async {
    try {
      final updated = await _localDatasource.update(
        VaccineScheduleModel.fromEntity(schedule),
      );
      return updated.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui jadwal imunisasi.');
    }
  }
}
