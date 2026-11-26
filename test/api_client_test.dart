import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:imunikita/core/errors/failures.dart';
import 'package:imunikita/core/network/api_cache.dart';
import 'package:imunikita/core/network/api_client.dart';
import 'package:imunikita/features/education/data/datasources/education_remote_datasource.dart';
import 'package:imunikita/features/faskes/data/datasources/faskes_remote_datasource.dart';
import 'package:imunikita/hive_registrar.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<String> cacheBox;

  setUpAll(() async {
    Hive.init('./test/hive_api_client_test_dir');
    Hive.registerAdapters();
  });

  setUp(() async {
    cacheBox = await Hive.openBox<String>('test_api_cache_box');
    await cacheBox.clear();
  });

  tearDown(() async {
    await cacheBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      final dir = SystemTempFile.tempDir('./test/hive_api_client_test_dir');
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  group('B8-5 & B8-9 ApiClient & Error Mapping Tests', () {
    test('ApiClient throw AuthFailure saat server mengembalikan 401', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final client = ApiClient(dio: dio, baseUrl: 'http://localhost:3000');

      expect(
        () async => await client.get('/v1/education/articles'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('ApiClient throw ServerFailure saat server mengembalikan 500', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 500,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final client = ApiClient(dio: dio, baseUrl: 'http://localhost:3000');

      expect(
        () async => await client.get('/v1/education/articles'),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('ApiClient throw NetworkFailure saat koneksi timeout', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
                message: 'Connection timed out',
              ),
            );
          },
        ),
      );

      final client = ApiClient(dio: dio, baseUrl: 'http://localhost:3000');

      expect(
        () async => await client.get('/v1/education/articles'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('B8-6, B8-7 & B8-8 RemoteDatasource & Fallback Tests', () {
    test('EducationRemoteDatasource memuat dari mock jika API gagal dan cache kosong', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );

      final client = ApiClient(dio: dio, baseUrl: 'http://localhost:3000');
      final cache = ApiCache(cacheBox);
      final remoteDs = EducationRemoteDatasource(
        apiClient: client,
        apiCache: cache,
      );

      final articles = await remoteDs.getArtikel();

      // Harus fallback ke mock data dan tidak melempar exception!
      expect(articles, isNotEmpty);
      expect(articles.first.articleId, isNotEmpty);
    });

    test('FaskesRemoteDatasource memuat dari mock jika API gagal dan cache kosong', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );

      final client = ApiClient(dio: dio, baseUrl: 'http://localhost:3000');
      final cache = ApiCache(cacheBox);
      final remoteDs = FaskesRemoteDatasource(
        apiClient: client,
        apiCache: cache,
      );

      final faskesList = await remoteDs.getAll();

      expect(faskesList, isNotEmpty);
      expect(faskesList.first.nama, isNotEmpty);
    });
  });
}

class SystemTempFile {
  static Directory tempDir(String path) => Directory(path);
}
