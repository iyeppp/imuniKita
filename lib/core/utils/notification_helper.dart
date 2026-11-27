import '../constants/app_constants.dart';

/// Utilitas penjadwalan notifikasi pengingat imunisasi H-7 & H-1.
abstract class NotificationHelper {
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
  static int notificationId(String scheduleId, int daysBefore) {
    final offset = supportedDaysBefore.indexOf(daysBefore);
    // Ruang ID diperbesar (100 juta) agar tabrakan antar `scheduleId` makin kecil.
    final base = _fnv1a(scheduleId) % 100000000;
    return (base * 2) + (offset < 0 ? 9 : offset);
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
