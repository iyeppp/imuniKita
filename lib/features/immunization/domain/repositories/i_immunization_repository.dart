import '../entities/vaccine_schedule_entity.dart';

/// Kontrak repository jadwal imunisasi.
abstract class IImmunizationRepository {
  /// Seluruh jadwal imunisasi milik [babyId], terurut berdasarkan usia target.
  Future<List<VaccineScheduleEntity>> getSchedulesByBaby(String babyId);

  /// Satu jadwal berdasarkan [scheduleId] (`null` bila tidak ditemukan), dengan status efektif seperti di atas.
  Future<VaccineScheduleEntity?> getScheduleById(String scheduleId);

  /// Simpan sekumpulan jadwal baru (dipanggil `GenerateScheduleUseCase`).
  Future<void> saveSchedules(List<VaccineScheduleEntity> schedules);

  /// Perbarui satu jadwal (mis. tandai selesai + catatan KIPI).
  Future<VaccineScheduleEntity> updateSchedule(VaccineScheduleEntity schedule);


  Future<void> deleteSchedulesByBaby(String babyId);
}
