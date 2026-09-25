import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/notification_helper.dart';
import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';

/// Seluruh jadwal imunisasi satu bayi, terurut berdasarkan usia target.
///
/// Dibaca lewat `IImmunizationRepository` -- bukan Hive box langsung -- supaya:
/// 1. status `TERLEWAT` ternormalisasi sekali di lapisan data (Temuan #3), dan
/// 2. data source bisa di-swap ke Firestore pada fase UAS tanpa menyentuh
///    screen mana pun (dev plan SS6.1).
class ImmunizationNotifier
    extends FamilyAsyncNotifier<List<VaccineScheduleEntity>, String> {
  @override
  Future<List<VaccineScheduleEntity>> build(String arg) async {
    final repository = ref.read(immunizationRepositoryProvider);
    final schedules = await repository.getSchedulesByBaby(arg);
    if (schedules.isNotEmpty) {
      return schedules;
    }

    // Auto-generate seluruh jadwal jika bayi ada tetapi belum punya jadwal
    try {
      final baby = await ref.read(babyRepositoryProvider).getBabyById(arg);
      if (baby != null) {
        return await ref
            .read(generateScheduleUseCaseProvider)
            .execute(babyId: baby.babyId, tanggalLahir: baby.tanggalLahir);
      }
    } catch (_) {
      // Non-fatal jika repository baby belum tersedia
    }

    return schedules;
  }

  /// Perbarui satu jadwal -- dipakai layar Detail Vaksin saat menandai
  /// "Sudah Diberikan" sekaligus menyimpan catatan KIPI.
  ///
  /// Fix Bug #7: saat status berubah ke [VaccineStatus.selesai], notifikasi
  /// H-7 dan H-1 untuk jadwal ini dibatalkan agar tidak muncul lagi.
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

    // Bug #7: batalkan notifikasi H-7 & H-1 saat jadwal ditandai selesai
    // agar pengingat tidak muncul setelah vaksin sudah diberikan.
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

  /// Hapus seluruh jadwal bayi ini -- dipakai saat profil bayi dihapus.
  Future<void> deleteAllForBaby() async {
    await ref
        .read(immunizationRepositoryProvider)
        .deleteSchedulesByBaby(arg);
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
///
/// Turut menormalkan status `TERLEWAT` karena membacanya lewat repository.
final vaccineScheduleByIdProvider =
    FutureProvider.family<VaccineScheduleEntity?, String>((ref, scheduleId) {
      return ref
          .watch(immunizationRepositoryProvider)
          .getScheduleById(scheduleId);
    });