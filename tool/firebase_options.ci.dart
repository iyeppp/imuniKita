// Template konfigurasi Firebase untuk CI/unit test.
//
// File ini SENGAJA tidak berisi API key asli. Tujuannya agar:
// - `flutter analyze` dan `flutter test` di CI tetap bisa dikompilasi tanpa
//   menyimpan kredensial di repositori;
// - tidak ada secret yang perlu dirotasi bila repo publik.
//
// Build aplikasi yang benar-benar memakai Firebase tetap memerlukan
// `lib/firebase_options.dart` hasil `flutterfire configure` (di-ignore git),
// yang memuat API key asli di mesin developer.
//
// CI menyalin file ini sebelum analyze/test: lihat `.github/workflows/ci.yaml`.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Nilai appId/projectId bukan secret (memang tertanam di aplikasi), tetapi
  // API key sengaja diisi placeholder agar tidak memicu secret scanning.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'ci-placeholder',
    appId: '1:219754293644:web:3bcc668cc1574760f8cea9',
    messagingSenderId: '219754293644',
    projectId: 'imunikita-dev-f',
    authDomain: 'imunikita-dev-f.firebaseapp.com',
    storageBucket: 'imunikita-dev-f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ci-placeholder',
    appId: '1:219754293644:android:092c762cf358018cf8cea9',
    messagingSenderId: '219754293644',
    projectId: 'imunikita-dev-f',
    storageBucket: 'imunikita-dev-f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ci-placeholder',
    appId: '1:219754293644:ios:b8d6b4087ece42def8cea9',
    messagingSenderId: '219754293644',
    projectId: 'imunikita-dev-f',
    storageBucket: 'imunikita-dev-f.firebasestorage.app',
    iosBundleId: 'com.imunikita.app',
  );
}
