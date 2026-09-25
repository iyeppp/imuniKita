import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/core/errors/failures.dart';
import 'package:imunikita/features/growth/data/datasources/growth_local_datasource.dart';
import 'package:imunikita/features/growth/data/models/growth_record_model.dart';
import 'package:imunikita/features/growth/data/repositories/growth_repository_impl.dart';
import 'package:imunikita/features/growth/domain/entities/growth_record_entity.dart';
import 'package:imunikita/features/health_journal/data/datasources/health_journal_local_datasource.dart';
import 'package:imunikita/features/health_journal/data/models/health_journal_model.dart';
import 'package:imunikita/features/health_journal/data/repositories/health_journal_repository_impl.dart';
import 'package:imunikita/features/health_journal/domain/entities/health_journal_entity.dart';
import 'package:imunikita/hive_registrar.g.dart';

/// Test Temuan #32 — lapisan data/domain baru untuk Pertumbuhan & Jurnal:
/// mapping model ↔ entity, error dibungkus `Failure`, dan operasi CRUD.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  const growthRepo = GrowthRepositoryImpl(GrowthLocalDatasource());
  const journalRepo = HealthJournalRepositoryImpl(
    HealthJournalLocalDatasource(),
  );

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('imunikita_gj_test');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await Hive.deleteBoxFromDisk(AppConstants.growthRecordsBox);
    await Hive.deleteBoxFromDisk(AppConstants.healthJournalsBox);
  });

  GrowthRecordEntity growth({
    required String id,
    required String babyId,
    required DateTime tanggal,
    double? lingkarKepala,
  }) {
    return GrowthRecordEntity(
      recordId: id,
      babyId: babyId,
      tanggalPengukuran: tanggal,
      beratBadan: 8.5,
      tinggiBadan: 70.0,
      lingkarKepala: lingkarKepala,
    );
  }

  HealthJournalEntity journal({
    required String id,
    required String babyId,
    required DateTime tanggal,
    List<String> gejala = const ['Demam'],
  }) {
    return HealthJournalEntity(
      journalId: id,
      babyId: babyId,
      tanggalCatatan: tanggal,
      isiCatatan: 'Catatan $id',
      suhuTubuh: 37.2,
      gejala: gejala,
    );
  }

  group('GrowthRepositoryImpl (#32)', () {
    test('menyimpan lalu membaca kembali sebagai entity', () async {
      await growthRepo.addRecord(
        growth(id: 'g-1', babyId: 'baby-1', tanggal: DateTime(2026, 3, 1)),
      );

      final hasil = await growthRepo.getRecordsByBaby('baby-1');

      expect(hasil, hasLength(1));
      expect(hasil.single.recordId, 'g-1');
      expect(hasil.single.beratBadan, 8.5);
      expect(hasil.single.lingkarKepala, isNull);
    });

    test('terurut lama → baru', () async {
      await growthRepo.addRecord(
        growth(id: 'g-2', babyId: 'baby-1', tanggal: DateTime(2026, 5, 1)),
      );
      await growthRepo.addRecord(
        growth(id: 'g-1', babyId: 'baby-1', tanggal: DateTime(2026, 1, 1)),
      );

      final hasil = await growthRepo.getRecordsByBaby('baby-1');

      expect(hasil.map((r) => r.recordId).toList(), ['g-1', 'g-2']);
    });

    test('tidak mencampur data bayi lain', () async {
      await growthRepo.addRecord(
        growth(id: 'g-1', babyId: 'baby-1', tanggal: DateTime(2026, 3, 1)),
      );
      await growthRepo.addRecord(
        growth(id: 'g-2', babyId: 'baby-2', tanggal: DateTime(2026, 3, 1)),
      );

      expect(await growthRepo.getRecordsByBaby('baby-1'), hasLength(1));
      expect(await growthRepo.getRecordsByBaby('baby-2'), hasLength(1));
    });

    test('deleteRecordsByBaby hanya menghapus milik bayi terkait', () async {
      await growthRepo.addRecord(
        growth(id: 'g-1', babyId: 'baby-1', tanggal: DateTime(2026, 3, 1)),
      );
      await growthRepo.addRecord(
        growth(id: 'g-2', babyId: 'baby-2', tanggal: DateTime(2026, 3, 1)),
      );

      await growthRepo.deleteRecordsByBaby('baby-1');

      expect(await growthRepo.getRecordsByBaby('baby-1'), isEmpty);
      expect(await growthRepo.getRecordsByBaby('baby-2'), hasLength(1));
    });

    test('lingkarKepala tersimpan & terbaca kembali', () async {
      await growthRepo.addRecord(
        growth(
          id: 'g-1',
          babyId: 'baby-1',
          tanggal: DateTime(2026, 3, 1),
          lingkarKepala: 42.5,
        ),
      );

      final hasil = await growthRepo.getRecordsByBaby('baby-1');
      expect(hasil.single.lingkarKepala, 42.5);
    });
  });

  group('HealthJournalRepositoryImpl (#32)', () {
    test('menyimpan lalu membaca kembali sebagai entity', () async {
      await journalRepo.addJournal(
        journal(id: 'j-1', babyId: 'baby-1', tanggal: DateTime(2026, 3, 1)),
      );

      final hasil = await journalRepo.getJournalsByBaby('baby-1');

      expect(hasil, hasLength(1));
      expect(hasil.single.isiCatatan, 'Catatan j-1');
      expect(hasil.single.suhuTubuh, 37.2);
      expect(hasil.single.gejala, ['Demam']);
    });

    test('terurut baru → lama', () async {
      await journalRepo.addJournal(
        journal(id: 'j-1', babyId: 'baby-1', tanggal: DateTime(2026, 1, 1)),
      );
      await journalRepo.addJournal(
        journal(id: 'j-2', babyId: 'baby-1', tanggal: DateTime(2026, 5, 1)),
      );

      final hasil = await journalRepo.getJournalsByBaby('baby-1');
      expect(hasil.map((j) => j.journalId).toList(), ['j-2', 'j-1']);
    });

    test('deleteJournal menghapus satu catatan saja', () async {
      await journalRepo.addJournal(
        journal(id: 'j-1', babyId: 'baby-1', tanggal: DateTime(2026, 3, 1)),
      );
      await journalRepo.addJournal(
        journal(id: 'j-2', babyId: 'baby-1', tanggal: DateTime(2026, 3, 2)),
      );

      await journalRepo.deleteJournal('j-1');

      final hasil = await journalRepo.getJournalsByBaby('baby-1');
      expect(hasil.map((j) => j.journalId).toList(), ['j-2']);
    });

    test('deleteJournalsByBaby hanya menyentuh bayi terkait', () async {
      await journalRepo.addJournal(
        journal(id: 'j-1', babyId: 'baby-1', tanggal: DateTime(2026, 3, 1)),
      );
      await journalRepo.addJournal(
        journal(id: 'j-2', babyId: 'baby-2', tanggal: DateTime(2026, 3, 1)),
      );

      await journalRepo.deleteJournalsByBaby('baby-1');

      expect(await journalRepo.getJournalsByBaby('baby-1'), isEmpty);
      expect(await journalRepo.getJournalsByBaby('baby-2'), hasLength(1));
    });
  });

  group('Mapping model ↔ entity (#32)', () {
    test('GrowthRecordModel.fromEntity/toEntity bolak-balik', () {
      final entity = growth(
        id: 'g-1',
        babyId: 'baby-1',
        tanggal: DateTime(2026, 3, 1),
        lingkarKepala: 41,
      );

      final kembali = GrowthRecordModel.fromEntity(entity).toEntity();

      expect(kembali.recordId, entity.recordId);
      expect(kembali.babyId, entity.babyId);
      expect(kembali.tanggalPengukuran, entity.tanggalPengukuran);
      expect(kembali.beratBadan, entity.beratBadan);
      expect(kembali.lingkarKepala, entity.lingkarKepala);
    });

    test('HealthJournalModel.fromEntity/toEntity bolak-balik', () {
      final entity = journal(
        id: 'j-1',
        babyId: 'baby-1',
        tanggal: DateTime(2026, 3, 1),
        gejala: const ['Demam', 'Rewel'],
      );

      final kembali = HealthJournalModel.fromEntity(entity).toEntity();

      expect(kembali.journalId, entity.journalId);
      expect(kembali.isiCatatan, entity.isiCatatan);
      expect(kembali.gejala, entity.gejala);
    });
  });

  group('Error dibungkus Failure (#32)', () {
    test('error datasource pertumbuhan menjadi LocalStorageFailure', () async {
      const repo = GrowthRepositoryImpl(_ThrowingGrowthDatasource());

      await expectLater(
        repo.getRecordsByBaby('baby-1'),
        throwsA(isA<LocalStorageFailure>()),
      );
    });

    test('error datasource jurnal menjadi LocalStorageFailure', () async {
      const repo = HealthJournalRepositoryImpl(_ThrowingJournalDatasource());

      await expectLater(
        repo.getJournalsByBaby('baby-1'),
        throwsA(isA<LocalStorageFailure>()),
      );
    });
  });
}

/// Datasource palsu yang selalu gagal — memastikan repository membungkus error
/// penyimpanan menjadi `Failure` (bukan membocorkan error mentah ke UI).
class _ThrowingGrowthDatasource extends GrowthLocalDatasource {
  const _ThrowingGrowthDatasource();

  @override
  Future<List<GrowthRecordModel>> getByBaby(String babyId) async {
    throw Exception('boom');
  }
}

class _ThrowingJournalDatasource extends HealthJournalLocalDatasource {
  const _ThrowingJournalDatasource();

  @override
  Future<List<HealthJournalModel>> getByBaby(String babyId) async {
    throw Exception('boom');
  }
}
