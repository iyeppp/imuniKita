import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore tidak memiliki cascade delete, dan Cloud Functions tidak dipakai (memerlukan billing), sehingga penghapusan dilakukan dari klien.
const List<String> babyChildCollections = [
  'vaccineSchedules',
  'growthRecords',
  'healthJournals',
];

/// Batas operasi per `WriteBatch` Firestore.
const int firestoreBatchLimit = 500;

/// Hapus seluruh dokumen dalam [collection] secara bertahap (batch ≤ 500).
Future<void> deleteCollectionInBatches(
  FirebaseFirestore firestore,
  CollectionReference<Map<String, dynamic>> collection,
) async {
  while (true) {
    final snapshot = await collection.limit(firestoreBatchLimit).get();
    if (snapshot.docs.isEmpty) return;

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

/// Hapus bayi beserta seluruh subkoleksi turunannya, lalu dokumen bayi itu sendiri.
Future<void> deleteBabyCascade(
  FirebaseFirestore firestore, {
  required String uid,
  required String babyId,
}) async {
  final babyRef = firestore
      .collection('users')
      .doc(uid)
      .collection('babies')
      .doc(babyId);

  for (final name in babyChildCollections) {
    await deleteCollectionInBatches(firestore, babyRef.collection(name));
  }
  await babyRef.delete();
}
