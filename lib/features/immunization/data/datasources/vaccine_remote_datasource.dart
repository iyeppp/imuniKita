import 'package:cloud_firestore/cloud_firestore.dart';

import '../mappers/vaccine_schedule_mapper.dart';
import '../models/vaccine_schedule_model.dart';

/// Kontrak remote datasource jadwal imunisasi bayi.
abstract class VaccineRemoteDatasource {
  Future<List<VaccineScheduleModel>> getSchedules(String uid, String babyId);
  Future<void> upsert(String uid, String babyId, VaccineScheduleModel schedule);
  Future<void> upsertBatch(String uid, String babyId, List<VaccineScheduleModel> schedules);
  Future<void> delete(String uid, String babyId, String scheduleId);
}

/// Implementasi Firebase Firestore untuk [VaccineRemoteDatasource].
///
/// Dokumen tersimpan di `users/{uid}/babies/{babyId}/vaccineSchedules/{scheduleId}`.
class FirebaseVaccineRemoteDatasource implements VaccineRemoteDatasource {
  FirebaseVaccineRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid, String babyId) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('babies')
          .doc(babyId)
          .collection('vaccineSchedules');

  @override
  Future<List<VaccineScheduleModel>> getSchedules(String uid, String babyId) async {
    final snapshot = await _collection(uid, babyId).get();
    return snapshot.docs
        .map((doc) => VaccineScheduleMapper.fromFirestore(doc.data(), doc.id, babyId: babyId))
        .toList();
  }

  @override
  Future<void> upsert(String uid, String babyId, VaccineScheduleModel schedule) async {
    await _collection(uid, babyId).doc(schedule.scheduleId).set(
          VaccineScheduleMapper.toFirestore(schedule),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> upsertBatch(String uid, String babyId, List<VaccineScheduleModel> schedules) async {
    if (schedules.isEmpty) return;

    // Firestore WriteBatch membatasi maksimal 500 operasi per commit
    const batchLimit = 500;
    final coll = _collection(uid, babyId);

    for (var i = 0; i < schedules.length; i += batchLimit) {
      final chunk = schedules.sublist(
        i,
        i + batchLimit > schedules.length ? schedules.length : i + batchLimit,
      );
      final batch = _firestore.batch();
      for (final schedule in chunk) {
        final docRef = coll.doc(schedule.scheduleId);
        batch.set(
          docRef,
          VaccineScheduleMapper.toFirestore(schedule),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }
  }

  @override
  Future<void> delete(String uid, String babyId, String scheduleId) async {
    await _collection(uid, babyId).doc(scheduleId).delete();
  }
}

