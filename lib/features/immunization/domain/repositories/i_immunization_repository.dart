import '../entities/vaccine_schedule_entity.dart';

/// Kontrak repository jadwal imunisasi.
///
/// Fase UTS diimplementasikan di atas Hive CE. Fase UAS akan menambah
/// `vaccine_remote_datasource.dart` (Firestore) di belakang kontrak yang
/// sama (dev plan §6.1) tanpa mengubah use case.
abstract class IImmunizationRepository {
  /// Seluruh jadwal imunisasi milik [babyId], terurut berdasarkan usia target.
  Future<List<VaccineScheduleEntity>> getSchedulesByBaby(String babyId);

  /// Simpan sekumpulan jadwal baru (dipanggil `GenerateScheduleUseCase`).
  Future<void> saveSchedules(List<VaccineScheduleEntity> schedules);

  /// Perbarui satu jadwal (mis. tandai selesai + catatan KIPI).
  Future<VaccineScheduleEntity> updateSchedule(VaccineScheduleEntity schedule);
}
