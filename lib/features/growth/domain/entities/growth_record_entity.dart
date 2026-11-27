/// Entity domain — satu rekam pengukuran pertumbuhan bayi.
class GrowthRecordEntity {
  const GrowthRecordEntity({
    required this.recordId,
    required this.babyId,
    required this.tanggalPengukuran,
    required this.beratBadan,
    required this.tinggiBadan,
    this.lingkarKepala,
    this.updatedAt,
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

  final DateTime? updatedAt;

  GrowthRecordEntity copyWith({
    DateTime? tanggalPengukuran,
    double? beratBadan,
    double? tinggiBadan,
    double? lingkarKepala,
    DateTime? updatedAt,
  }) {
    return GrowthRecordEntity(
      recordId: recordId,
      babyId: babyId,
      tanggalPengukuran: tanggalPengukuran ?? this.tanggalPengukuran,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      lingkarKepala: lingkarKepala ?? this.lingkarKepala,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
