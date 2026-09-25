import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/growth_record_model.dart';

/// Sumber data lokal rekam pertumbuhan via Hive CE.
///
/// `[UAS]`: akan didampingi `growth_remote_datasource.dart` (Firestore) —
/// lihat dev plan §1.1 & §6.1.
class GrowthLocalDatasource {
  const GrowthLocalDatasource();

  Future<Box<GrowthRecordModel>> _openBox() =>
      Hive.openBox<GrowthRecordModel>(AppConstants.growthRecordsBox);

  Future<List<GrowthRecordModel>> getByBaby(String babyId) async {
    final box = await _openBox();
    final list = box.values.where((r) => r.babyId == babyId).toList();
    list.sort((a, b) => a.tanggalPengukuran.compareTo(b.tanggalPengukuran));
    return list;
  }

  Future<GrowthRecordModel> put(GrowthRecordModel model) async {
    final box = await _openBox();
    await box.put(model.recordId, model);
    return model;
  }

  Future<void> deleteByBaby(String babyId) async {
    final box = await _openBox();
    final ids = box.values
        .where((r) => r.babyId == babyId)
        .map((r) => r.recordId)
        .toList();
    await box.deleteAll(ids);
  }
}
