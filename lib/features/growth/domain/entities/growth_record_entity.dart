/// Entity domain — satu rekam pengukuran pertumbuhan bayi.
///
/// Bebas dari Hive CE (`GrowthRecordModel` hanya dipakai di lapisan data),
/// sehingga logika bisnis tetap sama saat data source di-swap ke Firestore
/// (dev plan §6.1).
class GrowthRecordEntity {
  const GrowthRecordEntity({
    required this.recordId,
    required this.babyId,
    required this.tanggalPengukuran,
    required this.beratBadan,
    required this.tinggiBadan,
    this.lingkarKepala,
  });

  final String recordId;
  final String babyId;
  final DateTime tanggalPengukuran;

  /// Berat badan (kg).
  final double beratBadan;

  /// Tinggi/panjang badan (cm).
  final double tinggiBadan;

  /// Lingkar kepala (cm) — opsional.
  final double? lingkarKepala;

  GrowthRecordEntity copyWith({
    DateTime? tanggalPengukuran,
    double? beratBadan,
    double? tinggiBadan,
    double? lingkarKepala,
  }) {
    return GrowthRecordEntity(
      recordId: recordId,
      babyId: babyId,
      tanggalPengukuran: tanggalPengukuran ?? this.tanggalPengukuran,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      lingkarKepala: lingkarKepala ?? this.lingkarKepala,
    );
  }
}
