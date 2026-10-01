import 'package:flutter/material.dart';

/// Palet warna resmi ImuniKita (Design System v1.0).
/// Mengacu pada DNA Visual Petdegree: Bold Flat Illustration & High Contrast.
abstract class AppColors {
  // ── Primary Palette ───────────────────────────────────────────────────
  static const Color coral      = Color(0xFFF0856A); // Background dominan hero/splash
  static const Color teal       = Color(0xFF38B2AC); // Blok bawah, CTA button, accent
  static const Color darkText   = Color(0xFF1A1A1A); // Outline konsisten, teks gelap
  static const Color warmWhite  = Color(0xFFFFFDE8); // Confetti dot besar, teks di atas coral
  static const Color yellow     = Color(0xFFFAC532); // Confetti dot aksen, highlight
  static const Color red        = Color(0xFFD94F3D); // Confetti dot kecil, status terlewat

  // ── Extended / Secondary ──────────────────────────────────────────────
  static const Color pinkLogo   = Color(0xFFF9A8D4); // Pill background logo, blush pipi
  static const Color cream      = Color(0xFFFAF6F0); // Card background dalam app
  static const Color tealDark   = Color(0xFF2A8A85); // Pressed state button teal
  static const Color coralLight = Color(0xFFF7B09C); // Baju bayi / variasi aksen
  static const Color green      = Color(0xFF34C78B); // Status 'Selesai'
  static const Color grey       = Color(0xFF888888);
  static const Color skin       = Color(0xFFF2C49B); // Tone kulit karakter ibu & bayi

  // ── Status Vaksin ─────────────────────────────────────────────────────
  static const Color statusDone      = Color(0xFF34C78B); // ✅ Selesai
  static const Color statusScheduled = Color(0xFF38B2AC); // 🔵 Terjadwal
  static const Color statusMissed    = Color(0xFFD94F3D); // 🔴 Terlewat
  static const Color statusWarning   = Color(0xFFFAC532); // ⚠️  < 7 hari

  // ── Legacy Aliases / Fallbacks ─────────────────────────────────────────
  static const Color primary        = teal;
  static const Color primaryLight   = Color(0xFF4ECDC4);
  static const Color primaryLighter = Color(0xFFE0F7F6);
  static const Color primaryDark    = tealDark;

  static const Color secondary        = coral;
  static const Color secondaryLight   = coralLight;
  static const Color secondaryLighter = Color(0xFFFFECE6);

  static const Color background = cream;
  static const Color surface    = warmWhite;
  static const Color border     = darkText;
  static const Color divider    = Color(0xFFE5E7EB);

  static const Color textPrimary   = darkText;
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textHint      = grey;
  static const Color textOnPrimary = darkText;

  static const Color error   = red;
  static const Color success = green;
<<<<<<< Updated upstream
  static const Color warning = yellow;
  static const Color info    = teal;
=======

  // ── Dark Mode Palette ──────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121214);
  static const Color darkSurface = Color(0xFF1E1E24);
  static const Color darkSurfaceVariant = Color(0xFF2A2A32);
  static const Color darkBorder = Color(0xFF383842);
  static const Color darkDivider = Color(0xFF2E2E38);

  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextHint = Color(0xFF71717A);
  static const Color darkPrimaryLighter = Color(0xFF1B3836);

  // ── Theme-Aware Dynamic Helpers ──────────────────────────────────────
  /// Cek apakah mode gelap sedang aktif pada [context].
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Warna latar belakang Scaffold (cream di mode terang, darkBackground di mode gelap).
  static Color backgroundOf(BuildContext context) {
    return isDarkMode(context) ? darkBackground : background;
  }

  /// Warna permukaan/kartu (putih di mode terang, darkSurface di mode gelap).
  static Color surfaceOf(BuildContext context) {
    return isDarkMode(context) ? darkSurface : surface;
  }

  /// Warna permukaan varian/card terangkat (cream di mode terang, darkSurfaceVariant di mode gelap).
  static Color creamOf(BuildContext context) {
    return isDarkMode(context) ? darkSurfaceVariant : cream;
  }

  /// Warna teks utama (darkText #1A1A1A di mode terang, darkTextPrimary #F3F4F6 di mode gelap).
  static Color textPrimaryOf(BuildContext context) {
    return isDarkMode(context) ? darkTextPrimary : textPrimary;
  }

  /// Warna teks sekunder (#4A4A4A di mode terang, darkTextSecondary #A1A1AA di mode gelap).
  static Color textSecondaryOf(BuildContext context) {
    return isDarkMode(context) ? darkTextSecondary : textSecondary;
  }

  /// Warna teks petunjuk/hint (#6B7280 di mode terang, darkTextHint #71717A di mode gelap).
  static Color textHintOf(BuildContext context) {
    return isDarkMode(context) ? darkTextHint : textHint;
  }

  /// Warna outline/teks gelap (darkText di mode terang, darkTextPrimary di mode gelap).
  static Color darkTextOf(BuildContext context) {
    return isDarkMode(context) ? darkTextPrimary : darkText;
  }

  /// Warna border (#E2E8F0 di mode terang, darkBorder di mode gelap).
  static Color borderOf(BuildContext context) {
    return isDarkMode(context) ? darkBorder : border;
  }

  /// Warna pemisah/divider (#E5E7EB di mode terang, darkDivider di mode gelap).
  static Color dividerOf(BuildContext context) {
    return isDarkMode(context) ? darkDivider : divider;
  }

  /// Warna latar belakang tint primer (E0F7F6 di mode terang, darkPrimaryLighter di mode gelap).
  static Color primaryLighterOf(BuildContext context) {
    return isDarkMode(context) ? darkPrimaryLighter : primaryLighter;
  }

  /// Warna bayangan neo-brutalist (darkText #1A1A1A di mode terang,
  /// darkBorder #383842 di mode gelap agar tidak hilang di atas surface gelap).
  static Color shadowOf(BuildContext context) {
    return isDarkMode(context) ? darkBorder : darkText;
  }
>>>>>>> Stashed changes
}
