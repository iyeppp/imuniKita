import '../../../../core/errors/failures.dart';
import '../../domain/entities/health_journal_entity.dart';
import '../../domain/repositories/i_health_journal_repository.dart';
import '../datasources/health_journal_local_datasource.dart';
import '../models/health_journal_model.dart';

/// Implementasi `IHealthJournalRepository` fase UTS — di atas Hive CE.
class HealthJournalRepositoryImpl implements IHealthJournalRepository {
  const HealthJournalRepositoryImpl(this._localDatasource);

  final HealthJournalLocalDatasource _localDatasource;

  @override
  Future<List<HealthJournalEntity>> getJournalsByBaby(String babyId) async {
    try {
      final models = await _localDatasource.getByBaby(babyId);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      throw const LocalStorageFailure(
        'Gagal memuat jurnal kesehatan dari penyimpanan lokal.',
      );
    }
  }

  @override
  Future<HealthJournalEntity> addJournal(HealthJournalEntity journal) async {
    try {
      final saved = await _localDatasource.put(
        HealthJournalModel.fromEntity(journal),
      );
      return saved.toEntity();
    } catch (_) {
      throw const LocalStorageFailure('Gagal menyimpan catatan jurnal.');
    }
  }

  @override
  Future<void> deleteJournal(String journalId) async {
    try {
      await _localDatasource.delete(journalId);
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus catatan jurnal.');
    }
  }

  @override
  Future<void> deleteJournalsByBaby(String babyId) async {
    try {
      await _localDatasource.deleteByBaby(babyId);
    } catch (_) {
      throw const LocalStorageFailure('Gagal menghapus jurnal kesehatan.');
    }
  }
}
