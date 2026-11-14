import 'package:cloud_firestore/cloud_firestore.dart';

import '../mappers/baby_mapper.dart';
import '../models/baby_model.dart';

/// Kontrak remote datasource profil bayi.
///
/// Disusun sebagai abstract class agar dapat di-fake di unit test tanpa koneksi SDK.
abstract class BabyRemoteDatasource {
  Future<List<BabyModel>> getAll(String uid);
  Future<BabyModel?> getById(String uid, String babyId);
  Future<void> upsert(String uid, BabyModel baby);
  Future<void> delete(String uid, String babyId);
}

/// Implementasi Firebase Firestore untuk [BabyRemoteDatasource].
///
/// Dokumen tersimpan di `users/{uid}/babies/{babyId}`.
class FirebaseBabyRemoteDatasource implements BabyRemoteDatasource {
  FirebaseBabyRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('babies');

  @override
  Future<List<BabyModel>> getAll(String uid) async {
    final snapshot = await _collection(uid).get();
    return snapshot.docs
        .map((doc) => BabyMapper.fromFirestore(doc.data(), doc.id, userId: uid))
        .toList();
  }

  @override
  Future<BabyModel?> getById(String uid, String babyId) async {
    final doc = await _collection(uid).doc(babyId).get();
    if (!doc.exists || doc.data() == null) return null;
    return BabyMapper.fromFirestore(doc.data()!, doc.id, userId: uid);
  }

  @override
  Future<void> upsert(String uid, BabyModel baby) async {
    await _collection(uid).doc(baby.babyId).set(
          BabyMapper.toFirestore(baby),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> delete(String uid, String babyId) async {
    await _collection(uid).doc(babyId).delete();
  }
}

