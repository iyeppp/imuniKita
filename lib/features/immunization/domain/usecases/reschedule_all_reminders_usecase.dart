import '../../../baby_profile/domain/entities/baby_entity.dart';
import '../entities/vaccine_schedule_entity.dart';
import '../repositories/i_immunization_repository.dart';
import 'schedule_reminder_usecase.dart';

/// Daftarkan ulang pengingat H-7 & H-1 untuk **semua** bayi milik user.
///
/// Dipakai toggle notifikasi di layar Profil & Pengaturan: saat user
/// mengaktifkan kembali notifikasi, pengingat untuk seluruh jadwal `BELUM`
/// perlu didaftarkan lagi (penjadwalan hanya terjadi saat bayi didaftarkan).
///
/// Fix Bug #34: sebelumnya loop ini ditulis di dalam `settings_screen.dart`;
/// kini menjadi use case agar bisa diuji dan tidak lagi mencampur logika
/// bisnis ke lapisan UI.
class RescheduleAllRemindersUseCase {
  const RescheduleAllRemindersUseCase({
    required this.repository,
    required this.reminder,
  });

  final IImmunizationRepository repository;
  final ScheduleReminderUseCase reminder;

  /// Mengembalikan jumlah jadwal `BELUM` yang diproses (untuk pesan ke user).
  Future<int> execute(List<BabyEntity> babies) async {
    var jumlah = 0;

    for (final baby in babies) {
      final schedules = await repository.getSchedulesByBaby(baby.babyId);
      if (schedules.isEmpty) continue;

      await reminder.execute(namaAnak: baby.namaAnak, schedules: schedules);
      jumlah += schedules.where((s) => s.status == VaccineStatus.belum).length;
    }

    return jumlah;
  }
}
