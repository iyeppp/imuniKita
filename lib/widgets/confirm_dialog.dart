import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/app_colors.dart';

/// Dialog konfirmasi generik (komponen UI global — dev plan tabel
/// "Komponen UI Global / Shared Widgets").
///
/// Dipakai untuk aksi yang tidak bisa dibatalkan atau berisiko, mis. keluar
/// dari akun di layar Profil & Pengaturan.
abstract class ConfirmDialog {
  /// Tampilkan dialog dan kembalikan `true` bila user menekan tombol
  /// konfirmasi, `false` bila membatalkan atau menutup dialog.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Ya',
    String cancelLabel = 'Batal',
    bool isDestructive = false,
  }) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              cancelLabel,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.red : AppColors.teal,
              minimumSize: const Size(96, 44),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return hasil ?? false;
  }
}
