import '../entities/health_journal_entity.dart';
import '../repositories/i_health_journal_repository.dart';

/// Ambil seluruh catatan jurnal milik satu bayi (terurut baru → lama).
class GetHealthJournalsUseCase {
  const GetHealthJournalsUseCase(this._repository);

  final IHealthJournalRepository _repository;

  Future<List<HealthJournalEntity>> execute(String babyId) =>
      _repository.getJournalsByBaby(babyId);
}
