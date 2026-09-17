/// Validasi umum untuk formulir autentikasi ImuniKita.
class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegExp =
      RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validasi format email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi panjang password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }
    return null;
  }

  /// Validasi konfirmasi password
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != originalPassword) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Validasi teks wajib (nama, telepon, kota, dll.)
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }
}
