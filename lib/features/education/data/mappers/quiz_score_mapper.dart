import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quiz_score_model.dart';

/// Mapper dua arah antara [QuizScoreModel] dan dokumen Firestore.
class QuizScoreMapper {
  const QuizScoreMapper._();

  static const int currentSchemaVersion = 1;

  static Map<String, dynamic> toFirestore(
    QuizScoreModel model, {
    int schemaVersion = currentSchemaVersion,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'quizId': model.quizId,
      'skor': model.skor,
      'totalSoal': model.totalSoal,
      'tanggalPengerjaan': Timestamp.fromDate(model.tanggalPengerjaan),
      'attemptCount': model.attemptCount,
      'riwayatSkor': model.riwayatSkor != null
          ? List<int>.from(model.riwayatSkor!)
          : null,
      'updatedAt': Timestamp.fromDate(updatedAt ?? now),
      'schemaVersion': schemaVersion,
    };
  }

  static QuizScoreModel fromFirestore(
    Map<String, dynamic> data,
    String quizId,
  ) {
    final tanggalRaw = data['tanggalPengerjaan'];
    final tanggal = tanggalRaw is Timestamp
        ? tanggalRaw.toDate()
        : (tanggalRaw is String
            ? DateTime.parse(tanggalRaw)
            : DateTime.now());

    final riwayatRaw = data['riwayatSkor'];
    final List<int>? riwayat = riwayatRaw is List
        ? riwayatRaw.map((e) => (e as num).toInt()).toList()
        : null;

    return QuizScoreModel(
      quizId: (data['quizId'] as String?) ?? quizId,
      skor: (data['skor'] as num?)?.toInt() ?? 0,
      totalSoal: (data['totalSoal'] as num?)?.toInt() ?? 0,
      tanggalPengerjaan: tanggal,
      attemptCount: (data['attemptCount'] as num?)?.toInt(),
      riwayatSkor: riwayat,
    );
  }
}

