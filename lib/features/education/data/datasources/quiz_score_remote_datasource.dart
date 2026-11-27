import 'package:cloud_firestore/cloud_firestore.dart';

import '../mappers/quiz_score_mapper.dart';
import '../models/quiz_score_model.dart';

/// Kontrak remote datasource skor kuis edukasi.
abstract class QuizScoreRemoteDatasource {
  Future<List<QuizScoreModel>> getScores(String uid);
  Future<QuizScoreModel?> getScore(String uid, String quizId);
  Future<void> upsert(String uid, QuizScoreModel score);
}

/// Implementasi Firebase Firestore untuk [QuizScoreRemoteDatasource].
class FirebaseQuizScoreRemoteDatasource implements QuizScoreRemoteDatasource {
  FirebaseQuizScoreRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('quizScores');

  @override
  Future<List<QuizScoreModel>> getScores(String uid) async {
    final snapshot = await _collection(uid).get();
    return snapshot.docs
        .map((doc) => QuizScoreMapper.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<QuizScoreModel?> getScore(String uid, String quizId) async {
    final doc = await _collection(uid).doc(quizId).get();
    if (!doc.exists || doc.data() == null) return null;
    return QuizScoreMapper.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<void> upsert(String uid, QuizScoreModel score) async {
    await _collection(uid).doc(score.quizId).set(
          QuizScoreMapper.toFirestore(score),
          SetOptions(merge: true),
        );
  }
}

