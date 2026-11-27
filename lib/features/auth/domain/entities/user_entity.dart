/// Entity domain — akun pengguna ImuniKita.
class UserEntity {
  const UserEntity({
    required this.localId,
    required this.namaLengkap,
    required this.email,
    required this.nomorTelepon,
    this.lokasiKota,
    required this.createdAt,
  });

  final String localId;
  final String namaLengkap;
  final String email;
  final String nomorTelepon;
  final String? lokasiKota;
  final DateTime createdAt;

  UserEntity copyWith({
    String? namaLengkap,
    String? email,
    String? nomorTelepon,
    String? lokasiKota,
  }) {
    return UserEntity(
      localId: localId,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      lokasiKota: lokasiKota ?? this.lokasiKota,
      createdAt: createdAt,
    );
  }
}
