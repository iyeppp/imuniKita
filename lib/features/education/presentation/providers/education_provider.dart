import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../injection/dependency_injection.dart';
import '../../data/datasources/education_mock_datasource.dart';
import '../../data/datasources/education_remote_datasource.dart';
import '../../data/models/article_model.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/quiz_score_model.dart';
import '../../data/models/video_model.dart';

// ── Konten (REST API + Cache + Mock Fallback) ────────────────────────────

/// Akses konten edukasi.
final educationDatasourceProvider = Provider<EducationRemoteDatasource>((ref) {
  return ref.watch(educationRemoteDatasourceProvider);
});

/// Kategori aktif pada chip filter — dipakai bersama tab Artikel, Video, dan Kuis agar filter terasa konsisten.
final educationKategoriProvider = StateProvider<String>(
  (ref) => EducationKategori.semua,
);

final educationArtikelAsyncProvider = FutureProvider<List<ArticleModel>>((ref) async {
  final kategori = ref.watch(educationKategoriProvider);
  return ref.watch(educationDatasourceProvider).getArtikel(kategori: kategori);
});

final educationArtikelProvider = Provider<List<ArticleModel>>((ref) {
  final asyncVal = ref.watch(educationArtikelAsyncProvider);
  return asyncVal.asData?.value ??
      const EducationMockDatasource().getArtikel(
        kategori: ref.watch(educationKategoriProvider),
      );
});

final educationVideoAsyncProvider = FutureProvider<List<VideoModel>>((ref) async {
  final kategori = ref.watch(educationKategoriProvider);
  return ref.watch(educationDatasourceProvider).getVideo(kategori: kategori);
});

final educationVideoProvider = Provider<List<VideoModel>>((ref) {
  final asyncVal = ref.watch(educationVideoAsyncProvider);
  return asyncVal.asData?.value ??
      const EducationMockDatasource().getVideo(
        kategori: ref.watch(educationKategoriProvider),
      );
});

final educationKuisAsyncProvider = FutureProvider<List<QuizModel>>((ref) async {
  final kategori = ref.watch(educationKategoriProvider);
  return ref.watch(educationDatasourceProvider).getKuis(kategori: kategori);
});

final educationKuisProvider = Provider<List<QuizModel>>((ref) {
  final asyncVal = ref.watch(educationKuisAsyncProvider);
  return asyncVal.asData?.value ??
      const EducationMockDatasource().getKuis(
        kategori: ref.watch(educationKategoriProvider),
      );
});

final artikelDetailAsyncProvider = FutureProvider.family<ArticleModel?, String>((
  ref,
  articleId,
) async {
  return ref.watch(educationDatasourceProvider).getArtikelById(articleId);
});

/// Artikel tunggal untuk Article Detail (`null` bila id tidak dikenal).
final artikelDetailProvider = Provider.family<ArticleModel?, String>((
  ref,
  articleId,
) {
  final asyncVal = ref.watch(artikelDetailAsyncProvider(articleId));
  return asyncVal.asData?.value ??
      const EducationMockDatasource().getArtikelById(articleId);
});

// ── Skor kuis ────────────────────────────────────────────────────────────

/// Skor kuis yang sudah dikerjakan, dipetakan `quizId → QuizScoreModel`.
class QuizScoreNotifier extends AsyncNotifier<Map<String, QuizScoreModel>> {
  @override
  Future<Map<String, QuizScoreModel>> build() async {
    final box = await Hive.openBox<QuizScoreModel>(
      AppConstants.educationQuizScoresBox,
    );
    return {for (final skor in box.values) skor.quizId: skor};
  }

  /// Simpan hasil percobaan terbaru.
  Future<void> saveScore(QuizScoreModel skor) async {
    final box = await Hive.openBox<QuizScoreModel>(
      AppConstants.educationQuizScoresBox,
    );

    final lama = box.get(skor.quizId);
    final riwayat = <int>[...?lama?.riwayatSkor, skor.skor];

    await box.put(
      skor.quizId,
      QuizScoreModel(
        quizId: skor.quizId,
        skor: skor.skor,
        totalSoal: skor.totalSoal,
        tanggalPengerjaan: skor.tanggalPengerjaan,
        attemptCount: (lama?.attemptCount ?? 0) + 1,
        riwayatSkor: riwayat,
      ),
    );
    ref.invalidateSelf();
  }
}

final quizScoresProvider =
    AsyncNotifierProvider<QuizScoreNotifier, Map<String, QuizScoreModel>>(
      QuizScoreNotifier.new,
    );
