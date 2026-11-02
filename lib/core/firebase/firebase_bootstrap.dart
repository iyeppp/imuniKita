import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Service bootstrap terpusat untuk inisialisasi Firebase Foundation.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inisialisasi Firebase Foundation.
  ///
  /// Dibungkus `try-catch` agar kegagalan inisialisasi (mis. pada unit test atau
  /// lingkungan tanpa jaringan) tidak menggagalkan boot aplikasi lokal (Hive).
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('FirebaseBootstrap: Inisialisasi Firebase berhasil.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseBootstrap: Inisialisasi Firebase dilewati/gagal: $e');
      }
    }
  }
}
