import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gaya visual [StatusBadge].
enum StatusBadgeStyle {
  /// Latar tipis + border senada — default, aman di atas kartu putih.
  tinted,

  /// Latar penuh warna solid + teks putih — untuk penekanan.
  filled,

  /// Hanya latar tipis tanpa border.
  soft,
}

/// Badge status/pill kecil yang seragam (komponen UI global).
///
/// Menggantikan `Chip` ad-hoc dan `Container` berulang untuk status vaksin,
/// suhu jurnal, label usia, badge "Aktif", dsb.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.style = StatusBadgeStyle.tinted,
    this.compact = false,
    this.textColor,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final StatusBadgeStyle style;

  /// Ukuran lebih kecil (font 10–11, padding rapat) untuk di dalam list.
  final bool compact;

  /// Warna teks kustom; default mengikuti [color] (atau putih untuk `filled`).
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 10.5 : 11.5;
    final horizontal = compact ? 8.0 : 10.0;
    final vertical = compact ? 3.0 : 5.0;

    late final Color background;
    late final Color border;
    late final Color foreground;

    switch (style) {
      case StatusBadgeStyle.filled:
        background = color;
        border = color;
        foreground = textColor ?? Colors.white;
      case StatusBadgeStyle.soft:
        background = color.withValues(alpha: 0.15);
        border = Colors.transparent;
        foreground = textColor ?? color;
      case StatusBadgeStyle.tinted:
        background = color.withValues(alpha: 0.15);
        border = color;
        foreground = textColor ?? color;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
