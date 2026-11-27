import 'package:flutter/foundation.dart';

import '../../../../core/network/api_cache.dart';
import '../../../../core/network/api_client.dart';
import '../models/article_model.dart';
import '../models/quiz_model.dart';
import '../models/video_model.dart';
import 'education_mock_datasource.dart';

/// Remote datasource konten edukasi dengan cache Hive & fallback mock offline.
class EducationRemoteDatasource {
  EducationRemoteDatasource({
    this.apiClient,
    ApiCache? apiCache,
    EducationMockDatasource? mockDatasource,
  })  : _apiCache = apiCache ?? ApiCache(),
        _mockDatasource = mockDatasource ?? const EducationMockDatasource();

  final ApiClient? apiClient;
  final ApiCache _apiCache;
  final EducationMockDatasource _mockDatasource;

  Future<List<ArticleModel>> getArtikel({
    String kategori = EducationKategori.semua,
  }) async {
    final cacheKey = 'articles_$kategori';

    if (apiClient != null) {
      try {
        final query =
            kategori != EducationKategori.semua ? {'kategori': kategori} : null;
        final response = await apiClient!.get<Map<String, dynamic>>(
          '/v1/education/articles',
          queryParameters: query,
        );

        if (response.data != null) {
          final body = response.data!;
          await _apiCache.put(cacheKey, body);
          final rawList = body['data'] as List<dynamic>? ?? [];
          return rawList
              .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('EducationRemoteDatasource: GET articles gagal ($e), memuat cache/mock.');
        }
      }
    }

    // 1.
    final cached = await _apiCache.get(cacheKey);
    if (cached != null) {
      final rawList = cached['data'] as List<dynamic>? ?? [];
      return rawList
          .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // 2.
    return _mockDatasource.getArtikel(kategori: kategori);
  }

  Future<ArticleModel?> getArtikelById(String articleId) async {
    final articles = await getArtikel();
    for (final a in articles) {
      if (a.articleId == articleId) return a;
    }
    return _mockDatasource.getArtikelById(articleId);
  }

  Future<List<VideoModel>> getVideo({
    String kategori = EducationKategori.semua,
  }) async {
    final cacheKey = 'videos_$kategori';

    if (apiClient != null) {
      try {
        final query =
            kategori != EducationKategori.semua ? {'kategori': kategori} : null;
        final response = await apiClient!.get<Map<String, dynamic>>(
          '/v1/education/videos',
          queryParameters: query,
        );

        if (response.data != null) {
          final body = response.data!;
          await _apiCache.put(cacheKey, body);
          final rawList = body['data'] as List<dynamic>? ?? [];
          return rawList
              .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('EducationRemoteDatasource: GET videos gagal ($e), memuat cache/mock.');
        }
      }
    }

    final cached = await _apiCache.get(cacheKey);
    if (cached != null) {
      final rawList = cached['data'] as List<dynamic>? ?? [];
      return rawList
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return _mockDatasource.getVideo(kategori: kategori);
  }

  Future<List<QuizModel>> getQuizzes() async {
    const cacheKey = 'quizzes_all';

    if (apiClient != null) {
      try {
        final response = await apiClient!.get<Map<String, dynamic>>(
          '/v1/education/quizzes',
        );

        if (response.data != null) {
          final body = response.data!;
          await _apiCache.put(cacheKey, body);
          final rawList = body['data'] as List<dynamic>? ?? [];
          return rawList
              .map((json) => QuizModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('EducationRemoteDatasource: GET quizzes gagal ($e), memuat cache/mock.');
        }
      }
    }

    final cached = await _apiCache.get(cacheKey);
    if (cached != null) {
      final rawList = cached['data'] as List<dynamic>? ?? [];
      return rawList
          .map((json) => QuizModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return _mockDatasource.getKuis();
  }

  List<ArticleModel> getArtikelTerkait(ArticleModel artikel, {int limit = 3}) {
    return _mockDatasource.getArtikelTerkait(artikel, limit: limit);
  }

  Future<List<QuizModel>> getKuis({
    String kategori = EducationKategori.semua,
  }) async {
    final quizzes = await getQuizzes();
    if (kategori == EducationKategori.semua) return quizzes;
    return quizzes.where((q) => q.kategori == kategori).toList();
  }

  QuizModel? getKuisById(String quizId) {
    return _mockDatasource.getKuisById(quizId);
  }
}
