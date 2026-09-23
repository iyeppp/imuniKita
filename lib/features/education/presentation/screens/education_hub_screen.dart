import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/education_mock_datasource.dart';
import '../../data/models/article_model.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_score_model.dart';
import '../../data/models/video_model.dart';
import '../providers/education_provider.dart';
import '../widgets/education_kategori_badge.dart';
import '../widgets/education_thumbnail.dart';

/// Education Hub (FR-05) — titik masuk fitur edukasi.
///
/// Tiga tab konten (Artikel, Video, Kuis) dengan satu chip filter kategori
/// yang dipakai bersama, sehingga filter terasa konsisten di seluruh tab.
class EducationHubScreen extends StatelessWidget {
  const EducationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          // `/education` adalah route top-level. Bila dibuka tanpa riwayat
          // (mis. deep link), tidak ada halaman untuk di-`pop` — karena itu
          // tombol kembali selalu disediakan dan jatuh ke Dashboard.
          leading: IconButton(
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.dashboard),
          ),
          title: Text(
            'Edukasi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.coral,
            labelColor: AppColors.darkText,
            unselectedLabelColor: AppColors.textHint,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Artikel'),
              Tab(text: 'Video'),
              Tab(text: 'Kuis'),
            ],
          ),
        ),
        body: Column(
          children: [
            const _KategoriFilterBar(),
            Expanded(
              child: TabBarView(
                children: [_ArtikelTab(), _VideoTab(), _KuisTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Chip filter kategori
// ───────────────────────────────────────────────────────────────────────────

class _KategoriFilterBar extends ConsumerWidget {
  const _KategoriFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terpilih = ref.watch(educationKategoriProvider);

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: EducationKategori.filter.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final kategori = EducationKategori.filter[index];
          final aktif = kategori == terpilih;
          return FilterChip(
            label: Text(kategori),
            selected: aktif,
            onSelected: (_) =>
                ref.read(educationKategoriProvider.notifier).state = kategori,
            selectedColor: AppColors.teal,
            checkmarkColor: Colors.white,
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              color: aktif ? Colors.white : AppColors.darkText,
              fontWeight: aktif ? FontWeight.w600 : FontWeight.w400,
            ),
            side: BorderSide(color: aktif ? AppColors.teal : AppColors.divider),
            backgroundColor: AppColors.surface,
          );
        },
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Tab Artikel
// ───────────────────────────────────────────────────────────────────────────

class _ArtikelTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artikel = ref.watch(educationArtikelProvider);

    if (artikel.isEmpty) {
      return const _EmptyState(
        pesan: 'Belum ada artikel untuk kategori ini.',
        ikon: Icons.article_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: artikel.length,
      itemBuilder: (context, index) => _ArtikelCard(artikel: artikel[index]),
    );
  }
}

class _ArtikelCard extends StatelessWidget {
  const _ArtikelCard({required this.artikel});

  final ArticleModel artikel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/education/article/${artikel.articleId}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EducationThumbnail(
                kategori: artikel.kategori,
                imageUrl: artikel.imageUrl,
                width: 88,
                height: 88,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EducationKategoriBadge(kategori: artikel.kategori),
                    const SizedBox(height: 6),
                    Text(
                      artikel.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artikel.ringkasan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${artikel.estimasiBacaMenit} menit baca',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
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

// ───────────────────────────────────────────────────────────────────────────
// Tab Video
// ───────────────────────────────────────────────────────────────────────────

class _VideoTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(educationVideoProvider);

    if (video.isEmpty) {
      return const _EmptyState(
        pesan: 'Belum ada video untuk kategori ini.',
        ikon: Icons.play_circle_outline,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Tinggi kartu dipatok agar judul 2 baris + label kategori tidak
        // berisiko overflow di layar sempit.
        mainAxisExtent: 205,
      ),
      itemCount: video.length,
      itemBuilder: (context, index) => _VideoCard(video: video[index]),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});

  final VideoModel video;

  /// Fase UTS membuka pencarian YouTube di aplikasi/browser eksternal
  /// (belum ada video resmi yang di-host tim).
  Future<void> _buka(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final berhasil = await launchUrl(
        Uri.parse(video.tontonUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!berhasil) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Tautan video tidak dapat dibuka.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tautan video tidak dapat dibuka.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _buka(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                EducationThumbnail(
                  kategori: video.kategori,
                  imageUrl: video.thumbnailUrl,
                  width: double.infinity,
                  height: 96,
                  borderRadius: 0,
                  iconSize: 32,
                ),
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkText.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      video.durasiLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      video.kategori,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Tab Kuis
// ───────────────────────────────────────────────────────────────────────────

class _KuisTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kuis = ref.watch(educationKuisProvider);
    final skor =
        ref.watch(quizScoresProvider).asData?.value ??
        const <String, QuizScoreModel>{};

    if (kuis.isEmpty) {
      return const _EmptyState(
        pesan: 'Belum ada kuis untuk kategori ini.',
        ikon: Icons.quiz_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: kuis.length,
      itemBuilder: (context, index) =>
          _KuisCard(kuis: kuis[index], skor: skor[kuis[index].quizId]),
    );
  }
}

class _KuisCard extends StatelessWidget {
  const _KuisCard({required this.kuis, this.skor});

  final QuizModel kuis;
  final QuizScoreModel? skor;

  @override
  Widget build(BuildContext context) {
    final sudahDikerjakan = skor != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/education/quiz/${kuis.quizId}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      kuis.judul,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(sudahDikerjakan: sudahDikerjakan, skor: skor),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                kuis.deskripsi,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  EducationKategoriBadge(kategori: kuis.kategori),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.help_outline,
                    size: 13,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${kuis.totalSoal} soal',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.sudahDikerjakan, this.skor});

  final bool sudahDikerjakan;
  final QuizScoreModel? skor;

  @override
  Widget build(BuildContext context) {
    if (!sudahDikerjakan) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Mulai',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 13, color: AppColors.green),
          const SizedBox(width: 4),
          Text(
            '${skor!.persentase}%',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Komponen kecil bersama
// ───────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.pesan, required this.ikon});

  final String pesan;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 64, color: AppColors.grey),
            const SizedBox(height: 12),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
