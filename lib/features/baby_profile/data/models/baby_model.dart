import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/baby_entity.dart';

part 'baby_model.g.dart';

/// Model persistensi Hive CE untuk profil bayi.
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

  @HiveField(7)
  DateTime? updatedAt;

  BabyModel({
    required this.babyId,
    required this.userId,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.fotoProfilPath,
    required this.createdAt,
    this.updatedAt,
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
    updatedAt: updatedAt,
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
    updatedAt: entity.updatedAt,
  );
}
