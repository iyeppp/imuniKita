import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/growth_record_model.dart';

/// Mapper dua arah antara [GrowthRecordModel] dan dokumen Firestore.
class GrowthRecordMapper {
  const GrowthRecordMapper._();

  static const int currentSchemaVersion = 1;

  static Map<String, dynamic> toFirestore(
    GrowthRecordModel model, {
    int schemaVersion = currentSchemaVersion,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'recordId': model.recordId,
      'babyId': model.babyId,
      'tanggalPengukuran': Timestamp.fromDate(model.tanggalPengukuran),
      'beratBadan': model.beratBadan,
      'tinggiBadan': model.tinggiBadan,
      'lingkarKepala': model.lingkarKepala,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(updatedAt ?? now),
      'schemaVersion': schemaVersion,
    };
  }

  static GrowthRecordModel fromFirestore(
    Map<String, dynamic> data,
    String recordId, {
    String? babyId,
  }) {
    final tanggalRaw = data['tanggalPengukuran'];
    final tanggal = tanggalRaw is Timestamp
        ? tanggalRaw.toDate()
        : (tanggalRaw is String
            ? DateTime.parse(tanggalRaw)
            : DateTime.now());

    return GrowthRecordModel(
      recordId: (data['recordId'] as String?) ?? recordId,
      babyId: (data['babyId'] as String?) ?? (babyId ?? ''),
      tanggalPengukuran: tanggal,
      beratBadan: (data['beratBadan'] as num?)?.toDouble() ?? 0.0,
      tinggiBadan: (data['tinggiBadan'] as num?)?.toDouble() ?? 0.0,
      lingkarKepala: (data['lingkarKepala'] as num?)?.toDouble(),
    );
  }
}

