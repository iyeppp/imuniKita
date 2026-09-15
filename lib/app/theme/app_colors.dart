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
  static const Color warning = yellow;
  static const Color info    = teal;
}
