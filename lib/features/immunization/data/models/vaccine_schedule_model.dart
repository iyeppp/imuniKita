import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/vaccine_schedule_entity.dart';

part 'vaccine_schedule_model.g.dart';

/// Model persistensi Hive CE untuk satu baris jadwal imunisasi.
///
/// `typeId: 2` — mengikuti dev plan §3.1 "VaccineScheduleModel". Jangan
/// dipakai ulang: `UserModel` = 0, `BabyModel` = 1.
@HiveType(typeId: 2)
class VaccineScheduleModel extends HiveObject {
  @HiveField(0)
  late String scheduleId;

  @HiveField(1)
  late String babyId;

  @HiveField(2)
  late String namaVaksin;

  @HiveField(3)
  late String deskripsi;

  @HiveField(4)
  late int usiaBulanTarget;

  @HiveField(5)
  late DateTime tanggalTarget;

  @HiveField(6)
  late String status;

  @HiveField(7)
  DateTime? tanggalRealisasi;

  @HiveField(8)
  String? catatanReaksi;

  @HiveField(9)
  bool reminderH7Sent;

  @HiveField(10)
  bool reminderH1Sent;

  VaccineScheduleModel({
    required this.scheduleId,
    required this.babyId,
    required this.namaVaksin,
    required this.deskripsi,
    required this.usiaBulanTarget,
    required this.tanggalTarget,
    required this.status,
    this.tanggalRealisasi,
    this.catatanReaksi,
    this.reminderH7Sent = false,
    this.reminderH1Sent = false,
  });

  VaccineScheduleEntity toEntity() => VaccineScheduleEntity(
    scheduleId: scheduleId,
    babyId: babyId,
    namaVaksin: namaVaksin,
    deskripsi: deskripsi,
    usiaBulanTarget: usiaBulanTarget,
    tanggalTarget: tanggalTarget,
    status: status,
    tanggalRealisasi: tanggalRealisasi,
    catatanReaksi: catatanReaksi,
    reminderH7Sent: reminderH7Sent,
    reminderH1Sent: reminderH1Sent,
  );

  factory VaccineScheduleModel.fromEntity(VaccineScheduleEntity entity) =>
      VaccineScheduleModel(
        scheduleId: entity.scheduleId,
        babyId: entity.babyId,
        namaVaksin: entity.namaVaksin,
        deskripsi: entity.deskripsi,
        usiaBulanTarget: entity.usiaBulanTarget,
        tanggalTarget: entity.tanggalTarget,
        status: entity.status,
        tanggalRealisasi: entity.tanggalRealisasi,
        catatanReaksi: entity.catatanReaksi,
        reminderH7Sent: entity.reminderH7Sent,
        reminderH1Sent: entity.reminderH1Sent,
      );
}
