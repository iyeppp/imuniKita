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
      return models.map(_toEntity).toList();
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat jadwal imunisasi.');
    }
  }

  @override
  Future<VaccineScheduleEntity?> getScheduleById(String scheduleId) async {
    try {
      final model = await _localDatasource.getById(scheduleId);
      return model == null ? null : _toEntity(model);
    } catch (_) {
      throw const LocalStorageFailure('Gagal memuat detail jadwal imunisasi.');
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
      return _toEntity(updated);
    } catch (_) {
      throw const LocalStorageFailure('Gagal memperbarui jadwal imunisasi.');
    }
  }

  /// Model → entity sekaligus menormalkan status.
  ///
  /// Jadwal `BELUM` yang tanggal targetnya sudah lewat dihitung `TERLEWAT`
  /// (Temuan #3). Normalisasi dilakukan **saat membaca**, bukan disimpan:
  /// nilainya otomatis ikut berubah begitu hari berganti, tanpa penulisan
  /// ulang ke Hive dan tanpa migrasi data.
  VaccineScheduleEntity _toEntity(VaccineScheduleModel model) {
    final entity = model.toEntity();
    final efektif = VaccineStatus.effective(
      status: entity.status,
      tanggalTarget: entity.tanggalTarget,
    );

    return efektif == entity.status ? entity : entity.copyWith(status: efektif);
  }
}
