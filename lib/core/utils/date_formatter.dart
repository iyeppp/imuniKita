/// Format tanggal berbahasa Indonesia.
abstract class DateFormatter {
  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// `17 September 2026`
  static String formatLong(DateTime date) =>
      '${date.day} ${_bulan[date.month - 1]} ${date.year}';
}
