import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/growth_record_entity.dart';

part 'growth_record_model.g.dart';

@HiveType(typeId: 3)
class GrowthRecordModel extends HiveObject {
  @HiveField(0)
  late String recordId;

  @HiveField(1)
  late String babyId;

  @HiveField(2)
  late DateTime tanggalPengukuran;

  @HiveField(3)
  late double beratBadan; // kg

  @HiveField(4)
  late double tinggiBadan; // cm

  @HiveField(5)
  double? lingkarKepala; // cm

  GrowthRecordModel({
    required this.recordId,
    required this.babyId,
    required this.tanggalPengukuran,
    required this.beratBadan,
    required this.tinggiBadan,
    this.lingkarKepala,
  });

  /// Konversi ke entity domain (dipakai repository saat membaca dari Hive).
  GrowthRecordEntity toEntity() => GrowthRecordEntity(
    recordId: recordId,
    babyId: babyId,
    tanggalPengukuran: tanggalPengukuran,
    beratBadan: beratBadan,
    tinggiBadan: tinggiBadan,
    lingkarKepala: lingkarKepala,
  );

  /// Konversi dari entity domain (dipakai repository saat menulis ke Hive).
  factory GrowthRecordModel.fromEntity(GrowthRecordEntity entity) =>
      GrowthRecordModel(
        recordId: entity.recordId,
        babyId: entity.babyId,
        tanggalPengukuran: entity.tanggalPengukuran,
        beratBadan: entity.beratBadan,
        tinggiBadan: entity.tinggiBadan,
        lingkarKepala: entity.lingkarKepala,
      );
}
