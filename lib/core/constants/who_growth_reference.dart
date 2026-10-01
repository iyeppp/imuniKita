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
    this.startMonth = 0,
  });

  /// Label metrik, mis. "Berat Badan".
  final String label;
  final String unit;

  /// Bulan awal seri ini (default 0 untuk 0–24 bulan, 24 untuk >24 bulan).
  final int startMonth;

  /// Nilai per bulan (indeks 0 = usia [startMonth] bulan).
  final List<double> median;
  final List<double> minus2Sd;
  final List<double> plus2Sd;

  /// Usia tertinggi yang didukung tabel (bulan).
  int get maxMonth => startMonth + median.length - 1;

  /// Interpolasi linear nilai [seri] pada [bulan]. `null` bila di luar rentang.
  static double? _interpolate(
    List<double> seri,
    double bulan,
    int startMonth,
  ) {
    final rel = bulan - startMonth;
    if (rel < 0 || rel > seri.length - 1) return null;
    final bawah = rel.floor();
    final atas = rel.ceil();
    if (bawah == atas) return seri[bawah];
    final rasio = rel - bawah;
    return seri[bawah] + (seri[atas] - seri[bawah]) * rasio;
  }

  double? medianAt(double bulan) => _interpolate(median, bulan, startMonth);
  double? minus2SdAt(double bulan) =>
      _interpolate(minus2Sd, bulan, startMonth);
  double? plus2SdAt(double bulan) =>
      _interpolate(plus2Sd, bulan, startMonth);
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

  // ── Standar WHO Anak > 24 Bulan (24–60 bulan / 2–5 tahun) ───────────────

  // Berat badan > 24 bulan (kg)
  static const WhoSeries bbLakiOver24 = WhoSeries(
    label: 'Berat Badan',
    unit: 'kg',
    startMonth: 24,
    median: [
      12.2, 12.4, 12.5, 12.7, 12.9, 13.1, 13.3, 13.5, 13.7, 13.8, //
      14.0, 14.2, 14.3, 14.5, 14.7, 14.8, 15.0, 15.2, 15.3, 15.5, //
      15.7, 15.8, 16.0, 16.2, 16.3, 16.5, 16.7, 16.8, 17.0, 17.2, //
      17.3, 17.5, 17.7, 17.9, 18.0, 18.2, 18.3,
    ],
    minus2Sd: [
      9.7, 9.8, 10.0, 10.1, 10.2, 10.4, 10.5, 10.7, 10.8, 10.9, //
      11.0, 11.2, 11.3, 11.4, 11.5, 11.6, 11.8, 11.9, 12.0, 12.1, //
      12.2, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9, 13.1, 13.2, 13.3, //
      13.4, 13.5, 13.7, 13.8, 13.9, 14.0, 14.1,
    ],
    plus2Sd: [
      15.3, 15.5, 15.8, 16.0, 16.3, 16.5, 16.8, 17.0, 17.3, 17.5, //
      17.8, 18.0, 18.3, 18.5, 18.8, 19.0, 19.3, 19.5, 19.8, 20.1, //
      20.3, 20.6, 20.9, 21.1, 21.4, 21.7, 22.0, 22.2, 22.5, 22.8, //
      23.1, 23.4, 23.7, 24.0, 24.3, 24.6, 24.9,
    ],
  );

  static const WhoSeries bbPerempuanOver24 = WhoSeries(
    label: 'Berat Badan',
    unit: 'kg',
    startMonth: 24,
    median: [
      11.5, 11.7, 11.9, 12.1, 12.3, 12.5, 12.7, 12.9, 13.1, 13.3, //
      13.5, 13.7, 13.9, 14.0, 14.2, 14.4, 14.6, 14.8, 15.0, 15.2, //
      15.3, 15.5, 15.7, 15.9, 16.1, 16.3, 16.4, 16.6, 16.8, 17.0, //
      17.2, 17.4, 17.6, 17.8, 18.0, 18.2, 18.4,
    ],
    minus2Sd: [
      9.0, 9.2, 9.3, 9.4, 9.6, 9.7, 9.8, 10.0, 10.1, 10.2, //
      10.4, 10.5, 10.7, 10.8, 10.9, 11.1, 11.2, 11.3, 11.5, 11.6, //
      11.7, 11.8, 12.0, 12.1, 12.2, 12.4, 12.5, 12.6, 12.7, 12.9, //
      13.0, 13.1, 13.3, 13.4, 13.5, 13.7, 13.8,
    ],
    plus2Sd: [
      14.8, 15.1, 15.4, 15.7, 16.0, 16.3, 16.6, 16.9, 17.2, 17.5, //
      17.8, 18.1, 18.4, 18.7, 19.0, 19.3, 19.6, 19.9, 20.2, 20.6, //
      20.9, 21.2, 21.5, 21.9, 22.2, 22.6, 22.9, 23.3, 23.6, 24.0, //
      24.4, 24.8, 25.1, 25.5, 25.9, 26.3, 26.7,
    ],
  );

  // Tinggi/panjang badan > 24 bulan (cm)
  static const WhoSeries tbLakiOver24 = WhoSeries(
    label: 'Tinggi Badan',
    unit: 'cm',
    startMonth: 24,
    median: [
      87.8, 88.8, 89.6, 90.5, 91.3, 92.1, 92.9, 93.6, 94.4, 95.1, //
      95.8, 96.5, 97.2, 97.9, 98.6, 99.2, 99.9, 100.5, 101.2, 101.8, //
      102.4, 103.0, 103.6, 104.2, 104.8, 105.4, 106.0, 106.5, 107.1, 107.7, //
      108.2, 108.8, 109.3, 109.9, 110.4, 110.9, 111.5,
    ],
    minus2Sd: [
      81.7, 82.5, 83.3, 84.1, 84.9, 85.6, 86.3, 87.0, 87.7, 88.4, //
      89.0, 89.7, 90.3, 90.9, 91.5, 92.1, 92.7, 93.3, 93.9, 94.5, //
      95.0, 95.6, 96.1, 96.7, 97.2, 97.7, 98.2, 98.7, 99.2, 99.7, //
      100.2, 100.7, 101.2, 101.7, 102.1, 102.6, 103.1,
    ],
    plus2Sd: [
      93.9, 95.0, 95.9, 96.9, 97.8, 98.7, 99.5, 100.3, 101.1, 101.9, //
      102.7, 103.4, 104.2, 104.9, 105.7, 106.4, 107.1, 107.8, 108.5, 109.2, //
      109.9, 110.5, 111.2, 111.8, 112.5, 113.1, 113.7, 114.4, 115.0, 115.6, //
      116.2, 116.8, 117.4, 118.0, 118.6, 119.2, 119.8,
    ],
  );

  static const WhoSeries tbPerempuanOver24 = WhoSeries(
    label: 'Tinggi Badan',
    unit: 'cm',
    startMonth: 24,
    median: [
      86.4, 87.5, 88.4, 89.3, 90.1, 91.0, 91.8, 92.5, 93.3, 94.0, //
      94.7, 95.4, 96.1, 96.8, 97.4, 98.1, 98.7, 99.4, 100.0, 100.6, //
      101.2, 101.8, 102.4, 103.0, 103.6, 104.2, 104.7, 105.3, 105.8, 106.4, //
      106.9, 107.4, 108.0, 108.5, 109.0, 109.5, 110.0,
    ],
    minus2Sd: [
      80.0, 81.0, 81.8, 82.6, 83.4, 84.2, 84.9, 85.6, 86.3, 87.0, //
      87.6, 88.3, 88.9, 89.5, 90.1, 90.7, 91.3, 91.9, 92.4, 93.0, //
      93.5, 94.1, 94.6, 95.1, 95.6, 96.1, 96.6, 97.1, 97.6, 98.1, //
      98.5, 99.0, 99.5, 99.9, 100.4, 100.8, 101.3,
    ],
    plus2Sd: [
      92.9, 94.0, 95.0, 96.0, 96.9, 97.8, 98.6, 99.4, 100.2, 101.0, //
      101.8, 102.5, 103.3, 104.0, 104.8, 105.5, 106.2, 106.9, 107.6, 108.2, //
      108.9, 109.6, 110.2, 110.8, 111.5, 112.1, 112.7, 113.3, 114.0, 114.6, //
      115.2, 115.8, 116.4, 117.0, 117.6, 118.2, 118.8,
    ],
  );

  // Lingkar kepala > 24 bulan (cm)
  static const WhoSeries lkLakiOver24 = WhoSeries(
    label: 'Lingkar Kepala',
    unit: 'cm',
    startMonth: 24,
    median: [
      48.3, 48.4, 48.5, 48.6, 48.7, 48.8, 48.9, 49.0, 49.1, 49.2, //
      49.3, 49.4, 49.5, 49.5, 49.6, 49.7, 49.8, 49.8, 49.9, 50.0, //
      50.0, 50.1, 50.1, 50.2, 50.2, 50.3, 50.3, 50.4, 50.4, 50.5, //
      50.5, 50.6, 50.6, 50.7, 50.7, 50.7, 50.8,
    ],
    minus2Sd: [
      45.8, 45.9, 46.0, 46.1, 46.2, 46.3, 46.4, 46.5, 46.6, 46.7, //
      46.7, 46.8, 46.9, 47.0, 47.0, 47.1, 47.2, 47.2, 47.3, 47.3, //
      47.4, 47.4, 47.5, 47.5, 47.6, 47.6, 47.7, 47.7, 47.7, 47.8, //
      47.8, 47.8, 47.9, 47.9, 47.9, 48.0, 48.0,
    ],
    plus2Sd: [
      50.9, 51.0, 51.1, 51.2, 51.3, 51.4, 51.5, 51.6, 51.7, 51.8, //
      51.8, 51.9, 52.0, 52.1, 52.1, 52.2, 52.3, 52.3, 52.4, 52.5, //
      52.5, 52.6, 52.6, 52.7, 52.7, 52.8, 52.8, 52.9, 52.9, 53.0, //
      53.0, 53.0, 53.1, 53.1, 53.1, 53.2, 53.2,
    ],
  );

  static const WhoSeries lkPerempuanOver24 = WhoSeries(
    label: 'Lingkar Kepala',
    unit: 'cm',
    startMonth: 24,
    median: [
      47.2, 47.3, 47.4, 47.5, 47.6, 47.7, 47.8, 47.9, 48.0, 48.1, //
      48.2, 48.3, 48.4, 48.4, 48.5, 48.6, 48.6, 48.7, 48.8, 48.8, //
      48.9, 48.9, 49.0, 49.0, 49.1, 49.1, 49.2, 49.2, 49.3, 49.3, //
      49.4, 49.4, 49.5, 49.5, 49.5, 49.6, 49.6,
    ],
    minus2Sd: [
      44.3, 44.4, 44.5, 44.6, 44.7, 44.8, 44.9, 45.0, 45.1, 45.1, //
      45.2, 45.3, 45.4, 45.4, 45.5, 45.5, 45.6, 45.6, 45.7, 45.7, //
      45.8, 45.8, 45.9, 45.9, 45.9, 46.0, 46.0, 46.1, 46.1, 46.1, //
      46.2, 46.2, 46.2, 46.3, 46.3, 46.3, 46.4,
    ],
    plus2Sd: [
      49.6, 49.7, 49.8, 50.0, 50.1, 50.2, 50.3, 50.4, 50.5, 50.6, //
      50.7, 50.8, 50.9, 50.9, 51.0, 51.1, 51.1, 51.2, 51.3, 51.3, //
      51.4, 51.4, 51.5, 51.5, 51.6, 51.6, 51.7, 51.7, 51.8, 51.8, //
      51.8, 51.9, 51.9, 52.0, 52.0, 52.0, 52.1,
    ],
  );

  /// Mode grafik di `GrowthChartScreen` → seri WHO yang sesuai.
  ///
  /// [isLakiLaki] menentukan tabel yang dipakai (standar WHO dipisah per jenis
  /// kelamin). Bila [over24] bernilai true, mengembalikan standar WHO untuk usia
  /// > 24 bulan (24–60 bulan).
  static WhoSeries? forMode(
    String mode, {
    required bool isLakiLaki,
    bool over24 = false,
  }) {
    if (over24) {
      switch (mode) {
        case 'BB':
          return isLakiLaki ? bbLakiOver24 : bbPerempuanOver24;
        case 'TB':
          return isLakiLaki ? tbLakiOver24 : tbPerempuanOver24;
        case 'LK':
          return isLakiLaki ? lkLakiOver24 : lkPerempuanOver24;
        default:
          return null;
      }
    }
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
