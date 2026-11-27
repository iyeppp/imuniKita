import 'package:cloud_firestore/cloud_firestore.dart';

import '../mappers/health_journal_mapper.dart';
import '../models/health_journal_model.dart';

/// Kontrak remote datasource jurnal kesehatan & KIPI anak.
abstract class HealthJournalRemoteDatasource {
  Future<List<HealthJournalModel>> getJournals(
    String uid,
    String babyId, {
    String? vaccineScheduleId,
  });
  Future<void> upsert(String uid, String babyId, HealthJournalModel journal);
  Future<void> delete(String uid, String babyId, String journalId);
}

/// Implementasi Firebase Firestore untuk [HealthJournalRemoteDatasource].
class FirebaseHealthJournalRemoteDatasource implements HealthJournalRemoteDatasource {
  FirebaseHealthJournalRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid, String babyId) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('babies')
          .doc(babyId)
          .collection('healthJournals');

  @override
  Future<List<HealthJournalModel>> getJournals(
    String uid,
    String babyId, {
    String? vaccineScheduleId,
  }) async {
    Query<Map<String, dynamic>> query = _collection(uid, babyId);

    if (vaccineScheduleId != null && vaccineScheduleId.isNotEmpty) {
      query = query.where('vaccineScheduleId', isEqualTo: vaccineScheduleId);
    }

    // Urutkan berdasarkan tanggalCatatan (terbaru di atas)
    query = query.orderBy('tanggalCatatan', descending: true);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => HealthJournalMapper.fromFirestore(doc.data(), doc.id, babyId: babyId))
        .toList();
  }

  @override
  Future<void> upsert(String uid, String babyId, HealthJournalModel journal) async {
    await _collection(uid, babyId).doc(journal.journalId).set(
          HealthJournalMapper.toFirestore(journal),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> delete(String uid, String babyId, String journalId) async {
    await _collection(uid, babyId).doc(journalId).delete();
  }
}

