import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/baby_entity.dart';
import '../models/baby_model.dart';

/// Mapper dua arah antara [BabyModel] dan dokumen Firestore.
///
/// Path Firestore: `users/{uid}/babies/{babyId}`.
/// Sesuai aturan B4-2 & ADR 0001: `fotoProfilPath` TIDAK disimpan di cloud
/// (foto hanya lokal per perangkat).
class BabyMapper {
  const BabyMapper._();

  static const int currentSchemaVersion = 1;

  /// Ubah nilai internal jenis kelamin ('L' / 'P') menjadi format Firestore
  /// ('Laki-laki' / 'Perempuan') sesuai validasi `validBaby` di firestore.rules.
  static String genderToFirestore(String gender) {
    if (gender == BabyGender.laki || gender == 'Laki-laki') {
      return 'Laki-laki';
    }
    return 'Perempuan';
  }

  /// Ubah format Firestore ('Laki-laki' / 'Perempuan') kembali ke kode
  /// internal domain [BabyGender.laki] ('L') atau [BabyGender.perempuan] ('P').
  static String genderFromFirestore(String gender) {
    if (gender == 'Laki-laki' || gender == BabyGender.laki) {
      return BabyGender.laki;
    }
    return BabyGender.perempuan;
  }

  /// Serialisasi [BabyModel] ke format dokumen Firestore (Map).
  static Map<String, dynamic> toFirestore(
    BabyModel model, {
    int schemaVersion = currentSchemaVersion,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'babyId': model.babyId,
      'userId': model.userId,
      'namaAnak': model.namaAnak,
      'tanggalLahir': Timestamp.fromDate(model.tanggalLahir),
      'jenisKelamin': genderToFirestore(model.jenisKelamin),
      'createdAt': Timestamp.fromDate(model.createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? now),
      'schemaVersion': schemaVersion,
    };
  }

  /// Deserialisasi Map Firestore ke [BabyModel].
  ///
  /// [babyId] dan [userId] fallback ke parameter bila tidak ada dalam data.
  static BabyModel fromFirestore(
    Map<String, dynamic> data,
    String babyId, {
    String? userId,
  }) {
    final tanggalLahirRaw = data['tanggalLahir'];
    final createdAtRaw = data['createdAt'];

    final tanggalLahir = tanggalLahirRaw is Timestamp
        ? tanggalLahirRaw.toDate()
        : (tanggalLahirRaw is String
            ? DateTime.parse(tanggalLahirRaw)
            : DateTime.now());

    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : (createdAtRaw is String
            ? DateTime.parse(createdAtRaw)
            : DateTime.now());

    final rawGender = (data['jenisKelamin'] ?? BabyGender.laki).toString();

    return BabyModel(
      babyId: (data['babyId'] as String?) ?? babyId,
      userId: (data['userId'] as String?) ?? (userId ?? ''),
      namaAnak: (data['namaAnak'] as String?) ?? '',
      tanggalLahir: tanggalLahir,
      jenisKelamin: genderFromFirestore(rawGender),
      fotoProfilPath: null, // foto profil tidak disinkronkan ke cloud
      createdAt: createdAt,
    );
  }
}

