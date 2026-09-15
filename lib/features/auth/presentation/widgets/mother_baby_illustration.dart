import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Ilustrasi Flat Karakter Ibu & Bayi ImuniKita.
/// Mengadopsi gaya referensi editorial Petdegree:
/// - Outline hitam tebal konsisten (#1A1A1A, 3.8px)
/// - Solid flat colors (tanpa gradasi, tanpa shading blur)
/// - Ekspresi hangat & dinamis: mata lengkung bahagia (~~), mulut tertawa, pipi merona
/// - Ibu menggendong dan memeluk bayi dengan penuh kasih sayang
class MotherBabyIllustration extends StatelessWidget {
  final double width;
  final double height;

  const MotherBabyIllustration({
    super.key,
    this.width = 280,
    this.height = 320,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _MotherBabyPainter(),
        size: Size(width, height),
      ),
    );
  }
}

class _MotherBabyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Normalisasi koordinat ke kanvas 300 x 340
    final scaleX = size.width / 300.0;
    final scaleY = size.height / 340.0;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Paints
    final blackOutline = Paint()
      ..color = AppColors.darkText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fineOutline = Paint()
      ..color = AppColors.darkText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final hairPaint = Paint()
      ..color = AppColors.darkText
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFFFFCCB0) // Tan hangat khas tropis
      ..style = PaintingStyle.fill;

    final clothesMother = Paint()
      ..color = const Color(0xFFE85438) // Coral-orange hangat dinamis
      ..style = PaintingStyle.fill;

    final babyClothes = Paint()
      ..color = AppColors.warmWhite
      ..style = PaintingStyle.fill;

    final blushPaint = Paint()
      ..color = AppColors.pinkLogo
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = AppColors.darkText
      ..style = PaintingStyle.fill;

    final tonguePaint = Paint()
      ..color = const Color(0xFFFF6F91)
      ..style = PaintingStyle.fill;

    // ─────────────────────────────────────────────────────────────────────────
    // 1. RAMBUT BELAKANG IBU (Massa besar rambut hitam mengalir di belakang)
    // ─────────────────────────────────────────────────────────────────────────
    final backHair = Path();
    backHair.moveTo(130, 80);
    backHair.cubicTo(120, 40, 190, 20, 235, 45);
    backHair.cubicTo(275, 70, 290, 130, 280, 200);
    backHair.cubicTo(270, 260, 245, 300, 230, 335);
    backHair.lineTo(190, 335);
    backHair.cubicTo(210, 260, 220, 200, 195, 150);
    backHair.close();

    canvas.drawPath(backHair, hairPaint);
    canvas.drawPath(backHair, blackOutline);

    // ─────────────────────────────────────────────────────────────────────────
    // 2. BADAN & BAJU IBU (Turtleneck coral-orange dengan outline)
    // ─────────────────────────────────────────────────────────────────────────
    final bodyPath = Path();
    bodyPath.moveTo(150, 185);
    bodyPath.cubicTo(130, 200, 115, 230, 105, 340);
    bodyPath.lineTo(240, 340);
    bodyPath.cubicTo(240, 280, 235, 220, 215, 185);
    bodyPath.close();

    canvas.drawPath(bodyPath, clothesMother);
    canvas.drawPath(bodyPath, blackOutline);

    // Kerah Turtleneck Ibu
    final collarPath = Path();
    collarPath.moveTo(160, 168);
    collarPath.lineTo(155, 192);
    collarPath.cubicTo(180, 202, 205, 196, 215, 178);
    collarPath.lineTo(210, 158);
    collarPath.cubicTo(190, 170, 175, 172, 160, 168);
    collarPath.close();

    canvas.drawPath(collarPath, clothesMother);
    canvas.drawPath(collarPath, blackOutline);

    // ─────────────────────────────────────────────────────────────────────────
    // 3. LEHER & KEPALA IBU
    // ─────────────────────────────────────────────────────────────────────────
    // Leher
    final neckPath = Path();
    neckPath.moveTo(170, 140);
    neckPath.lineTo(168, 175);
    neckPath.lineTo(202, 175);
    neckPath.lineTo(200, 138);
    neckPath.close();
    canvas.drawPath(neckPath, skinPaint);
    canvas.drawPath(neckPath, blackOutline);

    // Wajah / Kepala Ibu
    final headPath = Path();
    headPath.moveTo(152, 98);
    headPath.cubicTo(145, 132, 160, 162, 185, 160);
    headPath.cubicTo(215, 158, 230, 130, 226, 95);
    headPath.cubicTo(222, 60, 160, 62, 152, 98);
    headPath.close();

    canvas.drawPath(headPath, skinPaint);
    canvas.drawPath(headPath, blackOutline);

    // Pipi Merona Ibu (Blush oval pink)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(164, 126), width: 18, height: 12),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(216, 120), width: 18, height: 12),
      blushPaint,
    );

    // Telinga Ibu
    final earPath = Path();
    earPath.addArc(
      Rect.fromCircle(center: const Offset(227, 108), radius: 11),
      -1.5,
      3.0,
    );
    canvas.drawPath(earPath, skinPaint);
    canvas.drawPath(earPath, blackOutline);

    // Mata Kiri Ibu (Mata lengkung tersenyum lebar khas gaya kartun Petdegree)
    final eyeLeft = Path();
    eyeLeft.moveTo(160, 106);
    eyeLeft.cubicTo(168, 97, 178, 98, 184, 107);
    canvas.drawPath(eyeLeft, blackOutline);

    // Mata Kanan Ibu
    final eyeRight = Path();
    eyeRight.moveTo(196, 103);
    eyeRight.cubicTo(204, 94, 214, 95, 220, 104);
    canvas.drawPath(eyeRight, blackOutline);

    // Hidung Ibu (Kecil lucu dan minimalis)
    final nosePath = Path();
    nosePath.moveTo(189, 111);
    nosePath.cubicTo(192, 117, 188, 120, 184, 119);
    canvas.drawPath(nosePath, fineOutline);

    // Mulut Tertawa Lebar Ibu
    final mouthPath = Path();
    mouthPath.moveTo(175, 126);
    mouthPath.cubicTo(188, 124, 202, 124, 210, 127);
    mouthPath.cubicTo(206, 146, 185, 148, 175, 126);
    mouthPath.close();

    canvas.drawPath(mouthPath, mouthPaint);

    // Lidah Pink di dalam mulut
    canvas.save();
    canvas.clipPath(mouthPath);
    final tonguePath = Path();
    tonguePath.addOval(Rect.fromCircle(center: const Offset(195, 142), radius: 10));
    canvas.drawPath(tonguePath, tonguePaint);
    canvas.restore();
    canvas.drawPath(mouthPath, blackOutline);

    // ─────────────────────────────────────────────────────────────────────────
    // 4. PONI & RAMBUT DEPAN IBU (Swooping bangs tebal & stylish)
    // ─────────────────────────────────────────────────────────────────────────
    final bangsPath = Path();
    bangsPath.moveTo(148, 92);
    bangsPath.cubicTo(165, 58, 210, 60, 228, 88);
    bangsPath.cubicTo(210, 80, 185, 84, 172, 96);
    bangsPath.cubicTo(165, 82, 155, 85, 148, 92);
    bangsPath.close();

    canvas.drawPath(bangsPath, hairPaint);
    canvas.drawPath(bangsPath, blackOutline);

    // ─────────────────────────────────────────────────────────────────────────
    // 5. BAYI MUNGIL DALAM DEKAPAN (Chubby, riang, menghadap ibu)
    // ─────────────────────────────────────────────────────────────────────────
    // Badan Bayi (Baju warm white lembut)
    final babyBody = Path();
    babyBody.moveTo(60, 220);
    babyBody.cubicTo(50, 270, 75, 310, 125, 305);
    babyBody.cubicTo(145, 300, 155, 275, 150, 230);
    babyBody.cubicTo(140, 200, 85, 195, 60, 220);
    babyBody.close();

    canvas.drawPath(babyBody, babyClothes);
    canvas.drawPath(babyBody, blackOutline);

    // Kerah aksen baju bayi (Teal cerah)
    final babyCollar = Path();
    babyCollar.moveTo(76, 205);
    babyCollar.cubicTo(95, 218, 118, 214, 130, 200);
    babyCollar.cubicTo(116, 194, 92, 196, 76, 205);
    babyCollar.close();

    final collarPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.fill;
    canvas.drawPath(babyCollar, collarPaint);
    canvas.drawPath(babyCollar, fineOutline);

    // Kaki chubby bayi (sedikit nongol di bawah pelukan)
    final babyFoot = Path();
    babyFoot.addOval(Rect.fromCenter(center: const Offset(42, 280), width: 34, height: 26));
    canvas.save();
    canvas.rotate(-0.25);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(15, 290), width: 36, height: 26),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(15, 290), width: 36, height: 26),
      blackOutline,
    );
    canvas.restore();

    // Kepala & Pipi Chubby Bayi
    final babyHead = Path();
    babyHead.moveTo(70, 140);
    babyHead.cubicTo(50, 160, 52, 195, 80, 205);
    babyHead.cubicTo(115, 215, 145, 195, 142, 158);
    babyHead.cubicTo(138, 125, 95, 115, 70, 140);
    babyHead.close();

    canvas.drawPath(babyHead, skinPaint);
    canvas.drawPath(babyHead, blackOutline);

    // Rambut Bayi (Jambul lucu 3 helai hitam berdiri)
    final tuftHair = Path();
    tuftHair.moveTo(102, 122);
    tuftHair.cubicTo(98, 105, 108, 100, 112, 112);
    tuftHair.cubicTo(116, 98, 128, 104, 122, 120);
    tuftHair.close();
    canvas.drawPath(tuftHair, hairPaint);
    canvas.drawPath(tuftHair, fineOutline);

    // Telinga Bayi
    canvas.drawCircle(const Offset(62, 172), 9, skinPaint);
    canvas.drawCircle(const Offset(62, 172), 9, fineOutline);

    // Pipi Merah Bayi (Blush oval cerah)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(78, 180), width: 16, height: 11),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(124, 174), width: 16, height: 11),
      blushPaint,
    );

    // Mata Bayi (Melengkung tertawa sangat bahagia)
    final babyEyeLeft = Path();
    babyEyeLeft.moveTo(82, 160);
    babyEyeLeft.cubicTo(88, 152, 96, 152, 100, 160);
    canvas.drawPath(babyEyeLeft, blackOutline);

    final babyEyeRight = Path();
    babyEyeRight.moveTo(110, 158);
    babyEyeRight.cubicTo(116, 150, 124, 150, 128, 158);
    canvas.drawPath(babyEyeRight, blackOutline);

    // Hidung Mungil Bayi
    canvas.drawCircle(const Offset(104, 166), 2.2, Paint()..color = AppColors.darkText);

    // Mulut Senyum Bayi
    final babyMouth = Path();
    babyMouth.moveTo(94, 174);
    babyMouth.cubicTo(103, 186, 114, 186, 120, 175);
    babyMouth.close();
    canvas.drawPath(babyMouth, mouthPaint);
    canvas.save();
    canvas.clipPath(babyMouth);
    canvas.drawCircle(const Offset(107, 182), 6, tonguePaint);
    canvas.restore();
    canvas.drawPath(babyMouth, fineOutline);

    // Tangan Mungil Bayi (Merangkul ke arah dada/leher ibu)
    final babyHand = Path();
    babyHand.moveTo(125, 205);
    babyHand.cubicTo(145, 195, 160, 200, 168, 185);
    babyHand.cubicTo(174, 188, 172, 196, 162, 208);
    babyHand.cubicTo(150, 218, 135, 220, 125, 215);
    babyHand.close();
    canvas.drawPath(babyHand, skinPaint);
    canvas.drawPath(babyHand, fineOutline);

    // ─────────────────────────────────────────────────────────────────────────
    // 6. LENGAN DAN TANGAN IBU (Memeluk erat bayi dengan penuh kehangatan)
    // ─────────────────────────────────────────────────────────────────────────
    // Lengan Kiri Ibu (Mendukung pantat dan punggung bayi dari bawah)
    final leftArm = Path();
    leftArm.moveTo(185, 230);
    leftArm.cubicTo(170, 280, 120, 315, 65, 295);
    leftArm.cubicTo(55, 280, 50, 265, 75, 255);
    leftArm.cubicTo(115, 275, 150, 255, 165, 218);
    leftArm.close();

    canvas.drawPath(leftArm, clothesMother);
    canvas.drawPath(leftArm, blackOutline);

    // Tangan Ibu memeluk pantat bayi (Telapak tangan tan hangat dengan jari-jari)
    final handLeft = Path();
    handLeft.moveTo(76, 262);
    handLeft.cubicTo(60, 260, 50, 275, 55, 292);
    handLeft.cubicTo(62, 304, 85, 302, 92, 290);
    handLeft.close();
    canvas.drawPath(handLeft, skinPaint);
    canvas.drawPath(handLeft, fineOutline);

    // Jari-jari telapak kiri ibu
    canvas.drawLine(const Offset(68, 274), const Offset(76, 280), fineOutline);
    canvas.drawLine(const Offset(74, 282), const Offset(82, 287), fineOutline);

    // Lengan Kanan Ibu (Melintang menopang tubuh atas bayi)
    final rightArm = Path();
    rightArm.moveTo(130, 220);
    rightArm.cubicTo(155, 210, 190, 215, 210, 240);
    rightArm.lineTo(202, 265);
    rightArm.cubicTo(180, 245, 145, 240, 115, 250);
    rightArm.close();

    canvas.drawPath(rightArm, clothesMother);
    canvas.drawPath(rightArm, blackOutline);

    // Tangan Kanan Ibu menopang dada bayi
    final handRight = Path();
    handRight.moveTo(116, 245);
    handRight.cubicTo(100, 240, 95, 220, 110, 214);
    handRight.cubicTo(124, 210, 132, 230, 126, 248);
    handRight.close();
    canvas.drawPath(handRight, skinPaint);
    canvas.drawPath(handRight, fineOutline);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
