import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/features/immunization/data/datasources/vaccine_local_datasource.dart';
import 'package:imunikita/features/immunization/data/models/vaccine_schedule_model.dart';
import 'package:imunikita/features/immunization/data/repositories/immunization_repository_impl.dart';
import 'package:imunikita/features/immunization/domain/entities/vaccine_schedule_entity.dart';
import 'package:imunikita/hive_registrar.g.dart';

/// Test Temuan #3 — status jadwal imunisasi yang sudah lewat harus terbaca
/// `TERLEWAT`, tanpa mengubah data yang tersimpan di Hive.
void main() {
  final hariIni = DateTime(2026, 9, 24);

  group('VaccineStatus.effective', () {
    test('jadwal yang belum lewat tetap BELUM', () {
      expect(
        VaccineStatus.effective(
          status: VaccineStatus.belum,
          tanggalTarget: DateTime(2026, 9, 25),
          now: hariIni,
        ),
        VaccineStatus.belum,
      );
    });

    test(
      'jadwal yang jatuh hari ini masih BELUM (belum bisa disebut lewat)',
      () {
        expect(
          VaccineStatus.effective(
            status: VaccineStatus.belum,
            tanggalTarget: DateTime(2026, 9, 24),
            now: hariIni,
          ),
          VaccineStatus.belum,
        );
      },
    );

    test('jadwal kemarin menjadi TERLEWAT', () {
      expect(
        VaccineStatus.effective(
          status: VaccineStatus.belum,
          tanggalTarget: DateTime(2026, 9, 23),
          now: hariIni,
        ),
        VaccineStatus.terlewat,
      );
    });

    test('jam pada tanggal tidak mempengaruhi hasil', () {
      expect(
        VaccineStatus.effective(
          status: VaccineStatus.belum,
          tanggalTarget: DateTime(2026, 9, 24, 8),
          now: DateTime(2026, 9, 24, 23, 59),
        ),
        VaccineStatus.belum,
      );
    });

    test('status SELESAI tidak pernah ditimpa', () {
      expect(
        VaccineStatus.effective(
          status: VaccineStatus.selesai,
          tanggalTarget: DateTime(2026, 9, 1),
          now: hariIni,
        ),
        VaccineStatus.selesai,
      );
    });

    test('status TERLEWAT yang tersimpan tetap TERLEWAT', () {
      expect(
        VaccineStatus.effective(
          status: VaccineStatus.terlewat,
          tanggalTarget: DateTime(2026, 9, 1),
          now: hariIni,
        ),
        VaccineStatus.terlewat,
      );
    });

    test('isOverdue sejalan dengan effective', () {
      expect(
        VaccineStatus.isOverdue(
          status: VaccineStatus.belum,
          tanggalTarget: DateTime(2026, 9, 1),
          now: hariIni,
        ),
        isTrue,
      );
      expect(
        VaccineStatus.isOverdue(
          status: VaccineStatus.belum,
          tanggalTarget: DateTime(2026, 10, 1),
          now: hariIni,
        ),
        isFalse,
      );
    });
  });

  group('ImmunizationRepositoryImpl — normalisasi status', () {
    late Directory tempDir;
    late ImmunizationRepositoryImpl repository;

    const datasource = VaccineLocalDatasource();

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('imunikita_vaccine_test');
      Hive.init(tempDir.path);
      Hive.registerAdapters();
      repository = const ImmunizationRepositoryImpl(datasource);
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    setUp(() async {
      await Hive.deleteBoxFromDisk(AppConstants.vaccineSchedulesBox);
    });

    VaccineScheduleModel model({
      required String scheduleId,
      required DateTime tanggalTarget,
      String status = VaccineStatus.belum,
      String babyId = 'baby-1',
      int usiaBulanTarget = 0,
    }) {
      return VaccineScheduleModel(
        scheduleId: scheduleId,
        babyId: babyId,
        namaVaksin: 'Vaksin $scheduleId',
        deskripsi: 'Deskripsi $scheduleId',
        usiaBulanTarget: usiaBulanTarget,
        tanggalTarget: tanggalTarget,
        status: status,
      );
    }

    Future<void> seed(List<VaccineScheduleModel> models) async {
      final box = await Hive.openBox<VaccineScheduleModel>(
        AppConstants.vaccineSchedulesBox,
      );
      await box.putAll({for (final m in models) m.scheduleId: m});
    }

    test('jadwal BELUM yang sudah lewat terbaca TERLEWAT', () async {
      await seed([
        model(
          scheduleId: 's-1',
          tanggalTarget: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);

      final hasil = await repository.getSchedulesByBaby('baby-1');

      expect(hasil.single.status, VaccineStatus.terlewat);
    });

    test(
      'jadwal masa depan tetap BELUM dan terurut berdasarkan usia',
      () async {
        final besok = DateTime.now().add(const Duration(days: 1));
        await seed([
          model(scheduleId: 's-2', tanggalTarget: besok, usiaBulanTarget: 3),
          model(scheduleId: 's-1', tanggalTarget: besok, usiaBulanTarget: 1),
        ]);

        final hasil = await repository.getSchedulesByBaby('baby-1');

        expect(hasil.map((s) => s.usiaBulanTarget).toList(), [1, 3]);
        expect(hasil.every((s) => s.status == VaccineStatus.belum), isTrue);
      },
    );

    test('status SELESAI tidak ikut menjadi TERLEWAT', () async {
      await seed([
        model(
          scheduleId: 's-1',
          tanggalTarget: DateTime.now().subtract(const Duration(days: 90)),
          status: VaccineStatus.selesai,
        ),
      ]);

      final hasil = await repository.getSchedulesByBaby('baby-1');

      expect(hasil.single.status, VaccineStatus.selesai);
    });

    test('normalisasi hanya saat dibaca — isi Hive tidak diubah', () async {
      await seed([
        model(
          scheduleId: 's-1',
          tanggalTarget: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);

      final hasil = await repository.getSchedulesByBaby('baby-1');
      expect(hasil.single.status, VaccineStatus.terlewat);

      final box = await Hive.openBox<VaccineScheduleModel>(
        AppConstants.vaccineSchedulesBox,
      );
      expect(box.get('s-1')!.status, VaccineStatus.belum);
    });

    test(
      'getScheduleById menormalkan status dan aman untuk id tak dikenal',
      () async {
        await seed([
          model(
            scheduleId: 's-1',
            tanggalTarget: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ]);

        final overdue = await repository.getScheduleById('s-1');
        expect(overdue?.status, VaccineStatus.terlewat);

        expect(await repository.getScheduleById('tidak-ada'), isNull);
      },
    );

    test(
      'updateSchedule menyimpan SELESAI walau tanggal targetnya sudah lewat',
      () async {
        await seed([
          model(
            scheduleId: 's-1',
            tanggalTarget: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ]);

        final overdue = (await repository.getScheduleById('s-1'))!;
        await repository.updateSchedule(
          overdue.copyWith(
            status: VaccineStatus.selesai,
            tanggalRealisasi: DateTime.now(),
            catatanReaksi: 'Demam ringan',
          ),
        );

        final sesudah = await repository.getScheduleById('s-1');
        expect(sesudah?.status, VaccineStatus.selesai);
        expect(sesudah?.catatanReaksi, 'Demam ringan');

        final box = await Hive.openBox<VaccineScheduleModel>(
          AppConstants.vaccineSchedulesBox,
        );
        expect(box.get('s-1')!.status, VaccineStatus.selesai);
      },
    );
  });
}
