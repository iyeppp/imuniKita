import '../entities/vaccine_schedule_entity.dart';
import 'generate_schedule_usecase.dart';
import 'schedule_reminder_usecase.dart';

/// Alur gabungan **bangun jadwal + daftarkan pengingat H-7/H-1**.
class SyncBabyScheduleUseCase {
  const SyncBabyScheduleUseCase({
    required this.generateSchedule,
    required this.scheduleReminder,
  });

  final GenerateScheduleUseCase generateSchedule;
  final ScheduleReminderUseCase scheduleReminder;

  /// Bangun seluruh jadwal imunisasi nasional dari [tanggalLahir], lalu daftarkan pengingat untuk jadwal `BELUM` yang masih di depan.
  Future<List<VaccineScheduleEntity>> execute({
    required String babyId,
    required String namaAnak,
    required DateTime tanggalLahir,
  }) async {
    final schedules = await generateSchedule.execute(
      babyId: babyId,
      tanggalLahir: tanggalLahir,
    );

    if (schedules.isNotEmpty) {
      await scheduleReminder.execute(namaAnak: namaAnak, schedules: schedules);
    }

    return schedules;
  }
}
