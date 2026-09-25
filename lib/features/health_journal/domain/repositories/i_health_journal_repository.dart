import '../entities/health_journal_entity.dart';

/// Kontrak repository jurnal kesehatan.
///
/// Fase UTS diimplementasikan di atas Hive CE; fase UAS menambah
/// `health_journal_remote_datasource.dart` di belakang kontrak yang sama
/// (dev plan §6.1).
abstract class IHealthJournalRepository {
  /// Seluruh catatan jurnal milik [babyId], terurut baru → lama.
  Future<List<HealthJournalEntity>> getJournalsByBaby(String babyId);

  /// Simpan (tambah/perbarui) satu catatan jurnal.
  Future<HealthJournalEntity> addJournal(HealthJournalEntity journal);

  /// Hapus satu catatan jurnal berdasarkan [journalId].
  Future<void> deleteJournal(String journalId);

  /// Hapus seluruh jurnal milik [babyId] (dipakai cascade delete).
  Future<void> deleteJournalsByBaby(String babyId);
}
