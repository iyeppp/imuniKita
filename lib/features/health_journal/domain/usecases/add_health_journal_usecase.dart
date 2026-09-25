import '../entities/health_journal_entity.dart';
import '../repositories/i_health_journal_repository.dart';

/// Simpan satu catatan jurnal kesehatan.
class AddHealthJournalUseCase {
  const AddHealthJournalUseCase(this._repository);

  final IHealthJournalRepository _repository;

  Future<HealthJournalEntity> execute(HealthJournalEntity journal) =>
      _repository.addJournal(journal);
}
