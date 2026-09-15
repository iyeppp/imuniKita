import 'package:flutter/material.dart';

/// Palet warna resmi ImuniKita.
/// Gunakan konstanta ini di seluruh codebase — jangan hardcode hex langsung.
abstract class AppColors {
  // ── Primary (Medical Blue) ────────────────────────────────────────────
  static const Color primary        = Color(0xFF1565C0);
  static const Color primaryLight   = Color(0xFF1E88E5);
  static const Color primaryLighter = Color(0xFFBBDEFB);
  static const Color primaryDark    = Color(0xFF0D47A1);

  // ── Secondary (Health Green) ──────────────────────────────────────────
  static const Color secondary        = Color(0xFF2E7D32);
  static const Color secondaryLight   = Color(0xFF43A047);
  static const Color secondaryLighter = Color(0xFFC8E6C9);

  // ── Status Vaksin ─────────────────────────────────────────────────────
  static const Color statusDone      = Color(0xFF57CC99); // ✅ Selesai
  static const Color statusScheduled = Color(0xFF4FC3F7); // 🔵 Terjadwal
  static const Color statusMissed    = Color(0xFFEF476F); // 🔴 Terlewat
  static const Color statusWarning   = Color(0xFFF9C74F); // ⚠️  < 7 hari

  // ── Neutral ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color divider    = Color(0xFFF1F5F9);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ──────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color info    = Color(0xFF0277BD);
}
