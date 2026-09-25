import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/app/theme/app_theme.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/features/baby_profile/domain/entities/baby_entity.dart';
import 'package:imunikita/features/baby_profile/presentation/providers/active_baby_provider.dart';
import 'package:imunikita/features/baby_profile/presentation/providers/baby_provider.dart';
import 'package:imunikita/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:imunikita/features/growth/presentation/providers/growth_provider.dart';
import 'package:imunikita/features/immunization/presentation/providers/immunization_provider.dart';
import 'package:imunikita/hive_registrar.g.dart';
import 'package:imunikita/injection/dependency_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regresi Bug #53 — dashboard kosong/freeze untuk bayi berusia > 18 bulan.
///
/// Saat seluruh jadwal imunisasi sudah lewat, Dashboard menampilkan kartu
/// "Semua imunisasi telah diselesaikan! 🎉" yang berisi `ElevatedButton` di
/// dalam `Row`. Theme global memakai `minimumSize: Size(infinity, 52)` sehingga
/// tombol meminta lebar tak terbatas → assertion "BoxConstraints forces an
/// infinite width" saat layout, dan Dashboard gagal dirender.
///
/// Pengujian ini memakai `tester.runAsync` karena provider menyentuh I/O Hive
/// yang nyata (fake-async bawaan `testWidgets` akan menggantung).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'user-1';
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('imunikita_dashboard_test');
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
    await prefs.setString(AppConstants.prefUserId, userId);
    for (final box in [
      AppConstants.babiesBox,
      AppConstants.vaccineSchedulesBox,
      AppConstants.growthRecordsBox,
    ]) {
      await Hive.deleteBoxFromDisk(box);
    }
  });

  Future<void> siapkanDanRender(WidgetTester tester, int umurBulan) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.runAsync(() async {
      final now = DateTime.now();
      final lahir = DateTime(now.year, now.month - umurBulan, now.day);

      final created = await container
          .read(babyNotifierProvider.notifier)
          .addBaby(
            BabyEntity(
              babyId: 'baby-$umurBulan',
              userId: userId,
              namaAnak: 'Anak $umurBulan',
              tanggalLahir: lahir,
              jenisKelamin: BabyGender.laki,
              createdAt: now,
            ),
          );

      await container
          .read(syncBabyScheduleUseCaseProvider)
          .execute(
            babyId: created.babyId,
            namaAnak: created.namaAnak,
            tanggalLahir: created.tanggalLahir,
          );

      // Selesaikan provider sebelum render agar build widget bebas I/O.
      await container.read(activeBabyProvider.future);
      await container.read(immunizationProvider(created.babyId).future);
      await container.read(growthProvider(created.babyId).future);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('bayi <= 18 bulan menampilkan jadwal terdekat', (tester) async {
    await siapkanDanRender(tester, 5);

    expect(find.text('Anak 5'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bayi > 18 bulan (semua jadwal lewat) tidak crash', (
    tester,
  ) async {
    await siapkanDanRender(tester, 20);

    expect(find.text('Anak 20'), findsWidgets);
    expect(find.textContaining('Semua imunisasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
