import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/app_colors.dart';

/// Judul seksi dengan aksi opsional di kanan (komponen UI global).
///
/// Menggantikan `Text` + `GoogleFonts.baloo2` yang berulang di Dashboard,
/// Profil & Pengaturan, Detail Vaksin, dan Article Detail.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.padding,
  });

  final String title;

  /// Bila [actionLabel] + [onAction] diisi, tombol teks tampil di kanan.
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final judul = Text(
      title,
      style: GoogleFonts.baloo2(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
    );

    if (actionLabel == null || onAction == null) {
      return Padding(padding: padding ?? EdgeInsets.zero, child: judul);
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: judul),
          TextButton.icon(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
            icon: actionIcon == null
                ? const SizedBox.shrink()
                : Icon(actionIcon, size: 16, color: AppColors.teal),
            label: Text(
              actionLabel!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
