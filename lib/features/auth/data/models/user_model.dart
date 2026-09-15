import 'package:hive_ce/hive_ce.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String localId;

  @HiveField(1)
  late String namaLengkap;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late String nomorTelepon;

  @HiveField(4)
  String? lokasiKota;

  @HiveField(5)
  late DateTime createdAt;

  UserModel({
    required this.localId,
    required this.namaLengkap,
    required this.email,
    required this.nomorTelepon,
    this.lokasiKota,
    required this.createdAt,
  });
}
