import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/vaccine_schedule_model.dart';

/// Sumber data lokal jadwal imunisasi via Hive CE.
///
/// `[UAS]`: akan didampingi `vaccine_remote_datasource.dart` (Firestore) —
/// lihat dev plan §1.1 & §6.1.
class VaccineLocalDatasource {
  const VaccineLocalDatasource();

  Future<Box<VaccineScheduleModel>> _openBox() =>
      Hive.openBox<VaccineScheduleModel>(AppConstants.vaccineSchedulesBox);

  Future<List<VaccineScheduleModel>> getByBaby(String babyId) async {
    final box = await _openBox();
    final list = box.values.where((s) => s.babyId == babyId).toList();
    list.sort((a, b) => a.usiaBulanTarget.compareTo(b.usiaBulanTarget));
    return list;
  }

  Future<VaccineScheduleModel?> getById(String scheduleId) async {
    final box = await _openBox();
    return box.get(scheduleId);
  }

  Future<void> saveAll(List<VaccineScheduleModel> models) async {
    final box = await _openBox();
    await box.putAll({for (final m in models) m.scheduleId: m});
  }

  Future<void> deleteByBaby(String babyId) async {
    final box = await _openBox();
    final ids = box.values
        .where((s) => s.babyId == babyId)
        .map((s) => s.scheduleId)
        .toList();
    await box.deleteAll(ids);
  }

  Future<VaccineScheduleModel> update(VaccineScheduleModel model) async {
    final box = await _openBox();
    await box.put(model.scheduleId, model);
    return model;
  }
}
