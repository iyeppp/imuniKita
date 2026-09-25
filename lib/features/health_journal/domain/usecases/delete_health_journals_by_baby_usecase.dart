import '../repositories/i_health_journal_repository.dart';

/// Hapus seluruh jurnal satu bayi (cascade delete profil bayi).
class DeleteHealthJournalsByBabyUseCase {
  const DeleteHealthJournalsByBabyUseCase(this._repository);

  final IHealthJournalRepository _repository;

  Future<void> execute(String babyId) =>
      _repository.deleteJournalsByBaby(babyId);
}
