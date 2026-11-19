import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../features/baby_profile/data/datasources/baby_remote_datasource.dart';
import '../../features/baby_profile/data/models/baby_model.dart';
import '../../features/education/data/datasources/quiz_score_remote_datasource.dart';
import '../../features/education/data/models/quiz_score_model.dart';
import '../../features/growth/data/datasources/growth_local_datasource.dart';
import '../../features/growth/data/datasources/growth_remote_datasource.dart';
import '../../features/health_journal/data/datasources/health_journal_local_datasource.dart';
import '../../features/health_journal/data/datasources/health_journal_remote_datasource.dart';
import '../../features/immunization/data/datasources/vaccine_local_datasource.dart';
import '../../features/immunization/data/datasources/vaccine_remote_datasource.dart';
import '../constants/app_constants.dart';
import '../firebase/firebase_bootstrap.dart';
import '../services/local_storage_service.dart';

/// Ringkasan jumlah data domain lokal yang terdeteksi untuk dimigrasikan.
class MigrationSummary {
  const MigrationSummary({
    required this.babyCount,
    required this.scheduleCount,
    required this.growthCount,
    required this.journalCount,
    required this.quizScoreCount,
  });

  final int babyCount;
  final int scheduleCount;
  final int growthCount;
  final int journalCount;
  final int quizScoreCount;

  int get totalRecords =>
      babyCount + scheduleCount + growthCount + journalCount + quizScoreCount;

  bool get hasData => totalRecords > 0;
}

/// Modul migrasi data domain UTS lokal ke Firebase Cloud Firestore (B6-1 s/d B6-4).
class DataMigration {
  DataMigration({
    this.babyRemote,
    VaccineLocalDatasource? vaccineLocal,
    this.vaccineRemote,
    GrowthLocalDatasource? growthLocal,
    this.growthRemote,
    HealthJournalLocalDatasource? journalLocal,
    this.journalRemote,
    this.quizRemote,
    this.firestore,
  })  : _vaccineLocal = vaccineLocal ?? const VaccineLocalDatasource(),
        _growthLocal = growthLocal ?? const GrowthLocalDatasource(),
        _journalLocal = journalLocal ?? const HealthJournalLocalDatasource();

  final BabyRemoteDatasource? babyRemote;
  final VaccineLocalDatasource _vaccineLocal;
  final VaccineRemoteDatasource? vaccineRemote;
  final GrowthLocalDatasource _growthLocal;
  final GrowthRemoteDatasource? growthRemote;
  final HealthJournalLocalDatasource _journalLocal;
  final HealthJournalRemoteDatasource? journalRemote;
  final QuizScoreRemoteDatasource? quizRemote;
  final FirebaseFirestore? firestore;

  FirebaseFirestore? get _effectiveFirestore {
    if (firestore != null) return firestore;
    if (FirebaseBootstrap.isInitialized) return FirebaseFirestore.instance;
    return null;
  }

  /// Memeriksa apakah migrasi sudah pernah sukses untuk [newUid].
  Future<bool> isDone(String newUid) async {
    return LocalStorageService.isMigrationDone(newUid);
  }

  /// B6-1: Deteksi data lokal milik `userId` lama (UUID lokal / bukan newUid).
  Future<MigrationSummary> detectLegacyData(String newUid) async {
    if (newUid.isEmpty || await isDone(newUid)) {
      return const MigrationSummary(
        babyCount: 0,
        scheduleCount: 0,
        growthCount: 0,
        journalCount: 0,
        quizScoreCount: 0,
      );
    }

    final babyBox = await Hive.openBox<BabyModel>(AppConstants.babiesBox);
    final legacyBabies = babyBox.values
        .where((b) => b.userId != newUid && b.userId.isNotEmpty)
        .toList();

    if (legacyBabies.isEmpty) {
      return const MigrationSummary(
        babyCount: 0,
        scheduleCount: 0,
        growthCount: 0,
        journalCount: 0,
        quizScoreCount: 0,
      );
    }

    int scheduleCount = 0;
    int growthCount = 0;
    int journalCount = 0;

    for (final baby in legacyBabies) {
      final schedules = await _vaccineLocal.getByBaby(baby.babyId);
      scheduleCount += schedules.length;

      final records = await _growthLocal.getByBaby(baby.babyId);
      growthCount += records.length;

      final journals = await _journalLocal.getByBaby(baby.babyId);
      journalCount += journals.length;
    }

    int quizScoreCount = 0;
    if (Hive.isBoxOpen(AppConstants.educationQuizScoresBox)) {
      final quizBox =
          Hive.box<QuizScoreModel>(AppConstants.educationQuizScoresBox);
      quizScoreCount = quizBox.length;
    } else {
      final quizBox =
          await Hive.openBox<QuizScoreModel>(AppConstants.educationQuizScoresBox);
      quizScoreCount = quizBox.length;
    }

    return MigrationSummary(
      babyCount: legacyBabies.length,
      scheduleCount: scheduleCount,
      growthCount: growthCount,
      journalCount: journalCount,
      quizScoreCount: quizScoreCount,
    );
  }

  /// B6-2 s/d B6-4: Menjalankan alur migrasi lengkap secara idempoten.
  Future<MigrationSummary> run(String newUid) async {
    if (newUid.isEmpty) {
      return const MigrationSummary(
        babyCount: 0,
        scheduleCount: 0,
        growthCount: 0,
        journalCount: 0,
        quizScoreCount: 0,
      );
    }

    if (await isDone(newUid)) {
      if (kDebugMode) {
        debugPrint('DataMigration: Migrasi untuk $newUid sudah pernah dilakukan.');
      }
      return const MigrationSummary(
        babyCount: 0,
        scheduleCount: 0,
        growthCount: 0,
        journalCount: 0,
        quizScoreCount: 0,
      );
    }

    final summary = await detectLegacyData(newUid);
    if (!summary.hasData) {
      await LocalStorageService.markMigrationDone(newUid);
      return summary;
    }

    final babyBox = await Hive.openBox<BabyModel>(AppConstants.babiesBox);
    final legacyBabies = babyBox.values
        .where((b) => b.userId != newUid && b.userId.isNotEmpty)
        .toList();

    // B6-2: Rewrite hanya BabyModel.userId -> newUid di Hive lokal
    for (final baby in legacyBabies) {
      baby.userId = newUid;
      await baby.save();
    }

    // B6-3: Upload batch via set() per dokumen
    final effectiveBabyRemote =
        babyRemote ?? (FirebaseBootstrap.isInitialized ? FirebaseBabyRemoteDatasource() : null);
    final effectiveVaccineRemote =
        vaccineRemote ?? (FirebaseBootstrap.isInitialized ? FirebaseVaccineRemoteDatasource() : null);
    final effectiveGrowthRemote =
        growthRemote ?? (FirebaseBootstrap.isInitialized ? FirebaseGrowthRemoteDatasource() : null);
    final effectiveJournalRemote =
        journalRemote ?? (FirebaseBootstrap.isInitialized ? FirebaseHealthJournalRemoteDatasource() : null);
    final effectiveQuizRemote =
        quizRemote ?? (FirebaseBootstrap.isInitialized ? FirebaseQuizScoreRemoteDatasource() : null);

    final now = DateTime.now();

    for (final baby in legacyBabies) {
      if (effectiveBabyRemote != null) {
        await effectiveBabyRemote.upsert(newUid, baby);
      }

      final schedules = await _vaccineLocal.getByBaby(baby.babyId);
      if (effectiveVaccineRemote != null && schedules.isNotEmpty) {
        await effectiveVaccineRemote.upsertBatch(newUid, baby.babyId, schedules);
      }

      final records = await _growthLocal.getByBaby(baby.babyId);
      if (effectiveGrowthRemote != null && records.isNotEmpty) {
        for (final record in records) {
          await effectiveGrowthRemote.upsert(newUid, baby.babyId, record);
        }
      }

      final journals = await _journalLocal.getByBaby(baby.babyId);
      if (effectiveJournalRemote != null && journals.isNotEmpty) {
        for (final journal in journals) {
          await effectiveJournalRemote.upsert(newUid, baby.babyId, journal);
        }
      }
    }

    // Kuis Skor
    if (effectiveQuizRemote != null && Hive.isBoxOpen(AppConstants.educationQuizScoresBox)) {
      final quizBox =
          Hive.box<QuizScoreModel>(AppConstants.educationQuizScoresBox);
      for (final score in quizBox.values) {
        await effectiveQuizRemote.upsert(newUid, score);
      }
    }

    // B6-4: Write syncMeta/main di Firestore
    final firestore = _effectiveFirestore;
    if (firestore != null) {
      await firestore.collection('users').doc(newUid).collection('syncMeta').doc('main').set(
        {
          'schemaVersion': 1,
          'migratedAt': Timestamp.fromDate(now),
          'lastPullAt': Timestamp.fromDate(now),
        },
        SetOptions(merge: true),
      );
    }

    // Commit penanda migrasi lokal
    await LocalStorageService.markMigrationDone(newUid);

    if (kDebugMode) {
      debugPrint(
        'DataMigration: Migrasi selesai (${summary.totalRecords} record di-upload).',
      );
    }

    return summary;
  }
}
