import '../constants/app_constants.dart';

/// Utilitas penjadwalan notifikasi pengingat imunisasi H-7 & H-1.
///
/// Semua perhitungan tanggal/ID di sini bersifat murni (pure function) agar
/// mudah diuji tanpa plugin notifikasi. Pengiriman ke OS dilakukan
/// `NotificationService`, dipanggil oleh `ScheduleReminderUseCase`.
abstract class NotificationHelper {
  /// Offset pengingat yang didukung, sesuai dev plan (H-7 dan H-1).
  static const List<int> supportedDaysBefore = [7, 1];

  /// Tanggal pengingat = `tanggalTarget - daysBefore` pada jam [hour].
  static DateTime reminderDate({
    required DateTime tanggalTarget,
    required int daysBefore,
    int hour = AppConstants.reminderHour,
  }) {
    final date = DateTime(
      tanggalTarget.year,
      tanggalTarget.month,
      tanggalTarget.day,
    ).subtract(Duration(days: daysBefore));

    return DateTime(date.year, date.month, date.day, hour);
  }

  /// ID notifikasi Android — deterministik dari `scheduleId` + offset hari.
  ///
  /// Deterministik penting agar notifikasi lama bisa dibatalkan/diganti
  /// dengan ID yang sama setelah app di-restart (`String.hashCode` bawaan
  /// Dart tidak dijamin stabil lintas proses/isolate).
  static int notificationId(String scheduleId, int daysBefore) {
    final offset = supportedDaysBefore.indexOf(daysBefore);
    final base = _fnv1a(scheduleId) % 1000000;
    return (base * 10) + (offset < 0 ? 9 : offset);
  }

  /// Judul notifikasi.
  static String buildTitle({required String namaAnak}) =>
      '🔔 Pengingat Imunisasi $namaAnak';

  /// Isi notifikasi — dibedakan untuk H-7 dan H-1.
  static String buildBody({
    required String namaVaksin,
    required int daysBefore,
  }) {
    final kapan = switch (daysBefore) {
      7 => 'minggu',
      1 => 'besok',
      _ => '$daysBefore hari',
    };
    return 'Vaksin $namaVaksin dijadwalkan $kapan! Siapkan buku KIA-mu.';
  }

  /// FNV-1a 32-bit — hash sederhana, stabil, dan bebas dependency.
  static int _fnv1a(String input) {
    var hash = 0x811c9dc5;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}
