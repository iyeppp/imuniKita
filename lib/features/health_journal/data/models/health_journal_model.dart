import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/health_journal_entity.dart';

part 'health_journal_model.g.dart';

@HiveType(typeId: 4)
class HealthJournalModel extends HiveObject {
  @HiveField(0)
  late String journalId;

  @HiveField(1)
  late String babyId;

  @HiveField(2)
  String? vaccineScheduleId;

  @HiveField(3)
  late DateTime tanggalCatatan;

  @HiveField(4)
  late String isiCatatan;

  @HiveField(5)
  double? suhuTubuh;

  @HiveField(6)
  late List<String> gejala;

  HealthJournalModel({
    required this.journalId,
    required this.babyId,
    this.vaccineScheduleId,
    required this.tanggalCatatan,
    required this.isiCatatan,
    this.suhuTubuh,
    required this.gejala,
  });

  /// Konversi ke entity domain (dipakai repository saat membaca dari Hive).
  HealthJournalEntity toEntity() => HealthJournalEntity(
    journalId: journalId,
    babyId: babyId,
    vaccineScheduleId: vaccineScheduleId,
    tanggalCatatan: tanggalCatatan,
    isiCatatan: isiCatatan,
    suhuTubuh: suhuTubuh,
    gejala: List.unmodifiable(gejala),
  );

  /// Konversi dari entity domain (dipakai repository saat menulis ke Hive).
  factory HealthJournalModel.fromEntity(HealthJournalEntity entity) =>
      HealthJournalModel(
        journalId: entity.journalId,
        babyId: entity.babyId,
        vaccineScheduleId: entity.vaccineScheduleId,
        tanggalCatatan: entity.tanggalCatatan,
        isiCatatan: entity.isiCatatan,
        suhuTubuh: entity.suhuTubuh,
        gejala: List.from(entity.gejala),
      );
}
