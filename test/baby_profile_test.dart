import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/core/constants/vaccine_schedule.dart';
import 'package:imunikita/core/services/local_storage_service.dart';
import 'package:imunikita/features/baby_profile/data/datasources/baby_local_datasource.dart';
import 'package:imunikita/features/baby_profile/data/repositories/baby_repository_impl.dart';
import 'package:imunikita/features/baby_profile/domain/entities/baby_entity.dart';
import 'package:imunikita/features/baby_profile/presentation/providers/active_baby_provider.dart';
import 'package:imunikita/features/baby_profile/presentation/providers/baby_provider.dart';
import 'package:imunikita/features/growth/data/models/growth_record_model.dart';
import 'package:imunikita/features/growth/presentation/providers/growth_provider.dart';
import 'package:imunikita/features/health_journal/data/models/health_journal_model.dart';
import 'package:imunikita/features/health_journal/presentation/providers/journal_provider.dart';
import 'package:imunikita/features/immunization/data/models/vaccine_schedule_model.dart';
import 'package:imunikita/features/immunization/domain/entities/vaccine_schedule_entity.dart';
import 'package:imunikita/features/immunization/presentation/providers/immunization_provider.dart';
import 'package:imunikita/hive_registrar.g.dart';
import 'package:imunikita/injection/dependency_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test Temuan #21 (ubah/hapus profil bayi) & #2 (bayi aktif).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'user-1';
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('imunikita_baby_test');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Sesi user diperlukan `BabyNotifier.build()`.
    await prefs.setString(AppConstants.prefUserId, userId);

    for (final box in [
      AppConstants.babiesBox,
      AppConstants.vaccineSchedulesBox,
      AppConstants.growthRecordsBox,
      AppConstants.healthJournalsBox,
    ]) {
      await Hive.deleteBoxFromDisk(box);
    }
  });

  BabyEntity bayi({required String id, required String nama, DateTime? lahir}) {
    return BabyEntity(
      babyId: id,
      userId: userId,
      namaAnak: nama,
      tanggalLahir: lahir ?? DateTime(2026, 1, 10),
      jenisKelamin: BabyGender.laki,
      createdAt: DateTime(2026, 1, 10),
    );
  }

  Future<void> isiJadwal(String babyId, int jumlah) async {
    final box = await Hive.openBox<VaccineScheduleModel>(
      AppConstants.vaccineSchedulesBox,
    );
    for (var i = 0; i < jumlah; i++) {
      final id = '$babyId-jadwal-$i';
      await box.put(
        id,
        VaccineScheduleModel(
          scheduleId: id,
          babyId: babyId,
          namaVaksin: 'Vaksin $i',
          deskripsi: 'Deskripsi $i',
          usiaBulanTarget: i,
          tanggalTarget: DateTime(2026, 6, 1),
          status: VaccineStatus.belum,
        ),
      );
    }
  }

  Future<void> isiPertumbuhan(String babyId, int jumlah) async {
    final box = await Hive.openBox<GrowthRecordModel>(
      AppConstants.growthRecordsBox,
    );
    for (var i = 0; i < jumlah; i++) {
      final id = '$babyId-ukur-$i';
      await box.put(
        id,
        GrowthRecordModel(
          recordId: id,
          babyId: babyId,
          tanggalPengukuran: DateTime(2026, 2, 1),
          beratBadan: 6 + i.toDouble(),
          tinggiBadan: 60 + i.toDouble(),
        ),
      );
    }
  }

  Future<void> isiJurnal(String babyId, int jumlah) async {
    final box = await Hive.openBox<HealthJournalModel>(
      AppConstants.healthJournalsBox,
    );
    for (var i = 0; i < jumlah; i++) {
      final id = '$babyId-jurnal-$i';
      await box.put(
        id,
        HealthJournalModel(
          journalId: id,
          babyId: babyId,
          tanggalCatatan: DateTime(2026, 2, 1),
          isiCatatan: 'Catatan $i',
          gejala: const ['Demam'],
        ),
      );
    }
  }

  group('Hapus profil bayi — data layer (#21)', () {
    test('deleteBaby menghapus profil dari Hive', () async {
      const repository = BabyRepositoryImpl(BabyLocalDatasource());
      await repository.addBaby(bayi(id: 'baby-1', nama: 'Aira'));
      expect((await repository.getBabiesByUser(userId)).length, 1);

      await repository.deleteBaby('baby-1');

      expect(await repository.getBabiesByUser(userId), isEmpty);
      expect(await repository.getBabyById('baby-1'), isNull);
    });

    test('deleteBaby untuk id tak dikenal tidak melempar error', () async {
      const repository = BabyRepositoryImpl(BabyLocalDatasource());
      await expectLater(repository.deleteBaby('tidak-ada'), completes);
    });

    test('updateBaby menyimpan perubahan nama & tanggal lahir', () async {
      const repository = BabyRepositoryImpl(BabyLocalDatasource());
      final awal = await repository.addBaby(bayi(id: 'baby-1', nama: 'Aira'));

      await repository.updateBaby(
        awal.copyWith(
          namaAnak: 'Aira Putri',
          tanggalLahir: DateTime(2026, 3, 15),
        ),
      );

      final sesudah = await repository.getBabyById('baby-1');
      expect(sesudah?.namaAnak, 'Aira Putri');
      expect(sesudah?.tanggalLahir, DateTime(2026, 3, 15));
    });
  });

  group('Bayi aktif (#2)', () {
    test('tanpa bayi → null dan pilihan lama dibersihkan', () async {
      await LocalStorageService.setActiveBabyId('baby-lama');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(activeBabyProvider.future), isNull);
      expect(await LocalStorageService.getActiveBabyId(), isNull);
    });

    test(
      'memilih bayi pertama & menyimpannya bila belum ada pilihan',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(babyNotifierProvider.notifier);
        await notifier.addBaby(bayi(id: 'baby-1', nama: 'Aira'));
        await notifier.addBaby(bayi(id: 'baby-2', nama: 'Bima'));

        final aktif = await container.read(activeBabyProvider.future);

        expect(aktif?.babyId, 'baby-1');
        expect(await LocalStorageService.getActiveBabyId(), 'baby-1');
      },
    );

    test('selectBaby mengganti bayi aktif', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(babyNotifierProvider.notifier);
      await notifier.addBaby(bayi(id: 'baby-1', nama: 'Aira'));
      await notifier.addBaby(bayi(id: 'baby-2', nama: 'Bima'));
      await container.read(activeBabyProvider.future);

      await container.read(activeBabyProvider.notifier).selectBaby('baby-2');

      expect(
        (await container.read(activeBabyProvider.future))?.babyId,
        'baby-2',
      );
      expect(await LocalStorageService.getActiveBabyId(), 'baby-2');
    });

    test('bayi aktif dihapus → jatuh ke bayi yang tersisa', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(babyNotifierProvider.notifier);
      await notifier.addBaby(bayi(id: 'baby-1', nama: 'Aira'));
      await notifier.addBaby(bayi(id: 'baby-2', nama: 'Bima'));
      await container.read(activeBabyProvider.notifier).selectBaby('baby-1');

      await notifier.deleteBaby('baby-1');

      expect(
        (await container.read(activeBabyProvider.future))?.babyId,
        'baby-2',
      );
      expect(await LocalStorageService.getActiveBabyId(), 'baby-2');
    });

    test('semua bayi dihapus → null', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(babyNotifierProvider.notifier);
      await notifier.addBaby(bayi(id: 'baby-1', nama: 'Aira'));
      await container.read(activeBabyProvider.future);

      await notifier.deleteBaby('baby-1');

      expect(await container.read(activeBabyProvider.future), isNull);
      expect(await LocalStorageService.getActiveBabyId(), isNull);
    });
  });

  group('Cascade delete data turunan (#21)', () {
    test('deleteAllForBaby hanya membersihkan data bayi terkait', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await isiJadwal('baby-1', 13);
      await isiJadwal('baby-2', 13);
      await isiPertumbuhan('baby-1', 2);
      await isiPertumbuhan('baby-2', 3);
      await isiJurnal('baby-1', 1);
      await isiJurnal('baby-2', 4);

      await container
          .read(immunizationProvider('baby-1').notifier)
          .deleteAllForBaby();
      await container
          .read(growthProvider('baby-1').notifier)
          .deleteAllForBaby();
      await container
          .read(journalProvider('baby-1').notifier)
          .deleteAllForBaby();

      final jadwal = await Hive.openBox<VaccineScheduleModel>(
        AppConstants.vaccineSchedulesBox,
      );
      final ukur = await Hive.openBox<GrowthRecordModel>(
        AppConstants.growthRecordsBox,
      );
      final jurnal = await Hive.openBox<HealthJournalModel>(
        AppConstants.healthJournalsBox,
      );

      expect(jadwal.length, 13);
      expect(jadwal.values.every((s) => s.babyId == 'baby-2'), isTrue);
      expect(ukur.length, 3);
      expect(ukur.values.every((r) => r.babyId == 'baby-2'), isTrue);
      expect(jurnal.length, 4);
      expect(jurnal.values.every((j) => j.babyId == 'baby-2'), isTrue);
    });
  });

  group('Hitung ulang jadwal setelah tanggal lahir diperbaiki', () {
    test('hapus + generate ulang memakai tanggal lahir baru', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final generator = container.read(generateScheduleUseCaseProvider);

      final awal = await generator.execute(
        babyId: 'baby-1',
        tanggalLahir: DateTime(2026, 1, 10),
      );
      expect(awal.length, VaccineMaster.jadwalNasional.length);
      expect(awal.length, 13);

      // Meniru alur `BabyDetailScreen`: bersihkan lalu bangun ulang.
      await container
          .read(immunizationProvider('baby-1').notifier)
          .deleteAllForBaby();
      final baru = await generator.execute(
        babyId: 'baby-1',
        tanggalLahir: DateTime(2026, 3, 15),
      );

      expect(baru.length, 13);
      final mr = baru.firstWhere((s) => s.usiaBulanTarget == 9);
      expect(mr.tanggalTarget, DateTime(2026, 12, 15));

      final box = await Hive.openBox<VaccineScheduleModel>(
        AppConstants.vaccineSchedulesBox,
      );
      expect(box.length, 13);
      expect(box.values.every((s) => s.babyId == 'baby-1'), isTrue);
    });
  });
}
