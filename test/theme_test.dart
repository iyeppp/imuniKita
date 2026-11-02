import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/app/theme/theme_provider.dart';
import 'package:imunikita/core/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Theme Persistence & Provider Tests', () {
    test('Default ThemeMode harus ThemeMode.system bila belum ada preferensi', () async {
      final mode = await LocalStorageService.getThemeMode();
      expect(mode, equals(ThemeMode.system));
    });

    test('Menyimpan ThemeMode.light harus tersimpan dan terbaca kembali', () async {
      await LocalStorageService.setThemeMode(ThemeMode.light);
      final mode = await LocalStorageService.getThemeMode();
      expect(mode, equals(ThemeMode.light));
    });

    test('Menyimpan ThemeMode.dark harus tersimpan dan terbaca kembali', () async {
      await LocalStorageService.setThemeMode(ThemeMode.dark);
      final mode = await LocalStorageService.getThemeMode();
      expect(mode, equals(ThemeMode.dark));
    });

    test('themeModeProvider membaca dari SharedPreferences dan memperbarui state', () async {
      await LocalStorageService.setThemeMode(ThemeMode.dark);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Pastikan provider selesai loading
      final initialMode = await container.read(themeModeProvider.future);
      expect(initialMode, equals(ThemeMode.dark));

      // Ubah ke light
      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);

      final updatedMode = await container.read(themeModeProvider.future);
      expect(updatedMode, equals(ThemeMode.light));

      // Cek di LocalStorageService
      final persistedMode = await LocalStorageService.getThemeMode();
      expect(persistedMode, equals(ThemeMode.light));
    });
  });
}
