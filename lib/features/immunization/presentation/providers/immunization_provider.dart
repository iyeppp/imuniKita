import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/notification_helper.dart';
import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';

/// Seluruh jadwal imunisasi satu bayi, terurut berdasarkan usia target.
class ImmunizationNotifier
    extends FamilyAsyncNotifier<List<VaccineScheduleEntity>, String> {
  @override
  Future<List<VaccineScheduleEntity>> build(String arg) async {
    final repository = ref.read(immunizationRepositoryProvider);
    final schedules = await repository.getSchedulesByBaby(arg);
    if (schedules.isNotEmpty) {
      return schedules;
    }

    // Auto-generate seluruh jadwal jika bayi ada tetapi belum punya jadwal (mis. data jadwal terhapus / dibuat sebelum fitur ini ada).
    final baby = await ref.read(babyRepositoryProvider).getBabyById(arg);
    if (baby == null) return schedules;

    // Generate + penjadwalan pengingat lewat satu use case bersama.
    return ref
        .read(syncBabyScheduleUseCaseProvider)
        .execute(
          babyId: baby.babyId,
          namaAnak: baby.namaAnak,
          tanggalLahir: baby.tanggalLahir,
        );
  }

  /// Perbarui satu jadwal -- dipakai layar Detail Vaksin saat menandai "Sudah Diberikan" sekaligus menyimpan catatan KIPI.
  Future<void> updateStatus(
    String scheduleId,
    String status, {
    DateTime? realisasiDate,
    String? reaksi,
  }) async {
    final repository = ref.read(immunizationRepositoryProvider);

    final current = await repository.getScheduleById(scheduleId);
    if (current == null) return;

    await repository.updateSchedule(
      current.copyWith(
        status: status,
        tanggalRealisasi: realisasiDate,
        catatanReaksi: reaksi,
      ),
    );

    // Batalkan notifikasi H-7 & H-1 saat jadwal ditandai selesai agar pengingat tidak muncul setelah vaksin sudah diberikan.
    if (status == VaccineStatus.selesai) {
      for (final daysBefore in NotificationHelper.supportedDaysBefore) {
        final notifId = NotificationHelper.notificationId(
          scheduleId,
          daysBefore,
        );
        try {
          await NotificationService.cancelNotification(notifId);
        } catch (_) {
          // Non-fatal: notifikasi mungkin sudah tidak ada atau plugin belum init
        }
      }
    }

    ref.invalidateSelf();
    ref.invalidate(vaccineScheduleByIdProvider(scheduleId));
  }

  Future<void> deleteAllForBaby() async {
    await ref.read(immunizationRepositoryProvider).deleteSchedulesByBaby(arg);
    ref.invalidateSelf();
  }
}

final immunizationProvider =
    AsyncNotifierProviderFamily<
      ImmunizationNotifier,
      List<VaccineScheduleEntity>,
      String
    >(ImmunizationNotifier.new);

/// Satu jadwal berdasarkan id -- dipakai layar Detail Vaksin (3.3).
final vaccineScheduleByIdProvider =
    FutureProvider.family<VaccineScheduleEntity?, String>((ref, scheduleId) {
      return ref
          .watch(immunizationRepositoryProvider)
          .getScheduleById(scheduleId);
    });
