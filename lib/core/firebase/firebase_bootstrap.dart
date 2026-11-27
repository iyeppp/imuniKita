import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../env/env_config.dart';
import '../errors/failures.dart';
import 'firebase_config_check.dart';

/// Service bootstrap terpusat untuk inisialisasi Firebase Foundation.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _isInitialized = false;

  /// Error terakhir saat inisialisasi — berguna untuk diagnostik/UI.
  static Object? lastError;

  static bool get isInitialized => _isInitialized;

  /// Hanya platform yang punya konfigurasi di `firebase_options.dart`.
  static bool get isSupportedPlatform =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Inisialisasi Firebase Foundation.
  static Future<void> initialize() async {
    if (_isInitialized) return;
    lastError = null;

    if (!isSupportedPlatform) {
      debugPrint(
        'FirebaseBootstrap: platform ${defaultTargetPlatform.name} tidak '
        'didukung DefaultFirebaseOptions — Firebase dilewati, aplikasi tetap '
        'berjalan dengan Hive lokal.',
      );
      return;
    }

    final options = DefaultFirebaseOptions.currentPlatform;
    final issue = FirebaseConfigCheck.issue(options);
    if (issue != null) {
      final failure = FirebaseConfigFailure(issue);
      lastError = failure;
      debugPrint('FirebaseBootstrap: $issue');
      if (kDebugMode) throw failure;
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      await _connectToEmulators();
      _isInitialized = true;
      debugPrint(
        'FirebaseBootstrap: Firebase siap (project ${options.projectId}'
        '${EnvConfig.useEmulators ? ', emulator ${EnvConfig.emulatorHost}' : ''}).',
      );
    } catch (error) {
      lastError = error;
      debugPrint('FirebaseBootstrap: inisialisasi gagal — $error');
      if (kDebugMode) rethrow;
    }
  }

  /// Menghubungkan Auth & Firestore ke Firebase Emulator Suite saat: `kDebugMode` + `--dart-define=USE_EMULATOR=true`.
  static Future<void> _connectToEmulators() async {
    if (!kDebugMode || !EnvConfig.useEmulators) return;

    final host = EnvConfig.emulatorHost;
    FirebaseAuth.instance.useAuthEmulator(host, EnvConfig.authEmulatorPort);
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      EnvConfig.firestoreEmulatorPort,
    );

    debugPrint(
      'FirebaseBootstrap: emulator aktif di $host '
      '(auth:${EnvConfig.authEmulatorPort}, '
      'firestore:${EnvConfig.firestoreEmulatorPort}).',
    );
  }
}
