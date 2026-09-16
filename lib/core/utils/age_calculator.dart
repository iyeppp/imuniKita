/// Hasil pemecahan usia bayi ke tahun/bulan/hari.
class AgeBreakdown {
  const AgeBreakdown({
    required this.years,
    required this.months,
    required this.days,
    required this.totalMonths,
    required this.totalDays,
  });

  final int years;
  final int months;
  final int days;

  /// Usia dalam bulan penuh (dipakai untuk cocokkan target vaksin).
  final int totalMonths;
  final int totalDays;
}

/// Utilitas perhitungan usia bayi.
///
/// Semua perhitungan memakai tanggal saja (tanpa jam) agar hasil konsisten
/// meski dipanggil pada jam berbeda dalam hari yang sama.
abstract class AgeCalculator {
  /// Pemecahan usia lengkap `birthDate` sampai `now` (default: hari ini).
  static AgeBreakdown breakdown(DateTime birthDate, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final birth = _dateOnly(birthDate);

    if (today.isBefore(birth)) {
      return const AgeBreakdown(
        years: 0,
        months: 0,
        days: 0,
        totalMonths: 0,
        totalDays: 0,
      );
    }

    var years = today.year - birth.year;
    var months = today.month - birth.month;
    var days = today.day - birth.day;

    if (days < 0) {
      months -= 1;
      final previousMonth = DateTime(today.year, today.month - 1);
      days += daysInMonth(previousMonth.year, previousMonth.month);
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return AgeBreakdown(
      years: years,
      months: months,
      days: days,
      totalMonths: (years * 12) + months,
      totalDays: today.difference(birth).inDays,
    );
  }

  /// Label ramah pengguna, mis. `8 bulan 12 hari` atau `1 tahun 2 bulan`.
  ///
  /// Dipakai untuk preview usia otomatis di form Tambah Profil Bayi.
  static String label(DateTime birthDate, {DateTime? now}) {
    final age = breakdown(birthDate, now: now);

    if (age.years > 0) {
      final bulan = age.months > 0 ? ' ${age.months} bulan' : '';
      return '${age.years} tahun$bulan';
    }
    if (age.months > 0) {
      final hari = age.days > 0 ? ' ${age.days} hari' : '';
      return '${age.months} bulan$hari';
    }
    return '${age.days} hari';
  }

  /// Tambah [months] bulan dengan pengaman akhir bulan.
  ///
  /// Contoh: 31 Januari + 1 bulan → 28/29 Februari (bukan 2/3 Maret).
  /// Dipakai `GenerateScheduleUseCase` untuk menghitung `tanggalTarget`
  /// tiap jadwal imunisasi dari tanggal lahir bayi.
  static DateTime addMonths(DateTime date, int months) {
    final monthIndex = (date.year * 12) + (date.month - 1) + months;
    final year = _floorDiv(monthIndex, 12);
    final month = _modulo(monthIndex, 12) + 1;
    final day = date.day > daysInMonth(year, month)
        ? daysInMonth(year, month)
        : date.day;

    return DateTime(year, month, day);
  }

  /// Jumlah hari dalam [month] (1-12) pada [year].
  static int daysInMonth(int year, int month) {
    if (month == 12) return 31;
    return DateTime(year, month + 1, 0).day;
  }

  static DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Pembagian bulat yang selalu membulat ke bawah (aman untuk nilai negatif).
  static int _floorDiv(int a, int b) {
    final result = a ~/ b;
    return (a % b != 0 && (a < 0) != (b < 0)) ? result - 1 : result;
  }

  /// Modulo yang selalu bernilai non-negatif.
  static int _modulo(int a, int b) {
    final result = a % b;
    return result < 0 ? result + b : result;
  }
}
