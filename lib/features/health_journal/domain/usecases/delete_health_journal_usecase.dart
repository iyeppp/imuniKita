import '../repositories/i_health_journal_repository.dart';

/// Hapus satu catatan jurnal (swipe-to-delete di daftar jurnal).
class DeleteHealthJournalUseCase {
  const DeleteHealthJournalUseCase(this._repository);

  final IHealthJournalRepository _repository;

  Future<void> execute(String journalId) =>
      _repository.deleteJournal(journalId);
}
