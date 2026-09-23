import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/health_journal_model.dart';

class JournalNotifier extends FamilyAsyncNotifier<List<HealthJournalModel>, String> {
  @override
  Future<List<HealthJournalModel>> build(String arg) async {
    final box = await Hive.openBox<HealthJournalModel>(AppConstants.healthJournalsBox);
    final journals = box.values.where((j) => j.babyId == arg).toList();
    journals.sort((a, b) => b.tanggalCatatan.compareTo(a.tanggalCatatan));
    return journals;
  }

  Future<void> addJournal(HealthJournalModel journal) async {
    final box = await Hive.openBox<HealthJournalModel>(AppConstants.healthJournalsBox);
    await box.put(journal.journalId, journal);
    ref.invalidateSelf();
  }

  Future<void> deleteJournal(String journalId) async {
    final box = await Hive.openBox<HealthJournalModel>(AppConstants.healthJournalsBox);
    await box.delete(journalId);
    ref.invalidateSelf();
  }


  /// Hapus seluruh jurnal bayi ini (dipakai saat bayi dihapus).
  Future<void> deleteAllForBaby() async {
    final box = await Hive.openBox<HealthJournalModel>(AppConstants.healthJournalsBox);
    final ids = box.values.where((j) => j.babyId == arg).map((j) => j.journalId).toList();
    await box.deleteAll(ids);
    ref.invalidateSelf();
  }
}

final journalProvider = AsyncNotifierProviderFamily<JournalNotifier, List<HealthJournalModel>, String>(
  JournalNotifier.new,
);
