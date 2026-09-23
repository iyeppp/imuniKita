import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Label kategori konten edukasi (dipakai kartu artikel, kartu kuis, dan
/// header Article Detail).
class EducationKategoriBadge extends StatelessWidget {
  const EducationKategoriBadge({super.key, required this.kategori, this.onTap});

  final String kategori;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          kategori,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.tealDark,
          ),
        ),
      ),
    );
  }
}
