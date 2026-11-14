import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/health_journal_model.dart';

/// Mapper dua arah antara [HealthJournalModel] dan dokumen Firestore.
///
/// Path Firestore: `users/{uid}/babies/{babyId}/healthJournals/{journalId}`.
class HealthJournalMapper {
  const HealthJournalMapper._();

  static const int currentSchemaVersion = 1;

  static Map<String, dynamic> toFirestore(
    HealthJournalModel model, {
    int schemaVersion = currentSchemaVersion,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'journalId': model.journalId,
      'babyId': model.babyId,
      'vaccineScheduleId': model.vaccineScheduleId,
      'tanggalCatatan': Timestamp.fromDate(model.tanggalCatatan),
      'isiCatatan': model.isiCatatan,
      'suhuTubuh': model.suhuTubuh,
      'gejala': List<String>.from(model.gejala),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(updatedAt ?? now),
      'schemaVersion': schemaVersion,
    };
  }

  static HealthJournalModel fromFirestore(
    Map<String, dynamic> data,
    String journalId, {
    String? babyId,
  }) {
    final tanggalRaw = data['tanggalCatatan'];
    final tanggal = tanggalRaw is Timestamp
        ? tanggalRaw.toDate()
        : (tanggalRaw is String
            ? DateTime.parse(tanggalRaw)
            : DateTime.now());

    final gejalaRaw = data['gejala'];
    final List<String> gejala = gejalaRaw is List
        ? gejalaRaw.map((e) => e.toString()).toList()
        : <String>[];

    return HealthJournalModel(
      journalId: (data['journalId'] as String?) ?? journalId,
      babyId: (data['babyId'] as String?) ?? (babyId ?? ''),
      vaccineScheduleId: data['vaccineScheduleId'] as String?,
      tanggalCatatan: tanggal,
      isiCatatan: (data['isiCatatan'] as String?) ?? '',
      suhuTubuh: (data['suhuTubuh'] as num?)?.toDouble(),
      gejala: gejala,
    );
  }
}

