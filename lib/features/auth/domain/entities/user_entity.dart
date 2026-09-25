/// Entity domain — akun pengguna ImuniKita.
///
/// Bebas dari Hive CE (`UserModel` hanya dipakai di lapisan data), sehingga
/// logika auth tidak berubah saat data source di-swap ke Firebase Auth pada
/// fase UAS (dev plan §6.1).
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
