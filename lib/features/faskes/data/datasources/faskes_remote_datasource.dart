import 'package:flutter/foundation.dart';

import '../../../../core/network/api_cache.dart';
import '../../../../core/network/api_client.dart';
import '../models/faskes_model.dart';
import 'faskes_mock_datasource.dart';

/// Remote datasource direktori faskes dengan cache Hive & fallback mock offline.
class FaskesRemoteDatasource {
  FaskesRemoteDatasource({
    this.apiClient,
    ApiCache? apiCache,
    FaskesMockDatasource? mockDatasource,
  })  : _apiCache = apiCache ?? ApiCache(),
        _mockDatasource = mockDatasource ?? const FaskesMockDatasource();

  final ApiClient? apiClient;
  final ApiCache _apiCache;
  final FaskesMockDatasource _mockDatasource;

  Future<List<FaskesModel>> getAll() async {
    return getByTipe(FaskesTipe.semua);
  }

  Future<List<FaskesModel>> getByTipe(String tipe) async {
    final cacheKey = 'faskes_$tipe';

    if (apiClient != null) {
      try {
        final query = tipe != FaskesTipe.semua ? {'tipe': tipe} : null;
        final response = await apiClient!.get<Map<String, dynamic>>(
          '/v1/faskes',
          queryParameters: query,
        );

        if (response.data != null) {
          final body = response.data!;
          await _apiCache.put(cacheKey, body);
          final rawList = body['data'] as List<dynamic>? ?? [];
          return rawList
              .map((json) => FaskesModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('FaskesRemoteDatasource: GET faskes gagal ($e), memuat cache/mock.');
        }
      }
    }

    final cached = await _apiCache.get(cacheKey);
    if (cached != null) {
      final rawList = cached['data'] as List<dynamic>? ?? [];
      return rawList
          .map((json) => FaskesModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return _mockDatasource.getByTipe(tipe);
  }
}
