/// Tabel referensi pertumbuhan **WHO Child Growth Standards** (0–24 bulan).
///
/// Temuan #8: sebelumnya grafik hanya menggambar satu garis statis (7 kg / 65 cm
/// / 40 cm) sehingga klaim "sesuai standar WHO" tidak berdasar. Di sini
/// disediakan **median, −2SD, dan +2SD** per bulan untuk berat badan (BB),
/// tinggi/panjang badan (TB), dan lingkar kepala (LK), dipisah laki-laki dan
/// perempuan.
///
/// Nilai diringkas dari tabel WHO Child Growth Standards (0–24 bulan).
/// Keterbatasan yang diketahui: hanya sampai 24 bulan dan bukan alat diagnosis —
/// tetap alat bantu visual untuk orang tua.
library;

/// Satu seri referensi (satu metrik, satu jenis kelamin).
class WhoSeries {
  const WhoSeries({
    required this.label,
    required this.unit,
    required this.median,
    required this.minus2Sd,
    required this.plus2Sd,
  });

  /// Label metrik, mis. "Berat Badan".
  final String label;
  final String unit;

  /// Nilai per bulan (indeks = usia bulan 0..24).
  final List<double> median;
  final List<double> minus2Sd;
  final List<double> plus2Sd;

  /// Usia tertinggi yang didukung tabel (bulan).
  int get maxMonth => median.length - 1;

  /// Interpolasi linear nilai [seri] pada [bulan]. `null` bila di luar rentang.
  static double? _interpolate(List<double> seri, double bulan) {
    if (bulan < 0 || bulan > seri.length - 1) return null;
    final bawah = bulan.floor();
    final atas = bulan.ceil();
    if (bawah == atas) return seri[bawah];
    final rasio = bulan - bawah;
    return seri[bawah] + (seri[atas] - seri[bawah]) * rasio;
  }

  double? medianAt(double bulan) => _interpolate(median, bulan);
  double? minus2SdAt(double bulan) => _interpolate(minus2Sd, bulan);
  double? plus2SdAt(double bulan) => _interpolate(plus2Sd, bulan);
}

/// Akses tabel referensi WHO per metrik & jenis kelamin.
abstract class WhoGrowthReference {
  // ── Berat badan (kg) ─────────────────────────────────────────────────────
  static const WhoSeries bbLaki = WhoSeries(
    label: 'Berat Badan',
    unit: 'kg',
    median: [
      3.3, 4.5, 5.6, 6.4, 7.0, 7.5, 7.9, 8.3, 8.6, 8.9, //
      9.2, 9.4, 9.6, 9.9, 10.1, 10.3, 10.5, 10.7, 10.9, 11.1, //
      11.3, 11.5, 11.8, 12.0, 12.2,
    ],
    minus2Sd: [
      2.5, 3.4, 4.3, 5.0, 5.6, 6.0, 6.4, 6.7, 6.9, 7.1, //
      7.4, 7.6, 7.7, 7.9, 8.1, 8.3, 8.4, 8.6, 8.8, 8.9, //
      9.1, 9.2, 9.4, 9.5, 9.7,
    ],
    plus2Sd: [
      4.4, 5.8, 7.1, 8.0, 8.7, 9.3, 9.8, 10.3, 10.7, 11.0, //
      11.4, 11.7, 12.0, 12.3, 12.6, 12.8, 13.1, 13.4, 13.7, 13.9, //
      14.2, 14.5, 14.7, 15.0, 15.3,
    ],
  );

  static const WhoSeries bbPerempuan = WhoSeries(
    label: 'Berat Badan',
    unit: 'kg',
    median: [
      3.2, 4.2, 5.1, 5.8, 6.4, 6.9, 7.3, 7.6, 7.9, 8.2, //
      8.5, 8.7, 8.9, 9.2, 9.4, 9.6, 9.8, 10.0, 10.2, 10.4, //
      10.6, 10.9, 11.1, 11.3, 11.5,
    ],
    minus2Sd: [
      2.4, 3.2, 3.9, 4.5, 5.0, 5.4, 5.7, 6.0, 6.3, 6.5, //
      6.7, 6.9, 7.0, 7.2, 7.4, 7.6, 7.7, 7.9, 8.1, 8.2, //
      8.4, 8.6, 8.7, 8.9, 9.0,
    ],
    plus2Sd: [
      4.2, 5.5, 6.6, 7.5, 8.2, 8.8, 9.3, 9.8, 10.2, 10.5, //
      10.9, 11.2, 11.5, 11.8, 12.1, 12.4, 12.6, 12.9, 13.2, 13.5, //
      13.7, 14.0, 14.3, 14.6, 14.8,
    ],
  );

  // ── Tinggi/panjang badan (cm) ────────────────────────────────────────────
  static const WhoSeries tbLaki = WhoSeries(
    label: 'Tinggi Badan',
    unit: 'cm',
    median: [
      49.9, 54.7, 58.4, 61.4, 63.9, 65.9, 67.6, 69.2, 70.6, 72.0, //
      73.3, 74.5, 75.7, 76.9, 78.0, 79.1, 80.2, 81.2, 82.3, 83.2, //
      84.2, 85.1, 86.0, 86.9, 87.8,
    ],
    minus2Sd: [
      46.1, 50.8, 54.4, 57.3, 59.7, 61.7, 63.3, 64.8, 66.2, 67.5, //
      68.7, 69.9, 71.0, 72.1, 73.1, 74.1, 75.0, 76.0, 76.9, 77.7, //
      78.6, 79.4, 80.2, 81.0, 81.7,
    ],
    plus2Sd: [
      53.7, 58.6, 62.4, 65.5, 68.0, 70.1, 71.9, 73.5, 75.0, 76.5, //
      77.9, 79.2, 80.5, 81.8, 83.0, 84.2, 85.4, 86.5, 87.7, 88.8, //
      89.8, 90.9, 91.9, 92.9, 93.9,
    ],
  );

  static const WhoSeries tbPerempuan = WhoSeries(
    label: 'Tinggi Badan',
    unit: 'cm',
    median: [
      49.1, 53.7, 57.1, 59.8, 62.1, 64.0, 65.7, 67.3, 68.7, 70.1, //
      71.5, 72.8, 74.0, 75.2, 76.4, 77.5, 78.6, 79.7, 80.7, 81.7, //
      82.7, 83.7, 84.6, 85.5, 86.4,
    ],
    minus2Sd: [
      45.4, 49.8, 53.0, 55.6, 57.8, 59.6, 61.2, 62.7, 64.0, 65.3, //
      66.5, 67.7, 68.9, 70.0, 71.0, 72.0, 73.0, 73.9, 74.9, 75.8, //
      76.7, 77.5, 78.4, 79.2, 80.0,
    ],
    plus2Sd: [
      52.7, 57.6, 61.1, 64.0, 66.4, 68.5, 70.3, 71.9, 73.5, 74.9, //
      76.4, 77.8, 79.2, 80.5, 81.7, 82.9, 84.1, 85.4, 86.6, 87.7, //
      88.8, 89.8, 90.9, 91.9, 92.9,
    ],
  );

  // ── Lingkar kepala (cm) ──────────────────────────────────────────────────
  static const WhoSeries lkLaki = WhoSeries(
    label: 'Lingkar Kepala',
    unit: 'cm',
    median: [
      34.5, 37.3, 39.1, 40.5, 41.6, 42.6, 43.3, 44.0, 44.5, 45.0, //
      45.4, 45.8, 46.1, 46.3, 46.6, 46.8, 47.0, 47.2, 47.4, 47.5, //
      47.7, 47.8, 48.0, 48.1, 48.3,
    ],
    minus2Sd: [
      32.1, 34.9, 36.8, 38.1, 39.2, 40.1, 40.9, 41.5, 42.0, 42.5, //
      42.9, 43.2, 43.6, 43.8, 44.1, 44.3, 44.5, 44.7, 44.9, 45.0, //
      45.2, 45.3, 45.5, 45.6, 45.8,
    ],
    plus2Sd: [
      36.9, 39.6, 41.5, 42.9, 44.0, 45.0, 45.8, 46.4, 47.0, 47.4, //
      47.9, 48.2, 48.6, 48.9, 49.2, 49.4, 49.6, 49.8, 50.0, 50.1, //
      50.3, 50.4, 50.6, 50.7, 50.9,
    ],
  );

  static const WhoSeries lkPerempuan = WhoSeries(
    label: 'Lingkar Kepala',
    unit: 'cm',
    median: [
      33.9, 36.5, 38.3, 39.5, 40.6, 41.5, 42.2, 42.8, 43.4, 43.8, //
      44.2, 44.6, 44.9, 45.2, 45.4, 45.7, 45.9, 46.1, 46.2, 46.4, //
      46.6, 46.7, 46.9, 47.0, 47.2,
    ],
    minus2Sd: [
      31.5, 34.2, 35.8, 37.1, 38.1, 38.9, 39.6, 40.2, 40.7, 41.2, //
      41.5, 41.9, 42.2, 42.5, 42.7, 42.9, 43.1, 43.3, 43.5, 43.6, //
      43.8, 43.9, 44.1, 44.2, 44.3,
    ],
    plus2Sd: [
      36.1, 38.8, 40.7, 42.0, 43.1, 44.0, 44.8, 45.4, 45.9, 46.4, //
      46.8, 47.2, 47.5, 47.8, 48.0, 48.3, 48.5, 48.6, 48.8, 48.9, //
      49.1, 49.2, 49.4, 49.5, 49.6,
    ],
  );

  /// Mode grafik di `GrowthChartScreen` → seri WHO yang sesuai.
  ///
  /// [isLakiLaki] menentukan tabel yang dipakai (standar WHO dipisah per jenis
  /// kelamin).
  static WhoSeries? forMode(String mode, {required bool isLakiLaki}) {
    switch (mode) {
      case 'BB':
        return isLakiLaki ? bbLaki : bbPerempuan;
      case 'TB':
        return isLakiLaki ? tbLaki : tbPerempuan;
      case 'LK':
        return isLakiLaki ? lkLaki : lkPerempuan;
      default:
        return null;
    }
  }
}
