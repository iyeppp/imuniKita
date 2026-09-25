import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/health_journal_model.dart';

/// Sumber data lokal jurnal kesehatan via Hive CE.
///
/// `[UAS]`: akan didampingi `health_journal_remote_datasource.dart` (Firestore)
/// — lihat dev plan §1.1 & §6.1.
class HealthJournalLocalDatasource {
  const HealthJournalLocalDatasource();

  Future<Box<HealthJournalModel>> _openBox() =>
      Hive.openBox<HealthJournalModel>(AppConstants.healthJournalsBox);

  Future<List<HealthJournalModel>> getByBaby(String babyId) async {
    final box = await _openBox();
    final list = box.values.where((j) => j.babyId == babyId).toList();
    list.sort((a, b) => b.tanggalCatatan.compareTo(a.tanggalCatatan));
    return list;
  }

  Future<HealthJournalModel> put(HealthJournalModel model) async {
    final box = await _openBox();
    await box.put(model.journalId, model);
    return model;
  }

  Future<void> delete(String journalId) async {
    final box = await _openBox();
    await box.delete(journalId);
  }

  Future<void> deleteByBaby(String babyId) async {
    final box = await _openBox();
    final ids = box.values
        .where((j) => j.babyId == babyId)
        .map((j) => j.journalId)
        .toList();
    await box.deleteAll(ids);
  }
}
