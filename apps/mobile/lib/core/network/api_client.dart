import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/environment_config.dart';
import '../errors/app_exception.dart';
import 'api_error_parser.dart';

/// Thin Dio wrapper for MeMy API.
///
/// - Base URL from [EnvironmentConfig.apiBaseUrl]
/// - Dev user header only when [kDebugMode] is true
/// - Debug logging excludes sensitive fields
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl, bool? enableLogging})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _normalizeBaseUrl(
                baseUrl ?? EnvironmentConfig.apiBaseUrl,
              ),
              connectTimeout: EnvironmentConfig.connectTimeout,
              receiveTimeout: EnvironmentConfig.receiveTimeout,
              sendTimeout: EnvironmentConfig.sendTimeout,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            options.headers['X-Dev-User-Id'] = EnvironmentConfig.devUserId;
          }
          handler.next(options);
        },
      ),
    );

    if (enableLogging ?? kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (object) {
            final line = object.toString();
            if (_looksSensitive(line)) return;
            debugPrint(line);
          },
        ),
      );
    }
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _guard(() => _dio.get<T>(path, queryParameters: queryParameters));
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _guard(() => _dio.post<T>(path, data: data));
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return _guard(() => _dio.patch<T>(path, data: data));
  }

  Future<Response<T>> delete<T>(String path) {
    return _guard(() => _dio.delete<T>(path));
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static AppException mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException.timeout();
      case DioExceptionType.connectionError:
        return AppException.networkUnavailable();
      case DioExceptionType.badResponse:
        return ApiErrorParser.fromStatusAndBody(
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return AppException.unknown('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return AppException.networkUnavailable(
          'Could not establish a secure connection.',
        );
      case DioExceptionType.unknown:
        return AppException.networkUnavailable();
      case DioExceptionType.transformTimeout:
        return AppException.timeout();
    }
  }

  static String _normalizeBaseUrl(String url) {
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }

  static bool _looksSensitive(String line) {
    final lower = line.toLowerCase();
    return lower.contains('password') ||
        lower.contains('authorization') ||
        lower.contains('token') ||
        lower.contains('x-dev-user') ||
        lower.contains('"notes"') ||
        lower.contains('api_key');
  }
}
