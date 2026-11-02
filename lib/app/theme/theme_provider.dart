import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/local_storage_service.dart';

/// Provider reaktif untuk manajemen state tema aplikasi (Follow System, Light, Dark).
final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    return LocalStorageService.getThemeMode();
  }

  /// Memperbarui mode tema aplikasi dan menyimpannya secara permanen ke SharedPreferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    await LocalStorageService.setThemeMode(mode);
  }
}
