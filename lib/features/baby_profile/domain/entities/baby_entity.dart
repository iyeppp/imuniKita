/// Nilai valid untuk `BabyEntity.jenisKelamin`.
abstract class BabyGender {
  static const String laki = 'L';
  static const String perempuan = 'P';
}

/// Entity domain — representasi profil bayi tanpa dependency ke Hive CE.
///
/// Lapisan domain (use case, repository interface) hanya bergantung pada
/// class ini, bukan pada `BabyModel`. Ini membuat logika bisnis tetap sama
/// saat data source di-swap dari Hive CE (UTS) ke Firestore (UAS).
class BabyEntity {
  const BabyEntity({
    required this.babyId,
    required this.userId,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.fotoProfilPath,
    required this.createdAt,
  });

  /// UUID lokal bayi.
  final String babyId;

  /// FK ke `UserModel.localId` — pemilik/orang tua bayi.
  final String userId;

  final String namaAnak;
  final DateTime tanggalLahir;

  /// `BabyGender.laki` ('L') atau `BabyGender.perempuan` ('P').
  final String jenisKelamin;

  /// Path lokal ke file foto di galeri perangkat (opsional).
  final String? fotoProfilPath;

  final DateTime createdAt;

  BabyEntity copyWith({
    String? namaAnak,
    DateTime? tanggalLahir,
    String? jenisKelamin,
    String? fotoProfilPath,
    // Temuan #37: flag eksplisit agar foto profil bisa dihapus (di-set null).
    bool clearFotoProfilPath = false,
  }) {
    return BabyEntity(
      babyId: babyId,
      userId: userId,
      namaAnak: namaAnak ?? this.namaAnak,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      fotoProfilPath: clearFotoProfilPath
          ? null
          : (fotoProfilPath ?? this.fotoProfilPath),
      createdAt: createdAt,
    );
  }
}
