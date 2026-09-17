import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../app/theme/app_colors.dart';

/// Tombol neo-brutalism reusable dengan border tebal dan drop shadow solid.
///
/// Mendukung state loading (CircularProgressIndicator) dan custom icon.
class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.teal,
    this.textColor = AppColors.darkText,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
    this.borderRadius = 12.0,
    this.borderWidth = 2.0,
    this.shadowOffset = const Offset(3, 3),
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = onPressed == null || isLoading;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.darkText,
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: effectiveDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          side: BorderSide(color: AppColors.darkText, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 6),
                    icon!,
                  ],
                ],
              ),
      ),
    );
  }
}
