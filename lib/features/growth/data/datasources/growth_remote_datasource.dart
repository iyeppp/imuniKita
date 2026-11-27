import 'package:cloud_firestore/cloud_firestore.dart';

import '../mappers/growth_record_mapper.dart';
import '../models/growth_record_model.dart';

/// Kontrak remote datasource rekam pertumbuhan anak.
abstract class GrowthRemoteDatasource {
  Future<List<GrowthRecordModel>> getRecords(String uid, String babyId);
  Future<void> upsert(String uid, String babyId, GrowthRecordModel record);
  Future<void> delete(String uid, String babyId, String recordId);
}

/// Implementasi Firebase Firestore untuk [GrowthRemoteDatasource].
class FirebaseGrowthRemoteDatasource implements GrowthRemoteDatasource {
  FirebaseGrowthRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid, String babyId) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('babies')
          .doc(babyId)
          .collection('growthRecords');

  @override
  Future<List<GrowthRecordModel>> getRecords(String uid, String babyId) async {
    // Diurutkan berdasarkan tanggalPengukuran (lama -> baru)
    final snapshot = await _collection(uid, babyId)
        .orderBy('tanggalPengukuran', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => GrowthRecordMapper.fromFirestore(doc.data(), doc.id, babyId: babyId))
        .toList();
  }

  @override
  Future<void> upsert(String uid, String babyId, GrowthRecordModel record) async {
    await _collection(uid, babyId).doc(record.recordId).set(
          GrowthRecordMapper.toFirestore(record),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> delete(String uid, String babyId, String recordId) async {
    await _collection(uid, babyId).doc(recordId).delete();
  }
}

