import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';

/// Helper terpusat untuk menampilkan SnackBar pesan sukses atau error.
class SnackbarHelper {
  SnackbarHelper._();

  /// Tampilkan SnackBar sukses (warna hijau)
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  /// Tampilkan SnackBar error (warna merah)
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }
}
