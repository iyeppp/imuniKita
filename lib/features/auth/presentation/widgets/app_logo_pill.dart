import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';

/// Logo Pill ImuniKita dengan gaya neo-brutalism.
/// Menggunakan logo karakter jarum suntik terbaru (`syringe_logo.png`).
/// Digunakan di LoginScreen dan screen lain yang memerlukan branding header.
class AppLogoPill extends StatelessWidget {
  const AppLogoPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pinkLogo,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.darkText, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.darkText,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/syringe_logo.png',
            width: 42,
            height: 42,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Text(
            'ImuniKita',
            style: GoogleFonts.baloo2(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
