import 'package:flutter/foundation.dart';

/// Konfigurasi environment aplikasi (Dev vs Prod).
///
/// Dibaca dari `--dart-define=ENV=dev` atau `ENV=prod`.
enum Environment { dev, prod }

class EnvConfig {
  EnvConfig._();

  static Environment get current {
    const envStr = String.fromEnvironment('ENV', defaultValue: 'dev');
    return envStr == 'prod' ? Environment.prod : Environment.dev;
  }

  static bool get isDev => current == Environment.dev;
  static bool get isProd => current == Environment.prod;

  static String get projectId => isProd ? 'imunikita-prod' : 'imunikita-dev';

  /// Host IP untuk emulator Android (`10.0.2.2`) vs iOS/Desktop (`localhost`).
  static String get emulatorHost {
    if (kIsWeb) return 'localhost';
    return defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
  }
}
