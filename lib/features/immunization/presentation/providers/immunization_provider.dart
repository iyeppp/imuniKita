import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/vaccine_schedule_model.dart';

class ImmunizationNotifier extends FamilyAsyncNotifier<List<VaccineScheduleModel>, String> {
  @override
  Future<List<VaccineScheduleModel>> build(String arg) async {
    final box = await Hive.openBox<VaccineScheduleModel>(AppConstants.vaccineSchedulesBox);
    final schedules = box.values.where((s) => s.babyId == arg).toList();
    schedules.sort((a, b) => a.usiaBulanTarget.compareTo(b.usiaBulanTarget));
    return schedules;
  }

  Future<void> updateStatus(String scheduleId, String status, {DateTime? realisasiDate, String? reaksi}) async {
    final box = await Hive.openBox<VaccineScheduleModel>(AppConstants.vaccineSchedulesBox);
    final schedule = box.get(scheduleId);
    if (schedule != null) {
      schedule.status = status;
      schedule.tanggalRealisasi = realisasiDate;
      schedule.catatanReaksi = reaksi;
      await schedule.save();
      ref.invalidateSelf();
    }
  }
}

final immunizationProvider = AsyncNotifierProviderFamily<ImmunizationNotifier, List<VaccineScheduleModel>, String>(
  ImmunizationNotifier.new,
);
