import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/dependency_injection.dart';
import '../../domain/entities/vaccine_schedule_entity.dart';

/// Seluruh jadwal imunisasi satu bayi, terurut berdasarkan usia target.
///
/// Dibaca lewat `IImmunizationRepository` — bukan Hive box langsung — supaya:
/// 1. status `TERLEWAT` ternormalisasi sekali di lapisan data (Temuan #3), dan
/// 2. data source bisa di-swap ke Firestore pada fase UAS tanpa menyentuh
///    screen mana pun (dev plan §6.1).
class ImmunizationNotifier
    extends FamilyAsyncNotifier<List<VaccineScheduleEntity>, String> {
  @override
  Future<List<VaccineScheduleEntity>> build(String arg) {
    return ref.read(immunizationRepositoryProvider).getSchedulesByBaby(arg);
  }

  /// Perbarui satu jadwal — dipakai layar Detail Vaksin saat menandai
  /// "Sudah Diberikan" sekaligus menyimpan catatan KIPI.
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

    ref.invalidateSelf();
    ref.invalidate(vaccineScheduleByIdProvider(scheduleId));
  }
}

final immunizationProvider =
    AsyncNotifierProviderFamily<
      ImmunizationNotifier,
      List<VaccineScheduleEntity>,
      String
    >(ImmunizationNotifier.new);

/// Satu jadwal berdasarkan id — dipakai layar Detail Vaksin (3.3).
///
/// Turut menormalkan status `TERLEWAT` karena membacanya lewat repository.
final vaccineScheduleByIdProvider =
    FutureProvider.family<VaccineScheduleEntity?, String>((ref, scheduleId) {
      return ref
          .watch(immunizationRepositoryProvider)
          .getScheduleById(scheduleId);
    });
