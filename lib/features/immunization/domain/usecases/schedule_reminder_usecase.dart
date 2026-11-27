import 'package:flutter/foundation.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/push_service.dart';
import '../../../../core/utils/notification_helper.dart';
import '../entities/vaccine_schedule_entity.dart';
import '../repositories/i_immunization_repository.dart';

/// Daftarkan notifikasi lokal H-7 dan H-1 untuk setiap jadwal `BELUM`.
class ScheduleReminderUseCase {
  const ScheduleReminderUseCase({this.repository, this.pushService});

  /// Opsional -- bila diisi, flag `reminderH7Sent`/`reminderH1Sent` akan diperbarui setelah notifikasi berhasil dijadwalkan.
  final IImmunizationRepository? repository;

  /// Opsional -- sumber status FCM untuk deduplikasi.
  final IPushService? pushService;

  Future<void> execute({
    required String namaAnak,
    required List<VaccineScheduleEntity> schedules,
  }) async {
    // Hormati preferensi "Notifikasi Pengingat" di layar Profil & Pengaturan: bila user mematikannya, tidak ada pengingat baru yang didaftarkan.
    if (!await LocalStorageService.isNotificationEnabled()) return;

    // Bila FCM aktif, server (GitHub Actions) yang mengirim pengingat.
    if (pushService != null && await pushService!.isPushActive()) {
      debugPrint(
        'ScheduleReminderUseCase: FCM aktif — pengingat lokal dilewati.',
      );
      return;
    }

    for (final schedule in schedules) {
      if (schedule.status != VaccineStatus.belum) continue;

      bool flagH7Updated = schedule.reminderH7Sent;
      bool flagH1Updated = schedule.reminderH1Sent;
      bool anyFlagChanged = false;

      for (final daysBefore in NotificationHelper.supportedDaysBefore) {
        // Lewati jika pengingat ini sudah dijadwalkan sebelumnya
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

          // Tandai flag setelah berhasil
          if (daysBefore == 7) {
            flagH7Updated = true;
          } else {
            flagH1Updated = true;
          }
          anyFlagChanged = true;
        } catch (e) {
          // Non-fatal: gagal jadwalkan notifikasi tidak hentikan alur, tetapi dicatat agar kegagalan (mis. izin alarm ditolak) tidak senyap.
          debugPrint(
            'ScheduleReminderUseCase: gagal menjadwalkan '
            '${schedule.namaVaksin} H-$daysBefore — $e',
          );
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
        } catch (e) {
          // Non-fatal: flag hanya penanda anti-duplikasi; kegagalan simpan dicatat agar tidak menutupi masalah storage.
          debugPrint(
            'ScheduleReminderUseCase: gagal menyimpan flag pengingat — $e',
          );
        }
      }
    }
  }
}
