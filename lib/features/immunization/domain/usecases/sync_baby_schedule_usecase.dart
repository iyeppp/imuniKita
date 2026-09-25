import '../entities/vaccine_schedule_entity.dart';
import 'generate_schedule_usecase.dart';
import 'schedule_reminder_usecase.dart';

/// Alur gabungan **bangun jadwal + daftarkan pengingat H-7/H-1**.
///
/// Fix Bug #34: sebelumnya urutan ini ditulis ulang di Tambah Bayi (1.5),
/// Kelola Profil Anak, dan `ImmunizationNotifier.build` — sehingga perubahan
/// aturan (mis. jadwal yang dibuat otomatis ternyata tidak diberi pengingat)
/// mudah terlewat di salah satu tempat. Kini hanya ada satu sumber kebenaran.
class SyncBabyScheduleUseCase {
  const SyncBabyScheduleUseCase({
    required this.generateSchedule,
    required this.scheduleReminder,
  });

  final GenerateScheduleUseCase generateSchedule;
  final ScheduleReminderUseCase scheduleReminder;

  /// Bangun seluruh jadwal imunisasi nasional dari [tanggalLahir], lalu
  /// daftarkan pengingat untuk jadwal `BELUM` yang masih di depan.
  ///
  /// Penjadwalan pengingat bersifat *best effort* (non-fatal di dalam
  /// `ScheduleReminderUseCase`): profil dan jadwal tetap tersimpan walau izin
  /// alarm/notifikasi OS ditolak.
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
