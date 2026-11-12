import 'package:firebase_core/firebase_core.dart';

import '../env/env_config.dart';

/// Validasi konfigurasi Firebase sebelum aplikasi memakainya.
///
/// Tujuan: misconfiguration (mis. `firebase_options.dart` masih berisi nilai
/// placeholder) tidak lagi gagal secara senyap. Deteksi dilakukan **tanpa**
/// memanggil jaringan, sehingga aman diuji sebagai unit test.
class FirebaseConfigCheck {
  FirebaseConfigCheck._();

  /// Penanda yang hanya muncul pada `firebase_options.dart` contoh/placeholder.
  static const List<String> placeholderMarkers = [
    'AIzaSyDevKeyFor',
    'imunikita123456',
  ];

  /// Perintah yang harus dijalankan untuk mengisi kredensial asli.
  static const String configureCommand =
      'flutterfire configure --project=imunikita-dev-f '
      '--platforms=android,ios,web';

  static bool isPlaceholder(FirebaseOptions options) {
    final fingerprint = [
      options.apiKey,
      options.appId,
      options.messagingSenderId,
      options.projectId,
    ].join('|').toLowerCase();

    return placeholderMarkers.any(
      (marker) => fingerprint.contains(marker.toLowerCase()),
    );
  }

  /// Mengembalikan pesan masalah bila konfigurasi tidak layak dipakai,
  /// atau `null` bila konfigurasi terlihat benar.
  static String? issue(FirebaseOptions options) {
    if (isPlaceholder(options)) {
      return 'Kredensial Firebase masih placeholder (bukan project asli). '
          'Jalankan: $configureCommand';
    }

    if (options.projectId != EnvConfig.projectId) {
      return 'Project Firebase "${options.projectId}" tidak cocok dengan ENV '
          '"${EnvConfig.projectId}". Periksa lib/firebase_options.dart atau '
          'jalankan ulang dengan --dart-define=ENV=prod.';
    }

    return null;
  }
}
