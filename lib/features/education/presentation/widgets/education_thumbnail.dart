import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/education_mock_datasource.dart';

/// Thumbnail/hero konten edukasi.
///
/// Konten UTS memakai URL gambar eksternal, jadi widget ini selalu punya
/// *fallback*: bila `imageUrl` kosong, gagal dimuat, atau perangkat sedang
/// offline, yang tampil adalah gradien warna kategori + ikon — bukan error
/// atau kotak kosong.
class EducationThumbnail extends StatelessWidget {
  const EducationThumbnail({
    super.key,
    required this.kategori,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.iconSize = 28,
  });

  final String kategori;
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final double iconSize;

  Color get _warnaKategori => switch (kategori) {
    EducationKategori.imunisasi => AppColors.coral,
    EducationKategori.nutrisi => AppColors.teal,
    EducationKategori.tumbuhKembang => AppColors.pinkLogo,
    EducationKategori.mpasi => AppColors.yellow,
    _ => AppColors.grey,
  };

  IconData get _ikonKategori => switch (kategori) {
    EducationKategori.imunisasi => Icons.vaccines,
    EducationKategori.nutrisi => Icons.emoji_food_beverage,
    EducationKategori.tumbuhKembang => Icons.child_care,
    EducationKategori.mpasi => Icons.rice_bowl,
    _ => Icons.menu_book,
  };

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.isEmpty
            ? _fallback()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => _fallback(),
                errorWidget: (_, _, _) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    final warna = _warnaKategori;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [warna.withValues(alpha: 0.9), warna.withValues(alpha: 0.55)],
        ),
      ),
      child: Center(
        child: Icon(_ikonKategori, color: AppColors.warmWhite, size: iconSize),
      ),
    );
  }
}
