import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/notification_helper.dart';
import '../entities/vaccine_schedule_entity.dart';

/// Daftarkan notifikasi lokal H-7 dan H-1 untuk setiap jadwal `BELUM`.
///
/// Dipanggil `AddBabyScreen` setelah `GenerateScheduleUseCase` selesai (dev
/// plan §4 "Alur Kerja"). Reminder yang tanggalnya sudah lewat (mis. vaksin
/// HB0 usia 0 bulan, H-7-nya jatuh sebelum bayi lahir) otomatis dilewati.
class ScheduleReminderUseCase {
  const ScheduleReminderUseCase();

  Future<void> execute({
    required String namaAnak,
    required List<VaccineScheduleEntity> schedules,
  }) async {
    for (final schedule in schedules) {
      if (schedule.status != VaccineStatus.belum) continue;

      for (final daysBefore in NotificationHelper.supportedDaysBefore) {
        final reminderAt = NotificationHelper.reminderDate(
          tanggalTarget: schedule.tanggalTarget,
          daysBefore: daysBefore,
        );

        if (reminderAt.isBefore(DateTime.now())) continue;

        await NotificationService.scheduleNotification(
          id: NotificationHelper.notificationId(
            schedule.scheduleId,
            daysBefore,
          ),
          title: NotificationHelper.buildTitle(namaAnak: namaAnak),
          body: NotificationHelper.buildBody(
            namaVaksin: schedule.namaVaksin,
            daysBefore: daysBefore,
          ),
          scheduledDate: reminderAt,
          payload: schedule.scheduleId,
        );
      }
    }
  }
}
