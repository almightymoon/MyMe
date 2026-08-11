import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/environment_config.dart';
import '../errors/app_exception.dart';
import 'access_token_store.dart';
import 'api_error_parser.dart';

typedef AccessTokenRefresher = Future<bool> Function();

/// Thin Dio wrapper for MeMy API.
///
/// - Base URL from [EnvironmentConfig.apiBaseUrl]
/// - Bearer access tokens from [AccessTokenStore]
/// - Dev user header only when [kDebugMode] and not production
/// - Debug logging excludes sensitive fields
class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
    bool? enableLogging,
    AccessTokenStore? accessTokenStore,
    this._refresher,
    this._attachDevUserHeader = true,
  }) : _tokens = accessTokenStore ?? AccessTokenStore(),
       _dio =
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
          if (_attachDevUserHeader &&
              kDebugMode &&
              !EnvironmentConfig.isProduction &&
              !EnvironmentConfig.usesAccountAuth) {
            options.headers['X-Dev-User-Id'] = EnvironmentConfig.devUserId;
          }
          final token = _tokens.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (!_shouldRefresh(error)) {
            handler.next(error);
            return;
          }
          final refreshed = await _refreshOnce();
          if (!refreshed) {
            handler.next(error);
            return;
          }
          try {
            final retry = await _retry(error.requestOptions);
            handler.resolve(retry);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
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
  final AccessTokenStore _tokens;
  final AccessTokenRefresher? _refresher;
  final bool _attachDevUserHeader;
  Future<bool>? _inFlightRefresh;

  Dio get dio => _dio;

  AccessTokenStore get tokens => _tokens;

  void cancelInFlight() {
    _dio.close(force: true);
  }

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

  Future<Response<T>> delete<T>(String path, {Object? data}) {
    return _guard(() => _dio.delete<T>(path, data: data));
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

  bool _shouldRefresh(DioException error) {
    if (error.response?.statusCode != 401) return false;
    if (_refresher == null) return false;
    if (error.requestOptions.extra['memyRetried'] == true ||
        error.requestOptions.headers['x-memy-retry'] == '1') {
      return false;
    }
    final path = error.requestOptions.path;
    return !path.contains('/auth/refresh') &&
        !path.contains('/auth/google') &&
        !path.contains('/auth/apple') &&
        !path.contains('/auth/logout');
  }

  Future<bool> _refreshOnce() {
    final existing = _inFlightRefresh;
    if (existing != null) return existing;
    final refresher = _refresher;
    if (refresher == null) return Future.value(false);
    final gate = Completer<bool>();
    _inFlightRefresh = gate.future;
    refresher()
        .then(gate.complete, onError: (_) => gate.complete(false))
        .whenComplete(() => _inFlightRefresh = null);
    return gate.future;
  }

  Future<Response<dynamic>> _retry(RequestOptions request) {
    final token = _tokens.token;
    final headers = Map<String, dynamic>.from(request.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['x-memy-retry'] = '1';
    return _dio.fetch<dynamic>(
      request.copyWith(
        headers: headers,
        extra: {...request.extra, 'memyRetried': true},
      ),
    );
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
