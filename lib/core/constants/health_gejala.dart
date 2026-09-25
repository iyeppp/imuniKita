/// Daftar gejala KIPI/jurnal yang bisa dipilih user — satu sumber kebenaran.
///
/// Sebelumnya daftar ini ditulis terpisah di `add_journal_screen.dart` dan
/// `vaccine_detail_screen.dart` dengan isi yang berbeda (Temuan #47), sehingga
/// gejala pasca-vaksinasi tidak konsisten antar layar.
abstract class HealthGejala {
  static const List<String> daftar = [
    'Demam',
    'Bengkak Bekas Suntik',
    'Rewel',
    'Muntah',
    'Ruam Kulit',
    'Batuk Pilek',
  ];
}
