import '../entities/vaccine_schedule_entity.dart';

/// Kontrak repository jadwal imunisasi.
///
/// Fase UTS diimplementasikan di atas Hive CE. Fase UAS akan menambah
/// `vaccine_remote_datasource.dart` (Firestore) di belakang kontrak yang
/// sama (dev plan §6.1) tanpa mengubah use case.
abstract class IImmunizationRepository {
  /// Seluruh jadwal imunisasi milik [babyId], terurut berdasarkan usia target.
  ///
  /// Status yang dikembalikan sudah **efektif**: jadwal `BELUM` yang tanggal
  /// targetnya sudah lewat menjadi `TERLEWAT` (lihat `VaccineStatus.effective`).
  Future<List<VaccineScheduleEntity>> getSchedulesByBaby(String babyId);

  /// Satu jadwal berdasarkan [scheduleId] (`null` bila tidak ditemukan),
  /// dengan status efektif seperti di atas.
  Future<VaccineScheduleEntity?> getScheduleById(String scheduleId);

  /// Simpan sekumpulan jadwal baru (dipanggil `GenerateScheduleUseCase`).
  Future<void> saveSchedules(List<VaccineScheduleEntity> schedules);

  /// Perbarui satu jadwal (mis. tandai selesai + catatan KIPI).
  Future<VaccineScheduleEntity> updateSchedule(VaccineScheduleEntity schedule);


  /// Hapus seluruh jadwal milik [babyId] (dipakai saat profil bayi dihapus).
  Future<void> deleteSchedulesByBaby(String babyId);
}
