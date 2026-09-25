import '../entities/growth_record_entity.dart';

/// Kontrak repository rekam pertumbuhan.
///
/// Fase UTS diimplementasikan di atas Hive CE; fase UAS menambah
/// `growth_remote_datasource.dart` di belakang kontrak yang sama (dev plan §6.1).
abstract class IGrowthRepository {
  /// Seluruh rekam pertumbuhan milik [babyId], terurut lama → baru.
  Future<List<GrowthRecordEntity>> getRecordsByBaby(String babyId);

  /// Simpan (tambah/perbarui) satu rekam pengukuran.
  Future<GrowthRecordEntity> addRecord(GrowthRecordEntity record);

  /// Hapus seluruh rekam pertumbuhan milik [babyId] (dipakai cascade delete).
  Future<void> deleteRecordsByBaby(String babyId);
}
