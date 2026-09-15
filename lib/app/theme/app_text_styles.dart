import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografi ImuniKita (Design System v1.0).
/// - Heading / Display : Baloo 2 (Rounded, geometric, bold playful)
/// - Body / Form / Label : Poppins (Clean, readable, friendly)
abstract class AppTextStyles {
  // ── Heading & Display (Baloo 2) ────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.baloo2(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
        height: 1.1,
      );

  static TextStyle get headingL => GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        height: 1.2,
      );

  static TextStyle get headingM => GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
        height: 1.25,
      );

  static TextStyle get headingS => GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        height: 1.3,
      );

  // ── Body & Form (Poppins) ──────────────────────────────────────────────
  static TextStyle get bodyL => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get bodyM => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
        height: 1.5,
      );

  static TextStyle get labelBold => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        letterSpacing: 0.2,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
      );

  // ── Legacy Aliases ─────────────────────────────────────────────────────
  static TextStyle get h1 => headingL;
  static TextStyle get h2 => headingM;
  static TextStyle get h3 => headingS;
  static TextStyle get h4 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      );

  static TextStyle get bodyLarge => bodyL;
  static TextStyle get bodyMedium => bodyM;
  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => labelBold;
  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      );
  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textHint,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        letterSpacing: 0.2,
      );
}
