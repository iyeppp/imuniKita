import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/app_colors.dart';

/// Avatar bayi: foto profil lokal bila ada, jika tidak inisial nama
/// (komponen UI global).
///
/// Menyatukan tiga implementasi berbeda yang sebelumnya ditulis ulang di
/// Dashboard (2×), Profil & Pengaturan, dan Kelola Profil Anak.
class BabyAvatar extends StatelessWidget {
  const BabyAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String name;

  /// Path file foto di perangkat; diabaikan bila file tidak ditemukan.
  final String? photoPath;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final file = photoPath == null ? null : File(photoPath!);
    final ImageProvider? foto = (file != null && file.existsSync())
        ? FileImage(file)
        : null;

    final trimmed = name.trim();
    final inisial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? AppColors.teal.withValues(alpha: 0.15),
      backgroundImage: foto,
      child: foto != null
          ? null
          : Text(
              inisial,
              style: GoogleFonts.baloo2(
                fontSize: radius * 0.82,
                fontWeight: FontWeight.w800,
                color: foregroundColor ?? AppColors.tealDark,
              ),
            ),
    );
  }
}
