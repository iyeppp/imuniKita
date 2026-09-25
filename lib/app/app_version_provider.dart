import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants/app_constants.dart';

/// Versi aplikasi yang sedang berjalan, dibaca dari metadata platform.
///
/// Temuan #20: sebelumnya layar Profil menampilkan `AppConstants.appVersion`
/// yang disamakan **manual** dengan `version:` di `pubspec.yaml` sehingga rawan
/// *drift*. Kini dibaca langsung dari `package_info_plus`.
///
/// Bila plugin gagal (mis. di lingkungan test tanpa platform), nilainya jatuh
/// kembali ke `AppConstants.appVersion` agar UI tetap menampilkan sesuatu.
final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final build = info.buildNumber.isEmpty ? '' : '+${info.buildNumber}';
    return '${info.version}$build';
  } catch (_) {
    return AppConstants.appVersion;
  }
});
