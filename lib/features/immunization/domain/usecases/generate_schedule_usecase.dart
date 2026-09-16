import 'package:uuid/uuid.dart';

import '../../../../core/constants/vaccine_schedule.dart';
import '../../../../core/utils/age_calculator.dart';
import '../entities/vaccine_schedule_entity.dart';
import '../repositories/i_immunization_repository.dart';

/// Bangun seluruh jadwal imunisasi nasional untuk satu bayi.
///
/// Dipanggil `AddBabyScreen` tepat setelah `AddBabyUseCase` berhasil (lihat
/// dev plan §4 "Alur Kerja"). `tanggalTarget` tiap vaksin dihitung dari
/// `tanggalLahir + usiaBulan` (lihat `VaccineMaster`), dengan
/// `AgeCalculator.addMonths` agar aman terhadap kasus akhir bulan.
class GenerateScheduleUseCase {
  GenerateScheduleUseCase(this._repository, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final IImmunizationRepository _repository;
  final Uuid _uuid;

  Future<List<VaccineScheduleEntity>> execute({
    required String babyId,
    required DateTime tanggalLahir,
  }) async {
    // Guard: jangan generate ulang bila bayi ini sudah punya jadwal
    // (mis. layar Add Baby ter-trigger dua kali karena double tap).
    final existing = await _repository.getSchedulesByBaby(babyId);
    if (existing.isNotEmpty) return existing;

    final schedules = VaccineMaster.jadwalNasional
        .map(
          (item) => VaccineScheduleEntity(
            scheduleId: _uuid.v4(),
            babyId: babyId,
            namaVaksin: item.nama,
            deskripsi: item.deskripsi,
            usiaBulanTarget: item.usiaBulan,
            tanggalTarget: AgeCalculator.addMonths(
              tanggalLahir,
              item.usiaBulan,
            ),
          ),
        )
        .toList();

    await _repository.saveSchedules(schedules);
    return schedules;
  }
}
