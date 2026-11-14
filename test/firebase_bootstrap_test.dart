import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imunikita/core/env/env_config.dart';
import 'package:imunikita/core/firebase/firebase_config_check.dart';
import 'package:imunikita/firebase_options.dart';

FirebaseOptions _options({
  String apiKey = 'AIzaSyB-real-key-1234567890',
  String appId = '1:987654321098:android:abcdef1234567890',
  String messagingSenderId = '987654321098',
  String projectId = 'imunikita-dev-f',
}) {
  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
  );
}

void main() {
  group('FirebaseConfigCheck — deteksi placeholder (P1)', () {
    test('menolak apiKey placeholder', () {
      final options = _options(apiKey: 'AIzaSyDevKeyForImuniKitaAndroid12345');

      expect(FirebaseConfigCheck.isPlaceholder(options), isTrue);
      expect(
        FirebaseConfigCheck.issue(options),
        contains('flutterfire configure'),
      );
    });

    test('menolak appId placeholder', () {
      final options = _options(appId: '1:1234567890:android:imunikita123456');

      expect(FirebaseConfigCheck.isPlaceholder(options), isTrue);
    });

    test('menerima konfigurasi asli untuk ENV dev', () {
      final options = _options();

      expect(FirebaseConfigCheck.isPlaceholder(options), isFalse);
      expect(FirebaseConfigCheck.issue(options), isNull);
    });

    test('menolak project yang tidak cocok dengan ENV', () {
      final options = _options(projectId: 'imunikita-prod-f');

      expect(FirebaseConfigCheck.isPlaceholder(options), isFalse);
      expect(FirebaseConfigCheck.issue(options), contains('tidak cocok'));
    });
  });

  group('EnvConfig — konfigurasi emulator (P3)', () {
    test('emulator nonaktif secara default', () {
      expect(EnvConfig.useEmulators, isFalse);
    });

    test('port emulator mengikuti Firebase Emulator Suite', () {
      expect(EnvConfig.authEmulatorPort, 9099);
      expect(EnvConfig.firestoreEmulatorPort, 8080);
    });
  });

  group('Konfigurasi project asli (P1)', () {
    test('firebase_options tidak lagi placeholder', () {
      expect(
        FirebaseConfigCheck.isPlaceholder(DefaultFirebaseOptions.android),
        isFalse,
      );
      expect(
        FirebaseConfigCheck.isPlaceholder(DefaultFirebaseOptions.ios),
        isFalse,
      );
      expect(
        FirebaseConfigCheck.isPlaceholder(DefaultFirebaseOptions.web),
        isFalse,
      );
    });

    test('projectId hasil configure cocok dengan EnvConfig (dev)', () {
      expect(DefaultFirebaseOptions.android.projectId, EnvConfig.projectId);
      expect(FirebaseConfigCheck.issue(DefaultFirebaseOptions.android), isNull);
    });
  });
}
