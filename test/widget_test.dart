// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:imunikita/app/router/app_router.dart';
import 'package:imunikita/app/theme/app_theme.dart';
import 'package:imunikita/features/auth/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('AppTheme.lightTheme dapat dibangun', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: Text('ImuniKita'))),
      ),
    );

    expect(find.text('ImuniKita'), findsOneWidget);
  });

  test('AppRoutes berisi path yang diharapkan', () {
    expect(AppRoutes.splash, '/');
    expect(AppRoutes.dashboard, '/dashboard');
  });

  testWidgets('SplashScreen menampilkan elemen visual sesuai design system', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Initial pump
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Si kecil,\nterlindungi'), findsOneWidget);
    expect(find.text('Jadwal imunisasi dalam genggamanmu'), findsOneWidget);
  });
}


