/// Data master jadwal imunisasi nasional (hardcoded, offline).
///
/// Dipakai `GenerateScheduleUseCase` untuk membangun seluruh
/// `VaccineScheduleEntity` bayi begitu profilnya disimpan. Nilai
/// [VaccineMasterItem.usiaBulan] dipetakan lewat `AgeCalculator.addMonths`
/// dari tanggal lahir bayi untuk mendapatkan `tanggalTarget`.
library;

/// Satu baris jadwal imunisasi nasional.
class VaccineMasterItem {
  const VaccineMasterItem({
    required this.nama,
    required this.usiaBulan,
    required this.dosis,
    required this.deskripsi,
  });

  /// Nama vaksin, mis. `BCG`, `DPT-HB-Hib 1`, `MR`.
  final String nama;

  /// Usia target pemberian dalam bulan (0 = segera setelah lahir).
  final int usiaBulan;

  /// Dosis ke-berapa untuk jenis vaksin ini.
  final int dosis;

  /// Penjelasan singkat untuk halaman detail vaksin.
  final String deskripsi;
}

/// Registry jadwal imunisasi nasional.
abstract class VaccineMaster {
  /// Urutan vaksin sesuai jadwal dasar Kemenkes/IDAI.
  static const List<VaccineMasterItem> jadwalNasional = [
    VaccineMasterItem(
      nama: 'HB0',
      usiaBulan: 0,
      dosis: 1,
      deskripsi:
          'Hepatitis B dosis pertama, diberikan sesegera mungkin setelah lahir',
    ),
    VaccineMasterItem(
      nama: 'Polio 0',
      usiaBulan: 0,
      dosis: 1,
      deskripsi: 'Polio tetes pertama saat lahir',
    ),
    VaccineMasterItem(
      nama: 'BCG',
      usiaBulan: 1,
      dosis: 1,
      deskripsi: 'Perlindungan terhadap Tuberkulosis (TBC)',
    ),
    VaccineMasterItem(
      nama: 'DPT-HB-Hib 1',
      usiaBulan: 2,
      dosis: 1,
      deskripsi: 'Difteri, Pertusis, Tetanus, Hepatitis B, dan Hib',
    ),
    VaccineMasterItem(
      nama: 'Polio 1',
      usiaBulan: 2,
      dosis: 1,
      deskripsi: 'Polio tetes kedua',
    ),
    VaccineMasterItem(
      nama: 'DPT-HB-Hib 2',
      usiaBulan: 3,
      dosis: 2,
      deskripsi: 'Dosis kedua DPT-HB-Hib',
    ),
    VaccineMasterItem(
      nama: 'Polio 2',
      usiaBulan: 3,
      dosis: 1,
      deskripsi: 'Polio tetes ketiga',
    ),
    VaccineMasterItem(
      nama: 'DPT-HB-Hib 3',
      usiaBulan: 4,
      dosis: 3,
      deskripsi: 'Dosis ketiga DPT-HB-Hib',
    ),
    VaccineMasterItem(
      nama: 'Polio 3',
      usiaBulan: 4,
      dosis: 1,
      deskripsi: 'Polio tetes keempat',
    ),
    VaccineMasterItem(
      nama: 'IPV',
      usiaBulan: 4,
      dosis: 1,
      deskripsi: 'Inactivated Polio Vaccine (Polio suntik)',
    ),
    VaccineMasterItem(
      nama: 'MR',
      usiaBulan: 9,
      dosis: 1,
      deskripsi: 'Measles-Rubella (Campak dan Rubella)',
    ),
    VaccineMasterItem(
      nama: 'DPT-HB-Hib 4',
      usiaBulan: 18,
      dosis: 4,
      deskripsi: 'Booster DPT',
    ),
    VaccineMasterItem(
      nama: 'MR Booster',
      usiaBulan: 18,
      dosis: 2,
      deskripsi: 'Booster Campak-Rubella',
    ),
  ];
}
