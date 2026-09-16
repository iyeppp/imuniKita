/// Representasi error tingkat domain.
///
/// Konvensi lapisan ini:
/// - `UseCase` **melempar** (`throw`) [Failure] saat operasi gagal.
/// - UI menangkapnya lewat `try/catch` (atau `AsyncValue.guard` bila memakai
///   `AsyncNotifier`), sehingga pesan error bisa ditampilkan langsung lewat
///   `failure.message` tanpa membongkar `Exception` mentah ke pengguna.
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
