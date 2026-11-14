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

  /// ID project Firebase yang dipakai sesuai `ENV`.
  ///
  /// Catatan: project Firebase tim memakai akhiran `-f`
  /// (`imunikita-dev-f` / `imunikita-prod-f`), bukan `imunikita-dev`.
  static String get projectId =>
      isProd ? 'imunikita-prod-f' : 'imunikita-dev-f';

  /// Host IP untuk emulator Android (`10.0.2.2`) vs iOS/Desktop (`localhost`).
  static String get emulatorHost {
    if (kIsWeb) return 'localhost';
    return defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
  }

  // ── Firebase Emulator Suite ────────────────────────────────────────────────
  /// Aktifkan koneksi Auth/Firestore ke emulator lokal.
  ///
  /// Default **nonaktif** agar aplikasi memakai project cloud `imunikita-dev-f`.
  /// Jalankan: `flutter run --dart-define=USE_EMULATOR=true`.
  static bool get useEmulators =>
      const bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
}
