import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';

/// Logo Pill ImuniKita dengan gaya neo-brutalism.
/// Digunakan di LoginScreen dan screen lain yang memerlukan branding header.
class AppLogoPill extends StatelessWidget {
  const AppLogoPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          const Icon(Icons.vaccines, color: AppColors.darkText, size: 28),
          const SizedBox(width: 8),
          Text(
            'ImuniKita',
            style: GoogleFonts.baloo2(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
