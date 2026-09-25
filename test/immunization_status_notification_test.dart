import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/core/utils/notification_helper.dart';
import 'package:imunikita/features/immunization/data/models/vaccine_schedule_model.dart';
import 'package:imunikita/features/immunization/domain/entities/vaccine_schedule_entity.dart';
import 'package:imunikita/features/immunization/presentation/providers/immunization_provider.dart';
import 'package:imunikita/hive_registrar.g.dart';

/// Test Bug #7 — `ImmunizationNotifier.updateStatus` harus membatalkan
/// notifikasi H-7 & H-1 saat sebuah jadwal ditandai `SELESAI`, agar
/// pengingat tidak tetap muncul untuk vaksin yang sudah diberikan.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kanal = MethodChannel('dexterous.com/flutter/local_notifications');
  const babyId = 'baby-1';
  const scheduleId = 's-1';

  late Directory tempDir;
  late List<MethodCall> panggilan;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'imunikita_notif_status_test',
    );
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    panggilan = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(kanal, (call) async {
          panggilan.add(call);
          return null;
        });
    AndroidFlutterLocalNotificationsPlugin.registerWith();

    await Hive.deleteBoxFromDisk(AppConstants.vaccineSchedulesBox);
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(kanal, null);
  });

  Future<void> seed({required String status, DateTime? tanggalTarget}) async {
    final box = await Hive.openBox<VaccineScheduleModel>(
      AppConstants.vaccineSchedulesBox,
    );
    await box.put(
      scheduleId,
      VaccineScheduleModel(
        scheduleId: scheduleId,
        babyId: babyId,
        namaVaksin: 'BCG',
        deskripsi: 'Deskripsi',
        usiaBulanTarget: 1,
        tanggalTarget:
            tanggalTarget ?? DateTime.now().add(const Duration(days: 10)),
        status: status,
      ),
    );
  }

  test('menandai jadwal SELESAI membatalkan notifikasi H-7 & H-1', () async {
    await seed(status: VaccineStatus.belum);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(immunizationProvider(babyId).notifier)
        .updateStatus(
          scheduleId,
          VaccineStatus.selesai,
          realisasiDate: DateTime.now(),
          reaksi: 'Tidak ada keluhan',
        );

    final idH7 = NotificationHelper.notificationId(scheduleId, 7);
    final idH1 = NotificationHelper.notificationId(scheduleId, 1);

    final idDibatalkan = panggilan
        .where((c) => c.method == 'cancel')
        .map((c) => (c.arguments as Map)['id'])
        .toSet();

    expect(idDibatalkan, containsAll([idH7, idH1]));

    final hasil = await container.read(immunizationProvider(babyId).future);
    final jadwal = hasil.firstWhere((s) => s.scheduleId == scheduleId);
    expect(jadwal.status, VaccineStatus.selesai);
    expect(jadwal.catatanReaksi, 'Tidak ada keluhan');
  });

  test(
    'mengubah status ke selain SELESAI tidak membatalkan notifikasi',
    () async {
      await seed(status: VaccineStatus.belum);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(immunizationProvider(babyId).notifier)
          .updateStatus(scheduleId, VaccineStatus.belum);

      expect(panggilan.where((c) => c.method == 'cancel'), isEmpty);
    },
  );
}
