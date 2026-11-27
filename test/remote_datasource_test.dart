import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/firebase/firebase_bootstrap.dart';
import 'package:imunikita/features/baby_profile/data/datasources/baby_remote_datasource.dart';
import 'package:imunikita/features/baby_profile/data/models/baby_model.dart';
import 'package:imunikita/features/baby_profile/domain/entities/baby_entity.dart';
import 'package:imunikita/features/education/data/datasources/quiz_score_remote_datasource.dart';
import 'package:imunikita/features/education/data/models/quiz_score_model.dart';
import 'package:imunikita/features/growth/data/datasources/growth_remote_datasource.dart';
import 'package:imunikita/features/growth/data/models/growth_record_model.dart';
import 'package:imunikita/features/health_journal/data/datasources/health_journal_remote_datasource.dart';
import 'package:imunikita/features/health_journal/data/models/health_journal_model.dart';
import 'package:imunikita/features/immunization/data/datasources/vaccine_remote_datasource.dart';
import 'package:imunikita/features/immunization/data/models/vaccine_schedule_model.dart';
import 'package:imunikita/injection/dependency_injection.dart';

/// Test unit — kontrak remote datasource dan registrasi DI.
void main() {
  group('Remote Datasource DI Providers (B4-7)', () {
    test('provider mengembalikan null saat Firebase belum diinisialisasi', () {
      expect(FirebaseBootstrap.isInitialized, isFalse);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(babyRemoteDatasourceProvider), isNull);
      expect(container.read(vaccineRemoteDatasourceProvider), isNull);
      expect(container.read(growthRemoteDatasourceProvider), isNull);
      expect(container.read(healthJournalRemoteDatasourceProvider), isNull);
      expect(container.read(quizScoreRemoteDatasourceProvider), isNull);
    });

    test('provider dapat di-override dengan fake datasource di test environment', () {
      final fakeBabyRemote = _FakeBabyRemoteDatasource();
      final fakeVaccineRemote = _FakeVaccineRemoteDatasource();
      final fakeGrowthRemote = _FakeGrowthRemoteDatasource();
      final fakeJournalRemote = _FakeHealthJournalRemoteDatasource();
      final fakeQuizRemote = _FakeQuizScoreRemoteDatasource();

      final container = ProviderContainer(
        overrides: [
          babyRemoteDatasourceProvider.overrideWithValue(fakeBabyRemote),
          vaccineRemoteDatasourceProvider.overrideWithValue(fakeVaccineRemote),
          growthRemoteDatasourceProvider.overrideWithValue(fakeGrowthRemote),
          healthJournalRemoteDatasourceProvider.overrideWithValue(fakeJournalRemote),
          quizScoreRemoteDatasourceProvider.overrideWithValue(fakeQuizRemote),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(babyRemoteDatasourceProvider), same(fakeBabyRemote));
      expect(container.read(vaccineRemoteDatasourceProvider), same(fakeVaccineRemote));
      expect(container.read(growthRemoteDatasourceProvider), same(fakeGrowthRemote));
      expect(container.read(healthJournalRemoteDatasourceProvider), same(fakeJournalRemote));
      expect(container.read(quizScoreRemoteDatasourceProvider), same(fakeQuizRemote));
    });
  });

  group('FakeBabyRemoteDatasource CRUD (B4-2)', () {
    late _FakeBabyRemoteDatasource datasource;

    setUp(() {
      datasource = _FakeBabyRemoteDatasource();
    });

    test('getAll mengembalikan list bayi berdasarkan uid', () async {
      final baby = BabyModel(
        babyId: 'b-1',
        userId: 'u-1',
        namaAnak: 'Bayi 1',
        tanggalLahir: DateTime(2025, 1, 1),
        jenisKelamin: BabyGender.laki,
        createdAt: DateTime.now(),
      );
      await datasource.upsert('u-1', baby);

      final result = await datasource.getAll('u-1');
      expect(result, hasLength(1));
      expect(result.first.babyId, 'b-1');

      final empty = await datasource.getAll('u-other');
      expect(empty, isEmpty);
    });

    test('delete menghapus bayi yang sesuai', () async {
      final baby = BabyModel(
        babyId: 'b-2',
        userId: 'u-1',
        namaAnak: 'Bayi 2',
        tanggalLahir: DateTime(2025, 1, 1),
        jenisKelamin: BabyGender.perempuan,
        createdAt: DateTime.now(),
      );
      await datasource.upsert('u-1', baby);
      await datasource.delete('u-1', 'b-2');

      final getResult = await datasource.getById('u-1', 'b-2');
      expect(getResult, isNull);
    });
  });

  group('FakeVaccineRemoteDatasource Batch (B4-3)', () {
    test('upsertBatch menyimpan seluruh jadwal', () async {
      final datasource = _FakeVaccineRemoteDatasource();
      final schedules = List.generate(
        13,
        (i) => VaccineScheduleModel(
          scheduleId: 'sch-$i',
          babyId: 'b-1',
          namaVaksin: 'Vaksin $i',
          deskripsi: 'Deskripsi $i',
          usiaBulanTarget: i,
          tanggalTarget: DateTime.now(),
          status: 'BELUM',
        ),
      );

      await datasource.upsertBatch('u-1', 'b-1', schedules);

      final result = await datasource.getSchedules('u-1', 'b-1');
      expect(result, hasLength(13));
    });
  });

  group('FakeGrowthRemoteDatasource (B4-4)', () {
    test('CRUD rekam pertumbuhan', () async {
      final datasource = _FakeGrowthRemoteDatasource();
      final record = GrowthRecordModel(
        recordId: 'rec-1',
        babyId: 'b-1',
        tanggalPengukuran: DateTime.now(),
        beratBadan: 4.5,
        tinggiBadan: 55.0,
      );

      await datasource.upsert('u-1', 'b-1', record);
      final list = await datasource.getRecords('u-1', 'b-1');
      expect(list, hasLength(1));

      await datasource.delete('u-1', 'b-1', 'rec-1');
      expect(await datasource.getRecords('u-1', 'b-1'), isEmpty);
    });
  });

  group('FakeHealthJournalRemoteDatasource (B4-5)', () {
    test('filter berdasarkan vaccineScheduleId', () async {
      final datasource = _FakeHealthJournalRemoteDatasource();
      final j1 = HealthJournalModel(
        journalId: 'j-1',
        babyId: 'b-1',
        vaccineScheduleId: 'sch-1',
        tanggalCatatan: DateTime.now(),
        isiCatatan: 'Demam setelah vaksin 1',
        gejala: ['Demam'],
      );
      final j2 = HealthJournalModel(
        journalId: 'j-2',
        babyId: 'b-1',
        vaccineScheduleId: 'sch-2',
        tanggalCatatan: DateTime.now(),
        isiCatatan: 'Batuk pilek biasa',
        gejala: ['Batuk'],
      );

      await datasource.upsert('u-1', 'b-1', j1);
      await datasource.upsert('u-1', 'b-1', j2);

      final filtered = await datasource.getJournals('u-1', 'b-1', vaccineScheduleId: 'sch-1');
      expect(filtered, hasLength(1));
      expect(filtered.first.journalId, 'j-1');

      final all = await datasource.getJournals('u-1', 'b-1');
      expect(all, hasLength(2));
    });
  });

  group('FakeQuizScoreRemoteDatasource (B4-6)', () {
    test('upsert dan getScore', () async {
      final datasource = _FakeQuizScoreRemoteDatasource();
      final score = QuizScoreModel(
        quizId: 'q-1',
        skor: 5,
        totalSoal: 5,
        tanggalPengerjaan: DateTime.now(),
      );

      await datasource.upsert('u-1', score);

      final found = await datasource.getScore('u-1', 'q-1');
      expect(found, isNotNull);
      expect(found!.skor, 5);

      final notFound = await datasource.getScore('u-1', 'q-none');
      expect(notFound, isNull);
    });
  });
}

// =============================================================================
// Fake Implementations for Testing Contracts
// =============================================================================

class _FakeBabyRemoteDatasource implements BabyRemoteDatasource {
  final Map<String, Map<String, BabyModel>> _store = {};

  @override
  Future<List<BabyModel>> getAll(String uid) async =>
      _store[uid]?.values.toList() ?? [];

  @override
  Future<BabyModel?> getById(String uid, String babyId) async =>
      _store[uid]?[babyId];

  @override
  Future<void> upsert(String uid, BabyModel baby) async {
    _store.putIfAbsent(uid, () => {})[baby.babyId] = baby;
  }

  @override
  Future<void> delete(String uid, String babyId) async {
    _store[uid]?.remove(babyId);
  }
}

class _FakeVaccineRemoteDatasource implements VaccineRemoteDatasource {
  final Map<String, Map<String, VaccineScheduleModel>> _store = {};

  String _key(String uid, String babyId) => '$uid/$babyId';

  @override
  Future<List<VaccineScheduleModel>> getSchedules(String uid, String babyId) async =>
      _store[_key(uid, babyId)]?.values.toList() ?? [];

  @override
  Future<void> upsert(String uid, String babyId, VaccineScheduleModel schedule) async {
    _store.putIfAbsent(_key(uid, babyId), () => {})[schedule.scheduleId] = schedule;
  }

  @override
  Future<void> upsertBatch(String uid, String babyId, List<VaccineScheduleModel> schedules) async {
    for (final s in schedules) {
      await upsert(uid, babyId, s);
    }
  }

  @override
  Future<void> delete(String uid, String babyId, String scheduleId) async {
    _store[_key(uid, babyId)]?.remove(scheduleId);
  }
}

class _FakeGrowthRemoteDatasource implements GrowthRemoteDatasource {
  final Map<String, Map<String, GrowthRecordModel>> _store = {};

  String _key(String uid, String babyId) => '$uid/$babyId';

  @override
  Future<List<GrowthRecordModel>> getRecords(String uid, String babyId) async =>
      _store[_key(uid, babyId)]?.values.toList() ?? [];

  @override
  Future<void> upsert(String uid, String babyId, GrowthRecordModel record) async {
    _store.putIfAbsent(_key(uid, babyId), () => {})[record.recordId] = record;
  }

  @override
  Future<void> delete(String uid, String babyId, String recordId) async {
    _store[_key(uid, babyId)]?.remove(recordId);
  }
}

class _FakeHealthJournalRemoteDatasource implements HealthJournalRemoteDatasource {
  final Map<String, Map<String, HealthJournalModel>> _store = {};

  String _key(String uid, String babyId) => '$uid/$babyId';

  @override
  Future<List<HealthJournalModel>> getJournals(
    String uid,
    String babyId, {
    String? vaccineScheduleId,
  }) async {
    final list = _store[_key(uid, babyId)]?.values.toList() ?? [];
    if (vaccineScheduleId != null) {
      return list.where((j) => j.vaccineScheduleId == vaccineScheduleId).toList();
    }
    return list;
  }

  @override
  Future<void> upsert(String uid, String babyId, HealthJournalModel journal) async {
    _store.putIfAbsent(_key(uid, babyId), () => {})[journal.journalId] = journal;
  }

  @override
  Future<void> delete(String uid, String babyId, String journalId) async {
    _store[_key(uid, babyId)]?.remove(journalId);
  }
}

class _FakeQuizScoreRemoteDatasource implements QuizScoreRemoteDatasource {
  final Map<String, Map<String, QuizScoreModel>> _store = {};

  @override
  Future<List<QuizScoreModel>> getScores(String uid) async =>
      _store[uid]?.values.toList() ?? [];

  @override
  Future<QuizScoreModel?> getScore(String uid, String quizId) async =>
      _store[uid]?[quizId];

  @override
  Future<void> upsert(String uid, QuizScoreModel score) async {
    _store.putIfAbsent(uid, () => {})[score.quizId] = score;
  }
}

