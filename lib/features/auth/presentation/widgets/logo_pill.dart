import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

/// Icon mark ImuniKita:
/// Lingkaran putih beroutline hitam dengan tetes vaksin teal dipeluk dua lengan coral.
class ImuniKitaIconMark extends StatelessWidget {
  final double size;

  const ImuniKitaIconMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.darkText,
          width: 2.2,
        ),
      ),
      child: CustomPaint(
        painter: _IconMarkPainter(),
      ),
    );
  }
}

class _IconMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Tetes Vaksin (Teal) di bagian tengah atas
    final dropPath = Path();
    dropPath.moveTo(w * 0.5, h * 0.22);
    // Lengkungan kanan
    dropPath.cubicTo(w * 0.68, h * 0.44, w * 0.70, h * 0.62, w * 0.5, h * 0.66);
    // Lengkungan kiri
    dropPath.cubicTo(w * 0.30, h * 0.62, w * 0.32, h * 0.44, w * 0.5, h * 0.22);
    dropPath.close();

    final dropFill = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.fill;
    final dropStroke = Paint()
      ..color = AppColors.darkText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(dropPath, dropFill);
    canvas.drawPath(dropPath, dropStroke);

    // Titik kilau kecil di tetesan
    final shinePaint = Paint()
      ..color = AppColors.warmWhite.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.43, h * 0.46), w * 0.05, shinePaint);

    // 2. Lengan Pelindung (Coral) memeluk dari bawah
    final armPath = Path();
    // Lengan kiri melengkung memeluk
    armPath.moveTo(w * 0.22, h * 0.60);
    armPath.cubicTo(w * 0.26, h * 0.78, w * 0.42, h * 0.82, w * 0.5, h * 0.82);
    armPath.cubicTo(w * 0.58, h * 0.82, w * 0.74, h * 0.78, w * 0.78, h * 0.60);
    armPath.cubicTo(w * 0.70, h * 0.70, w * 0.58, h * 0.73, w * 0.5, h * 0.73);
    armPath.cubicTo(w * 0.42, h * 0.73, w * 0.30, h * 0.70, w * 0.22, h * 0.60);
    armPath.close();

    final armFill = Paint()
      ..color = AppColors.coral
      ..style = PaintingStyle.fill;
    final armStroke = Paint()
      ..color = AppColors.darkText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(armPath, armFill);
    canvas.drawPath(armPath, armStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logo Pill resmi ImuniKita sesuai Section 3.1 Design System:
/// - Background: Pink (#F9A8D4)
/// - Outline: Hitam tebal (#1A1A1A, 2.8px)
/// - Icon Mark + Wordmark Baloo 2 Bold
class ImuniKitaLogoPill extends StatelessWidget {
  final double scale;

  const ImuniKitaLogoPill({
    super.key,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 7 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.pinkLogo,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.darkText,
          width: 2.8 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText,
            offset: Offset(2.5 * scale, 2.5 * scale),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ImuniKitaIconMark(size: 30 * scale),
          SizedBox(width: 8 * scale),
          Text(
            'ImuniKita',
            style: GoogleFonts.baloo2(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
