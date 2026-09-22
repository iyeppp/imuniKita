import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/baby_entity.dart';

part 'baby_model.g.dart';

/// Model persistensi Hive CE untuk profil bayi.
///
/// `typeId: 1` — jangan dipakai ulang untuk model lain (lihat `UserModel`
/// yang memakai `typeId: 0`). Skema mengikuti dev plan §3.1 "BabyModel".
@HiveType(typeId: 1)
class BabyModel extends HiveObject {
  @HiveField(0)
  late String babyId;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String namaAnak;

  @HiveField(3)
  late DateTime tanggalLahir;

  @HiveField(4)
  late String jenisKelamin;

  @HiveField(5)
  String? fotoProfilPath;

  @HiveField(6)
  late DateTime createdAt;

  BabyModel({
    required this.babyId,
    required this.userId,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.fotoProfilPath,
    required this.createdAt,
  });

  /// Konversi ke entity domain (dipakai repository saat membaca dari Hive).
  BabyEntity toEntity() => BabyEntity(
    babyId: babyId,
    userId: userId,
    namaAnak: namaAnak,
    tanggalLahir: tanggalLahir,
    jenisKelamin: jenisKelamin,
    fotoProfilPath: fotoProfilPath,
    createdAt: createdAt,
  );

  /// Konversi dari entity domain (dipakai repository saat menulis ke Hive).
  factory BabyModel.fromEntity(BabyEntity entity) => BabyModel(
    babyId: entity.babyId,
    userId: entity.userId,
    namaAnak: entity.namaAnak,
    tanggalLahir: entity.tanggalLahir,
    jenisKelamin: entity.jenisKelamin,
    fotoProfilPath: entity.fotoProfilPath,
    createdAt: entity.createdAt,
  );
}
