import 'package:hive_ce/hive_ce.dart';

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
}
