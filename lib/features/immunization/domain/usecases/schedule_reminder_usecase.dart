import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/notification_helper.dart';
import '../entities/vaccine_schedule_entity.dart';
import '../repositories/i_immunization_repository.dart';

/// Daftarkan notifikasi lokal H-7 dan H-1 untuk setiap jadwal `BELUM`.
///
/// Dipanggil `AddBabyScreen` setelah `GenerateScheduleUseCase` selesai (dev
/// plan SS4 "Alur Kerja"). Reminder yang tanggalnya sudah lewat (mis. vaksin
/// HB0 usia 0 bulan, H-7-nya jatuh sebelum bayi lahir) otomatis dilewati.
///
/// Fix Bug #11: setelah zonedSchedule berhasil, flag `reminderH7Sent` /
/// `reminderH1Sent` di-set `true` lewat repository sehingga alur ini tidak
/// mendaftarkan ulang pengingat yang sudah terjadwal.
class ScheduleReminderUseCase {
  const ScheduleReminderUseCase({this.repository});

  /// Opsional -- bila diisi, flag `reminderH7Sent`/`reminderH1Sent` akan
  /// diperbarui setelah notifikasi berhasil dijadwalkan (Bug #11).
  final IImmunizationRepository? repository;

  Future<void> execute({
    required String namaAnak,
    required List<VaccineScheduleEntity> schedules,
  }) async {
    // Hormati preferensi "Notifikasi Pengingat" di layar Profil & Pengaturan:
    // bila user mematikannya, tidak ada pengingat baru yang didaftarkan.
    if (!await LocalStorageService.isNotificationEnabled()) return;

    for (final schedule in schedules) {
      if (schedule.status != VaccineStatus.belum) continue;

      bool flagH7Updated = schedule.reminderH7Sent;
      bool flagH1Updated = schedule.reminderH1Sent;
      bool anyFlagChanged = false;

      for (final daysBefore in NotificationHelper.supportedDaysBefore) {
        // Bug #11: lewati jika pengingat ini sudah dijadwalkan sebelumnya
        final alreadySent = daysBefore == 7
            ? schedule.reminderH7Sent
            : schedule.reminderH1Sent;
        if (alreadySent) continue;

        final reminderAt = NotificationHelper.reminderDate(
          tanggalTarget: schedule.tanggalTarget,
          daysBefore: daysBefore,
        );

        if (reminderAt.isBefore(DateTime.now())) continue;

        try {
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

          // Bug #11: tandai flag setelah berhasil
          if (daysBefore == 7) {
            flagH7Updated = true;
          } else {
            flagH1Updated = true;
          }
          anyFlagChanged = true;
        } catch (_) {
          // Non-fatal: gagal jadwalkan notifikasi tidak hentikan alur
        }
      }

      // Simpan update flag jika ada perubahan dan repository tersedia
      if (anyFlagChanged && repository != null) {
        try {
          await repository!.updateSchedule(
            schedule.copyWith(
              reminderH7Sent: flagH7Updated,
              reminderH1Sent: flagH1Updated,
            ),
          );
        } catch (_) {
          // Non-fatal: gagal simpan flag tidak hentikan alur
        }
      }
    }
  }
}