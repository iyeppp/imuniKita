/// Representasi error tingkat domain.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Pesan siap tampil untuk pengguna (Bahasa Indonesia).
  final String message;

  @override
  String toString() => message;
}

/// Kegagalan saat mengakses penyimpanan lokal (Hive CE / SharedPreferences).
class LocalStorageFailure extends Failure {
  const LocalStorageFailure([
    super.message = 'Gagal mengakses penyimpanan lokal perangkat.',
  ]);
}

/// Data yang dicari tidak ditemukan.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data yang dicari tidak ditemukan.']);
}

/// Input dari pengguna tidak lolos validasi.
class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Data yang dimasukkan belum valid.',
  ]);
}

/// Izin sistem ditolak (mis. akses galeri untuk foto profil bayi).
class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'Izin aplikasi ditolak. Aktifkan melalui pengaturan.',
  ]);
}

/// Error tak terduga — jaring terakhir sebelum error mentah naik ke UI.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Terjadi kesalahan tak terduga. Coba lagi sebentar lagi.',
  ]);
}

/// Kegagalan umum pada proses autentikasi (Firebase Auth atau fallback lokal).
class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Gagal memproses autentikasi. Coba lagi.',
  ]);
}

/// Email atau password tidak cocok dengan akun yang terdaftar.
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = 'Email atau password salah. Periksa kembali.',
  ]);
}

/// Email belum terdaftar (dipakai untuk mengarahkan user ke halaman daftar).
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([
    super.message = 'Email belum terdaftar. Silakan daftar terlebih dahulu.',
  ]);
}

/// Email sudah dipakai akun lain.
class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([
    super.message = 'Email ini sudah terdaftar. Silakan masuk.',
  ]);
}

/// Password tidak memenuhi kebijakan keamanan Firebase.
class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([
    super.message = 'Password terlalu lemah. Gunakan minimal 6 karakter.',
  ]);
}

/// Belum ada akun sama sekali di perangkat (mode lokal tanpa Firebase).
class NoAccountFailure extends AuthFailure {
  const NoAccountFailure([
    super.message = 'Belum ada akun terdaftar. Silakan daftar terlebih dahulu.',
  ]);
}

/// Tidak ada koneksi internet atau server tidak dapat dihubungi.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
  ]);
}

/// Server mengembalikan respon error (5xx / REST API error).
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Layanan server mengalami gangguan. Coba lagi nanti.',
  ]);
}

/// Konfigurasi Firebase belum valid (mis. `firebase_options.dart` masih placeholder atau project tidak cocok dengan `ENV`).
class FirebaseConfigFailure extends Failure {
  const FirebaseConfigFailure([
    super.message =
        'Konfigurasi Firebase belum valid. Jalankan `flutterfire configure`.',
  ]);
}
