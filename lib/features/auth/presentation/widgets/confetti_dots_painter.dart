import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Model posisi dan ukuran dot confetti sesuai Section 5 ImuniKita Design System.
class ConfettiDot {
  final double relX; // 0.0 - 1.0 lebar layar
  final double relY; // 0.0 - 1.0 tinggi zona atas
  final double radius;
  final Color color;

  const ConfettiDot({
    required this.relX,
    required this.relY,
    required this.radius,
    required this.color,
  });
}

/// CustomPainter untuk sistem confetti dots khas ImuniKita & Petdegree branding:
/// - 3 variasi ukuran: XL, M, S
/// - Warna: Warm White (#FFFDE8), Bold Yellow (#FAC532), Accent Red (#D94F3D)
/// - Solid flat tanpa border/outline, beberapa overlap dan terpotong tepi.
class ConfettiDotsPainter extends CustomPainter {
  final double animationProgress;

  // Koordinat kurasi desainer agar komposisi seimbang di sekitar karakter
  static const List<ConfettiDot> dots = [
    // Dots XL (Besar, beberapa di tepi/sudut)
    ConfettiDot(relX: -0.05, relY: 0.28, radius: 55, color: AppColors.warmWhite),
    ConfettiDot(relX: 1.04, relY: 0.18, radius: 48, color: AppColors.yellow),
    ConfettiDot(relX: 0.88, relY: 0.58, radius: 42, color: AppColors.warmWhite),

    // Dots M (Sedang, tersebar dinamis)
    ConfettiDot(relX: 0.12, relY: 0.12, radius: 24, color: AppColors.yellow),
    ConfettiDot(relX: 0.82, relY: 0.32, radius: 26, color: AppColors.red),
    ConfettiDot(relX: 0.06, relY: 0.54, radius: 28, color: AppColors.yellow),
    ConfettiDot(relX: 0.28, relY: 0.22, radius: 22, color: AppColors.warmWhite),
    ConfettiDot(relX: 0.72, relY: 0.48, radius: 20, color: AppColors.warmWhite),

    // Dots S (Kecil, penyeimbang visual)
    ConfettiDot(relX: 0.22, relY: 0.07, radius: 10, color: AppColors.warmWhite),
    ConfettiDot(relX: 0.76, relY: 0.09, radius: 11, color: AppColors.yellow),
    ConfettiDot(relX: 0.94, relY: 0.42, radius: 9, color: AppColors.warmWhite),
    ConfettiDot(relX: 0.18, relY: 0.42, radius: 12, color: AppColors.red),
    ConfettiDot(relX: 0.38, relY: 0.15, radius: 8, color: AppColors.yellow),
    ConfettiDot(relX: 0.64, relY: 0.22, radius: 10, color: AppColors.red),
    ConfettiDot(relX: 0.86, relY: 0.72, radius: 14, color: AppColors.yellow),
    ConfettiDot(relX: 0.14, relY: 0.70, radius: 12, color: AppColors.warmWhite),
  ];

  ConfettiDotsPainter({this.animationProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (animationProgress <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < dots.length; i++) {
      final dot = dots[i];

      // Staggered pop-in animation effect
      final dotDelay = (i / dots.length) * 0.5;
      final localProgress = ((animationProgress - dotDelay) / 0.5).clamp(0.0, 1.0);
      if (localProgress <= 0) continue;

      // Elastic / overshoot scale effect
      final curvedScale = Curves.easeOutBack.transform(localProgress);

      paint.color = dot.color.withValues(alpha: localProgress.clamp(0.0, 1.0));
      final center = Offset(dot.relX * size.width, dot.relY * size.height);
      canvas.drawCircle(center, dot.radius * curvedScale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiDotsPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}
