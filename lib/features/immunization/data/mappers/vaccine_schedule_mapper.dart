import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vaccine_schedule_model.dart';

/// Mapper dua arah antara [VaccineScheduleModel] dan dokumen Firestore.
class VaccineScheduleMapper {
  const VaccineScheduleMapper._();

  static const int currentSchemaVersion = 1;

  static Map<String, dynamic> toFirestore(
    VaccineScheduleModel model, {
    int schemaVersion = currentSchemaVersion,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'scheduleId': model.scheduleId,
      'babyId': model.babyId,
      'namaVaksin': model.namaVaksin,
      'deskripsi': model.deskripsi,
      'usiaBulanTarget': model.usiaBulanTarget,
      'tanggalTarget': Timestamp.fromDate(model.tanggalTarget),
      'status': model.status,
      'tanggalRealisasi': model.tanggalRealisasi != null
          ? Timestamp.fromDate(model.tanggalRealisasi!)
          : null,
      'catatanReaksi': model.catatanReaksi,
      'updatedAt': Timestamp.fromDate(updatedAt ?? now),
      'schemaVersion': schemaVersion,
    };
  }

  static VaccineScheduleModel fromFirestore(
    Map<String, dynamic> data,
    String scheduleId, {
    String? babyId,
  }) {
    final tanggalTargetRaw = data['tanggalTarget'];
    final tanggalTarget = tanggalTargetRaw is Timestamp
        ? tanggalTargetRaw.toDate()
        : (tanggalTargetRaw is String
            ? DateTime.parse(tanggalTargetRaw)
            : DateTime.now());

    final tanggalRealisasiRaw = data['tanggalRealisasi'];
    final tanggalRealisasi = tanggalRealisasiRaw is Timestamp
        ? tanggalRealisasiRaw.toDate()
        : (tanggalRealisasiRaw is String
            ? DateTime.parse(tanggalRealisasiRaw)
            : null);

    return VaccineScheduleModel(
      scheduleId: (data['scheduleId'] as String?) ?? scheduleId,
      babyId: (data['babyId'] as String?) ?? (babyId ?? ''),
      namaVaksin: (data['namaVaksin'] as String?) ?? '',
      deskripsi: (data['deskripsi'] as String?) ?? '',
      usiaBulanTarget: (data['usiaBulanTarget'] as num?)?.toInt() ?? 0,
      tanggalTarget: tanggalTarget,
      status: (data['status'] as String?) ?? 'BELUM',
      tanggalRealisasi: tanggalRealisasi,
      catatanReaksi: data['catatanReaksi'] as String?,
      reminderH7Sent: false, // lokal per perangkat
      reminderH1Sent: false, // lokal per perangkat
    );
  }
}

