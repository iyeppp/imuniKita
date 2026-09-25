import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../widgets/empty_state_widget.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_score_model.dart';
import '../providers/education_provider.dart';

/// Quiz Screen (FR-05 / poin 5.3).
///
/// Alur: satu soal per layar → user memilih satu jawaban → feedback
/// langsung (benar/salah + penjelasan) → lanjut sampai soal terakhir →
/// layar hasil dengan skor + badge → skor disimpan ke Hive CE.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.quizId});

  final String quizId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _index = 0;
  int? _dipilih;
  int _jumlahBenar = 0;
  bool _selesai = false;

  void _jawab(QuizQuestion soal, int pilihan) {
    // Satu soal hanya dihitung sekali — tap berikutnya diabaikan.
    if (_dipilih != null) return;

    setState(() {
      _dipilih = pilihan;
      if (pilihan == soal.indexJawabanBenar) _jumlahBenar++;
    });
  }

  Future<void> _lanjut(QuizModel kuis) async {
    final soalTerakhir = _index == kuis.totalSoal - 1;

    if (!soalTerakhir) {
      setState(() {
        _index++;
        _dipilih = null;
      });
      return;
    }

    // Simpan skor terakhir ke Hive CE sebelum menampilkan hasil.
    await ref
        .read(quizScoresProvider.notifier)
        .saveScore(
          QuizScoreModel(
            quizId: kuis.quizId,
            skor: _jumlahBenar,
            totalSoal: kuis.totalSoal,
            tanggalPengerjaan: DateTime.now(),
          ),
        );

    if (!mounted) return;
    setState(() => _selesai = true);
  }

  void _cobaLagi() {
    setState(() {
      _index = 0;
      _dipilih = null;
      _jumlahBenar = 0;
      _selesai = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kuis = ref
        .watch(educationDatasourceProvider)
        .getKuisById(widget.quizId);

    if (kuis == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.education),
          ),
          title: Text(
            'Kuis',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        body: const EmptyStateWidget(
          icon: Icons.quiz_outlined,
          title: 'Kuis tidak ditemukan',
          message: 'Kuis ini mungkin sudah tidak tersedia.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.education),
        ),
        title: Text(
          _selesai ? 'Hasil Kuis' : kuis.judul,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(child: _selesai ? _buildHasil(kuis) : _buildSoal(kuis)),
    );
  }

  // ── Tampilan soal ──────────────────────────────────────────────────────

  Widget _buildSoal(QuizModel kuis) {
    final soal = kuis.soal[_index];
    final sudahDijawab = _dipilih != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar soal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${_index + 1}/${kuis.totalSoal}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Text(
                kuis.kategori,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + 1) / kuis.totalSoal,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 20),

          // Pertanyaan
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                soal.pertanyaan,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4 pilihan jawaban (single select)
          ...List.generate(
            soal.pilihan.length,
            (index) => _buildOpsi(soal, index),
          ),
          const SizedBox(height: 8),

          // Feedback langsung
          if (sudahDijawab) _buildFeedback(soal),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: sudahDijawab ? () => _lanjut(kuis) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.4),
            ),
            child: Text(
              _index == kuis.totalSoal - 1 ? 'Lihat Hasil' : 'Lanjut',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpsi(QuizQuestion soal, int index) {
    final sudahDijawab = _dipilih != null;
    final jawabanBenar = index == soal.indexJawabanBenar;
    final dipilih = _dipilih == index;

    var border = AppColors.border;
    var background = AppColors.surface;
    IconData? ikon;

    if (sudahDijawab && jawabanBenar) {
      border = AppColors.green;
      background = AppColors.green.withValues(alpha: 0.12);
      ikon = Icons.check_circle;
    } else if (sudahDijawab && dipilih) {
      border = AppColors.red;
      background = AppColors.red.withValues(alpha: 0.12);
      ikon = Icons.cancel;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: sudahDijawab ? null : () => _jawab(soal, index),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withValues(
                      alpha: sudahDijawab ? 0.08 : 0.15,
                    ),
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    soal.pilihan[index],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.darkText,
                      height: 1.35,
                    ),
                  ),
                ),
                if (ikon != null) ...[
                  const SizedBox(width: 8),
                  Icon(ikon, size: 20, color: border),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(QuizQuestion soal) {
    final benar = _dipilih == soal.indexJawabanBenar;
    final warna = benar ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warna, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                benar ? Icons.check_circle : Icons.cancel,
                color: warna,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                benar ? 'Jawaban Benar!' : 'Jawaban Salah',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: warna,
                ),
              ),
            ],
          ),
          if (!benar) ...[
            const SizedBox(height: 8),
            Text(
              'Jawaban yang benar: ${soal.jawabanBenar}',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            soal.penjelasan,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tampilan hasil ─────────────────────────────────────────────────────

  Widget _buildHasil(QuizModel kuis) {
    final persentase = kuis.totalSoal == 0
        ? 0
        : ((_jumlahBenar / kuis.totalSoal) * 100).round();

    final (label, warnaBadge) = switch (persentase) {
      >= 80 => ('Excellent 🏆', AppColors.green),
      >= 60 => ('Good 👍', AppColors.yellow),
      _ => ('Keep Trying 💪', AppColors.coral),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: warnaBadge.withValues(alpha: 0.15),
                border: Border.all(color: warnaBadge, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$persentase%',
                    style: GoogleFonts.baloo2(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    'skor akhir',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: warnaBadge.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: warnaBadge),
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    kuis.judul,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatHasil(
                        label: 'Jawaban Benar',
                        nilai: '$_jumlahBenar',
                        warna: AppColors.green,
                      ),
                      _StatHasil(
                        label: 'Jawaban Salah',
                        nilai: '${kuis.totalSoal - _jumlahBenar}',
                        warna: AppColors.red,
                      ),
                      _StatHasil(
                        label: 'Total Soal',
                        nilai: '${kuis.totalSoal}',
                        warna: AppColors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Skor tersimpan di perangkat Anda',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: _cobaLagi, child: const Text('Coba Lagi')),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Kembali ke Edukasi'),
          ),
        ],
      ),
    );
  }
}

class _StatHasil extends StatelessWidget {
  const _StatHasil({
    required this.label,
    required this.nilai,
    required this.warna,
  });

  final String label;
  final String nilai;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          nilai,
          style: GoogleFonts.baloo2(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: warna,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
