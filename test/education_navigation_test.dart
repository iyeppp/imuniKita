import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/constants/app_constants.dart';
import 'package:imunikita/features/education/presentation/screens/education_hub_screen.dart';
import 'package:imunikita/hive_registrar.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regresi bug navigasi: halaman Edukasi sebelumnya tidak punya tombol
/// kembali karena `/education` adalah route top-level dan dibuka dengan `go`
/// (tumpukan hanya berisi satu halaman, jadi tidak ada yang bisa di-`pop`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('imunikita_edu_nav_test');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await Hive.deleteBoxFromDisk(AppConstants.educationQuizScoresBox);
  });

  GoRouter routerTest({required String awal}) {
    return GoRouter(
      initialLocation: awal,
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Halaman Dashboard'),
                    ElevatedButton(
                      onPressed: () => context.push('/education'),
                      child: const Text('Buka Edukasi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/education',
          builder: (_, _) => const EducationHubScreen(),
        ),
      ],
    );
  }

  Future<void> pumpAplikasi(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    // `pumpAndSettle` untuk menyelesaikan transisi halaman dan build ulang
    // router; thumbnail konten memakai `CachedNetworkImage` yang di test
    // langsung jatuh ke placeholder (tanpa animasi tak berujung).
    await tester.pumpAndSettle();
  }

  testWidgets('dibuka langsung (tanpa riwayat) → tombol kembali ke Dashboard', (
    tester,
  ) async {
    final router = routerTest(awal: '/education');
    addTearDown(router.dispose);

    await pumpAplikasi(tester, router);

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Halaman Dashboard'), findsOneWidget);
  });

  testWidgets('dibuka lewat push → tombol kembali muncul dan mem-pop halaman', (
    tester,
  ) async {
    final router = routerTest(awal: '/dashboard');
    addTearDown(router.dispose);

    await pumpAplikasi(tester, router);

    await tester.tap(find.text('Buka Edukasi'));
    await tester.pumpAndSettle();
    expect(find.text('Artikel'), findsOneWidget);

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Halaman Dashboard'), findsOneWidget);
  });
}
