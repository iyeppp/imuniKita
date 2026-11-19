import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/core/services/local_storage_service.dart';
import 'package:imunikita/core/sync/data_migration.dart';
import 'package:imunikita/features/baby_profile/data/datasources/baby_remote_datasource.dart';
import 'package:imunikita/features/baby_profile/data/models/baby_model.dart';
import 'package:imunikita/features/education/data/datasources/quiz_score_remote_datasource.dart';
import 'package:imunikita/features/education/data/models/quiz_score_model.dart';
import 'package:imunikita/features/growth/data/datasources/growth_local_datasource.dart';
import 'package:imunikita/features/growth/data/datasources/growth_remote_datasource.dart';
import 'package:imunikita/features/growth/data/models/growth_record_model.dart';
import 'package:imunikita/features/health_journal/data/datasources/health_journal_local_datasource.dart';
import 'package:imunikita/features/health_journal/data/datasources/health_journal_remote_datasource.dart';
import 'package:imunikita/features/health_journal/data/models/health_journal_model.dart';
import 'package:imunikita/features/immunization/data/datasources/vaccine_local_datasource.dart';
import 'package:imunikita/features/immunization/data/datasources/vaccine_remote_datasource.dart';
import 'package:imunikita/features/immunization/data/models/vaccine_schedule_model.dart';
import 'package:imunikita/hive_registrar.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBabyRemoteDatasource implements BabyRemoteDatasource {
  final Map<String, BabyModel> items = {};

  @override
  Future<List<BabyModel>> getAll(String uid) async {
    return items.values.where((b) => b.userId == uid).toList();
  }

  @override
  Future<BabyModel?> getById(String uid, String babyId) async => items[babyId];

  @override
  Future<void> upsert(String uid, BabyModel baby) async {
    items[baby.babyId] = baby;
  }

  @override
  Future<void> delete(String uid, String babyId) async {
    items.remove(babyId);
  }
}

class FakeVaccineRemoteDatasource implements VaccineRemoteDatasource {
  final Map<String, VaccineScheduleModel> items = {};

  @override
  Future<List<VaccineScheduleModel>> getSchedules(String uid, String babyId) async {
    return items.values.where((s) => s.babyId == babyId).toList();
  }

  @override
  Future<void> upsert(String uid, String babyId, VaccineScheduleModel schedule) async {
    items[schedule.scheduleId] = schedule;
  }

  @override
  Future<void> upsertBatch(String uid, String babyId, List<VaccineScheduleModel> schedules) async {
    for (final s in schedules) {
      items[s.scheduleId] = s;
    }
  }

  @override
  Future<void> delete(String uid, String babyId, String scheduleId) async {
    items.remove(scheduleId);
  }
}

class FakeGrowthRemoteDatasource implements GrowthRemoteDatasource {
  final Map<String, GrowthRecordModel> items = {};

  @override
  Future<List<GrowthRecordModel>> getRecords(String uid, String babyId) async {
    return items.values.where((r) => r.babyId == babyId).toList();
  }

  @override
  Future<void> upsert(String uid, String babyId, GrowthRecordModel record) async {
    items[record.recordId] = record;
  }

  @override
  Future<void> delete(String uid, String babyId, String recordId) async {
    items.remove(recordId);
  }
}

class FakeHealthJournalRemoteDatasource implements HealthJournalRemoteDatasource {
  final Map<String, HealthJournalModel> items = {};

  @override
  Future<List<HealthJournalModel>> getJournals(
    String uid,
    String babyId, {
    String? vaccineScheduleId,
  }) async {
    return items.values.where((j) {
      if (j.babyId != babyId) return false;
      if (vaccineScheduleId != null && vaccineScheduleId.isNotEmpty) {
        return j.vaccineScheduleId == vaccineScheduleId;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> upsert(String uid, String babyId, HealthJournalModel journal) async {
    items[journal.journalId] = journal;
  }

  @override
  Future<void> delete(String uid, String babyId, String journalId) async {
    items.remove(journalId);
  }
}

class FakeQuizScoreRemoteDatasource implements QuizScoreRemoteDatasource {
  final Map<String, QuizScoreModel> items = {};

  @override
  Future<List<QuizScoreModel>> getScores(String uid) async => items.values.toList();

  @override
  Future<QuizScoreModel?> getScore(String uid, String quizId) async => items[quizId];

  @override
  Future<void> upsert(String uid, QuizScoreModel score) async {
    items[score.quizId] = score;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<BabyModel> babyBox;
  late Box<VaccineScheduleModel> scheduleBox;
  late Box<GrowthRecordModel> growthBox;
  late Box<HealthJournalModel> journalBox;
  late Box<QuizScoreModel> quizBox;

  late FakeBabyRemoteDatasource babyRemote;
  late FakeVaccineRemoteDatasource vaccineRemote;
  late FakeGrowthRemoteDatasource growthRemote;
  late FakeHealthJournalRemoteDatasource journalRemote;
  late FakeQuizScoreRemoteDatasource quizRemote;

  setUpAll(() async {
    Hive.init('./test/hive_migration_test_dir');
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      final dir = Directory('./test/hive_migration_test_dir');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    babyBox = await Hive.openBox<BabyModel>(AppConstants.babiesBox);
    scheduleBox = await Hive.openBox<VaccineScheduleModel>(AppConstants.vaccineSchedulesBox);
    growthBox = await Hive.openBox<GrowthRecordModel>(AppConstants.growthRecordsBox);
    journalBox = await Hive.openBox<HealthJournalModel>(AppConstants.healthJournalsBox);
    quizBox = await Hive.openBox<QuizScoreModel>(AppConstants.educationQuizScoresBox);

    await babyBox.clear();
    await scheduleBox.clear();
    await growthBox.clear();
    await journalBox.clear();
    await quizBox.clear();

    babyRemote = FakeBabyRemoteDatasource();
    vaccineRemote = FakeVaccineRemoteDatasource();
    growthRemote = FakeGrowthRemoteDatasource();
    journalRemote = FakeHealthJournalRemoteDatasource();
    quizRemote = FakeQuizScoreRemoteDatasource();
  });

  tearDown(() async {
    await babyBox.clear();
    await scheduleBox.clear();
    await growthBox.clear();
    await journalBox.clear();
    await quizBox.clear();
  });

  group('B6-1 s/d B6-6 DataMigration Tests', () {
    test('detectLegacyData mendeteksi data domain lokal milik userId lama', () async {
      const oldUserId = 'legacy-local-uuid';
      const newUid = 'firebase-uid-001';

      // Seed 2 bayi + 13 jadwal + 1 growth + 1 jurnal + 1 quiz score
      final baby1 = BabyModel(
        babyId: 'b1',
        userId: oldUserId,
        namaAnak: 'Ahmad',
        tanggalLahir: DateTime(2026, 1, 1),
        jenisKelamin: 'L',
        createdAt: DateTime.now(),
      );
      final baby2 = BabyModel(
        babyId: 'b2',
        userId: oldUserId,
        namaAnak: 'Aisyah',
        tanggalLahir: DateTime(2026, 2, 1),
        jenisKelamin: 'P',
        createdAt: DateTime.now(),
      );
      await babyBox.put(baby1.babyId, baby1);
      await babyBox.put(baby2.babyId, baby2);

      final schedule = VaccineScheduleModel(
        scheduleId: 's1',
        babyId: 'b1',
        namaVaksin: 'BCG',
        deskripsi: 'Vaksin BCG',
        usiaBulanTarget: 1,
        tanggalTarget: DateTime.now(),
        status: 'BELUM',
      );
      await scheduleBox.put(schedule.scheduleId, schedule);

      final growth = GrowthRecordModel(
        recordId: 'g1',
        babyId: 'b1',
        tanggalPengukuran: DateTime.now(),
        beratBadan: 4.5,
        tinggiBadan: 55.0,
      );
      await growthBox.put(growth.recordId, growth);

      final journal = HealthJournalModel(
        journalId: 'j1',
        babyId: 'b1',
        tanggalCatatan: DateTime.now(),
        isiCatatan: 'Anak sehat',
        gejala: [],
      );
      await journalBox.put(journal.journalId, journal);

      final quiz = QuizScoreModel(
        quizId: 'q1',
        skor: 5,
        totalSoal: 5,
        tanggalPengerjaan: DateTime.now(),
      );
      await quizBox.put(quiz.quizId, quiz);

      final migration = DataMigration(
        babyRemote: babyRemote,
        vaccineLocal: const VaccineLocalDatasource(),
        vaccineRemote: vaccineRemote,
        growthLocal: const GrowthLocalDatasource(),
        growthRemote: growthRemote,
        journalLocal: const HealthJournalLocalDatasource(),
        journalRemote: journalRemote,
        quizRemote: quizRemote,
      );

      final summary = await migration.detectLegacyData(newUid);

      expect(summary.babyCount, equals(2));
      expect(summary.scheduleCount, equals(1));
      expect(summary.growthCount, equals(1));
      expect(summary.journalCount, equals(1));
      expect(summary.quizScoreCount, equals(1));
      expect(summary.hasData, isTrue);
    });

    test('run mengeksekusi migrasi, rewrite BabyModel.userId, upload ke remote, dan idempoten', () async {
      const oldUserId = 'legacy-local-uuid';
      const newUid = 'firebase-uid-001';

      final baby1 = BabyModel(
        babyId: 'b1',
        userId: oldUserId,
        namaAnak: 'Ahmad',
        tanggalLahir: DateTime(2026, 1, 1),
        jenisKelamin: 'L',
        createdAt: DateTime.now(),
      );
      await babyBox.put(baby1.babyId, baby1);

      final schedule = VaccineScheduleModel(
        scheduleId: 's1',
        babyId: 'b1',
        namaVaksin: 'BCG',
        deskripsi: 'Vaksin BCG',
        usiaBulanTarget: 1,
        tanggalTarget: DateTime.now(),
        status: 'BELUM',
      );
      await scheduleBox.put(schedule.scheduleId, schedule);

      final migration = DataMigration(
        babyRemote: babyRemote,
        vaccineLocal: const VaccineLocalDatasource(),
        vaccineRemote: vaccineRemote,
        growthLocal: const GrowthLocalDatasource(),
        growthRemote: growthRemote,
        journalLocal: const HealthJournalLocalDatasource(),
        journalRemote: journalRemote,
        quizRemote: quizRemote,
      );

      final summary = await migration.run(newUid);

      expect(summary.babyCount, equals(1));

      // Verifikasi B6-2: BabyModel.userId di Hive lokal di-rewrite ke newUid
      final updatedBabyLocal = babyBox.get('b1');
      expect(updatedBabyLocal?.userId, equals(newUid));
      expect(updatedBabyLocal?.babyId, equals('b1')); // ID tetap identik!

      // Verifikasi B6-3: Data muncul di remote dengan ID identik
      expect(babyRemote.items.containsKey('b1'), isTrue);
      expect(vaccineRemote.items.containsKey('s1'), isTrue);

      // Verifikasi B6-4: Penanda migrasi lokal ter-set
      expect(await LocalStorageService.isMigrationDone(newUid), isTrue);

      // Verifikasi Idempotensi: Jalankan migrasi ke-2x -> skip (summary 0)
      final secondSummary = await migration.run(newUid);
      expect(secondSummary.totalRecords, equals(0));
    });
  });
}
