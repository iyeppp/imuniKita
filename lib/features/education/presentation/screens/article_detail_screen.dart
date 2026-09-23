import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/article_model.dart';
import '../providers/education_provider.dart';
import '../widgets/education_kategori_badge.dart';
import '../widgets/education_thumbnail.dart';

/// Article Detail (FR-05 / poin 5.2).
///
/// Body artikel dirender dari HTML memakai `flutter_html`, lalu di bawahnya
/// ditampilkan daftar artikel terkait dari kategori yang sama.
class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.articleId});

  final String articleId;

  /// Tombol share artikel.
  ///
  /// Fase UTS menyalin judul + kategori ke clipboard karena belum ada URL
  /// publik artikel (konten masih mock) dan `share_plus` tidak ada di pubspec
  /// dev plan §7. UAS: ganti ke deep link artikel via `share_plus`.
  Future<void> _bagikan(BuildContext context, ArticleModel artikel) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(
        text:
            'ImuniKita — ${artikel.judul} '
            '(kategori ${artikel.kategori}, ${artikel.estimasiBacaMenit} menit baca)',
      ),
    );
    messenger.showSnackBar(
      const SnackBar(content: Text('Informasi artikel disalin ke clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artikel = ref.watch(artikelDetailProvider(articleId));

    if (artikel == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Artikel',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Text(
            'Artikel tidak ditemukan.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final terkait = ref
        .watch(educationDatasourceProvider)
        .getArtikelTerkait(artikel);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Artikel',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Bagikan artikel',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _bagikan(context, artikel),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            EducationThumbnail(
              kategori: artikel.kategori,
              imageUrl: artikel.imageUrl,
              width: double.infinity,
              height: 200,
              borderRadius: 0,
              iconSize: 56,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EducationKategoriBadge(kategori: artikel.kategori),
                  const SizedBox(height: 10),
                  Text(
                    artikel.judul,
                    style: GoogleFonts.baloo2(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MetaRow(artikel: artikel),
                  const Divider(height: 28),

                  // Body artikel (HTML)
                  Html(
                    data: artikel.kontenHtml,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(14),
                        lineHeight: LineHeight(1.7),
                        color: AppColors.darkText,
                      ),
                      'h3': Style(
                        fontSize: FontSize(16),
                        fontWeight: FontWeight.w700,
                        margin: Margins.only(top: 18, bottom: 6),
                      ),
                      'p': Style(margin: Margins.only(bottom: 10)),
                      'ul': Style(margin: Margins.only(bottom: 10)),
                      'li': Style(margin: Margins.only(bottom: 4)),
                    },
                  ),
                  const SizedBox(height: 24),

                  // Artikel terkait
                  if (terkait.isNotEmpty) ...[
                    Text(
                      'Artikel Terkait',
                      style: GoogleFonts.baloo2(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...terkait.map((item) => _TerkaitCard(artikel: item)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.artikel});

  final ArticleModel artikel;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: 11.5,
      color: AppColors.textHint,
    );

    Widget item(IconData ikon, String teks) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(teks, style: style),
        ],
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        item(Icons.person_outline, artikel.penulis),
        item(
          Icons.calendar_today,
          DateFormatter.formatLong(artikel.tanggalPublish),
        ),
        item(Icons.schedule, '${artikel.estimasiBacaMenit} menit baca'),
      ],
    );
  }
}

class _TerkaitCard extends StatelessWidget {
  const _TerkaitCard({required this.artikel});

  final ArticleModel artikel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/education/article/${artikel.articleId}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              EducationThumbnail(
                kategori: artikel.kategori,
                imageUrl: artikel.imageUrl,
                width: 64,
                height: 64,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artikel.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${artikel.kategori} · ${artikel.estimasiBacaMenit} menit baca',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
