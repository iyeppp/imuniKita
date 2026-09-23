import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/education_mock_datasource.dart';
import '../../data/models/article_model.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_score_model.dart';
import '../../data/models/video_model.dart';

// ── Konten (mock) ────────────────────────────────────────────────────────
//
// Provider ditulis manual (tanpa codegen) mengikuti pola yang dipakai fitur
// lain — lihat dev plan §2.

/// Akses konten edukasi. Fase UAS: ganti isi provider ini dengan
/// implementasi CMS tanpa menyentuh screen.
final educationDatasourceProvider = Provider<EducationMockDatasource>((ref) {
  return const EducationMockDatasource();
});

/// Kategori aktif pada chip filter — dipakai bersama tab Artikel, Video,
/// dan Kuis agar filter terasa konsisten.
final educationKategoriProvider = StateProvider<String>(
  (ref) => EducationKategori.semua,
);

final educationArtikelProvider = Provider<List<ArticleModel>>((ref) {
  final kategori = ref.watch(educationKategoriProvider);
  return ref.watch(educationDatasourceProvider).getArtikel(kategori: kategori);
});

final educationVideoProvider = Provider<List<VideoModel>>((ref) {
  final kategori = ref.watch(educationKategoriProvider);
  return ref.watch(educationDatasourceProvider).getVideo(kategori: kategori);
});

final educationKuisProvider = Provider<List<QuizModel>>((ref) {
  final kategori = ref.watch(educationKategoriProvider);
  return ref.watch(educationDatasourceProvider).getKuis(kategori: kategori);
});

/// Artikel tunggal untuk Article Detail (`null` bila id tidak dikenal).
final artikelDetailProvider = Provider.family<ArticleModel?, String>((
  ref,
  articleId,
) {
  return ref.watch(educationDatasourceProvider).getArtikelById(articleId);
});

// ── Skor kuis ────────────────────────────────────────────────────────────

/// Skor kuis yang sudah dikerjakan, dipetakan `quizId → QuizScoreModel`.
///
/// Disimpan di Hive CE box [AppConstants.educationQuizScoresBox] sehingga
/// badge "Sudah dikerjakan ✓" tetap ada setelah aplikasi di-restart.
class QuizScoreNotifier extends AsyncNotifier<Map<String, QuizScoreModel>> {
  @override
  Future<Map<String, QuizScoreModel>> build() async {
    final box = await Hive.openBox<QuizScoreModel>(
      AppConstants.educationQuizScoresBox,
    );
    return {for (final skor in box.values) skor.quizId: skor};
  }

  /// Simpan skor terbaru; menimpa skor kuis yang sama bila diulang.
  Future<void> saveScore(QuizScoreModel skor) async {
    final box = await Hive.openBox<QuizScoreModel>(
      AppConstants.educationQuizScoresBox,
    );
    await box.put(skor.quizId, skor);
    ref.invalidateSelf();
  }
}

final quizScoresProvider =
    AsyncNotifierProvider<QuizScoreNotifier, Map<String, QuizScoreModel>>(
      QuizScoreNotifier.new,
    );
