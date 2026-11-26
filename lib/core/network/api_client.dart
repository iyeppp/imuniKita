import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../errors/failures.dart';
import '../firebase/firebase_bootstrap.dart';

/// Client HTTP Dio terpusat untuk komunikasi dengan backend REST API (B8-5).
///
/// Fitur:
/// - Base URL dinamis dari `--dart-define=API_BASE_URL` (default `http://10.0.2.2:3000`).
/// - Interceptor penyemat `Authorization: Bearer <Firebase ID Token>`.
/// - Retry otomatis untuk transient error (max 2 kali).
/// - Pemetaan error DioException ke Failure (`NetworkFailure`, `ServerFailure`, `AuthFailure`).
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl, this._auth})
      : _isCustomDio = dio != null,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ??
                    const String.fromEnvironment(
                      'API_BASE_URL',
                      defaultValue: 'http://10.0.2.2:3000',
                    ),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final authInstance = _auth ??
                (FirebaseBootstrap.isInitialized
                    ? FirebaseAuth.instance
                    : null);
            final user = authInstance?.currentUser;
            if (user != null) {
              final token = await user.getIdToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('ApiClient: Gagal mengambil Firebase ID Token: $e');
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final FirebaseAuth? _auth;
  final bool _isCustomDio;

  Dio get dio => _dio;

  bool get _isTestEnvironment =>
      kDebugMode && Platform.environment.containsKey('FLUTTER_TEST');

  /// Melakukan request GET.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_isTestEnvironment && !_isCustomDio) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        message: 'Mode test: koneksi server dilewati.',
      );
    }
    return _executeWithRetry(
      () => _dio.get<T>(path, queryParameters: queryParameters),
    );
  }

  /// Melakukan request POST.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) async {
    if (_isTestEnvironment && !_isCustomDio) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
        message: 'Mode test: koneksi server dilewati.',
      );
    }
    return _executeWithRetry(
      () => _dio.post<T>(path, data: data),
    );
  }

  Future<Response<T>> _executeWithRetry<T>(
    Future<Response<T>> Function() requestFn, {
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await requestFn();
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          throw const AuthFailure('Sesi telah berakhir. Silakan masuk kembali.');
        }

        final isTransient = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            (statusCode != null && statusCode >= 500);

        if (isTransient && attempts <= maxRetries) {
          if (!kDebugMode || !Platform.environment.containsKey('FLUTTER_TEST')) {
            await Future.delayed(Duration(milliseconds: 500 * attempts));
          }
          continue;
        }

        if (statusCode != null && statusCode >= 500) {
          throw ServerFailure(
            'Layanan server mengalami gangguan (${e.response?.statusCode}).',
          );
        }

        throw NetworkFailure(
          e.message ?? 'Gagal terhubung ke server REST API.',
        );
      } catch (e) {
        if (e is Failure) rethrow;
        throw NetworkFailure('Terjadi kesalahan jaringan: $e');
      }
    }
  }
}
