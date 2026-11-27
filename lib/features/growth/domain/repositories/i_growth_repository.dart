import '../entities/growth_record_entity.dart';

/// Kontrak repository rekam pertumbuhan.
abstract class IGrowthRepository {
  /// Seluruh rekam pertumbuhan milik [babyId], terurut lama → baru.
  Future<List<GrowthRecordEntity>> getRecordsByBaby(String babyId);

  /// Simpan (tambah/perbarui) satu rekam pengukuran.
  Future<GrowthRecordEntity> addRecord(GrowthRecordEntity record);

  /// Hapus seluruh rekam pertumbuhan milik [babyId] (dipakai cascade delete).
  Future<void> deleteRecordsByBaby(String babyId);
}
