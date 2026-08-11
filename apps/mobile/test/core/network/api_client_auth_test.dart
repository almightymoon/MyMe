import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/network/access_token_store.dart';
import 'package:memy/core/network/api_client.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'attaches bearer tokens and omits development headers in account mode',
    () async {
      late RequestOptions captured;
      final tokens = AccessTokenStore()
        ..replace(
          'access-token-value',
          DateTime.now().toUtc().add(const Duration(minutes: 10)),
        );
      final dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'));
      final client = ApiClient(
        dio: dio,
        accessTokenStore: tokens,
        attachDevUserHeader: false,
        enableLogging: false,
      );
      dio.httpClientAdapter = _ScriptedAdapter((options) async {
        captured = options;
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
      await client.get<Map<String, dynamic>>('/me');
      expect(captured.headers['Authorization'], 'Bearer access-token-value');
      expect(captured.headers['X-Dev-User-Id'], isNull);
    },
  );

  test('401 refresh is single-flight and retries once', () async {
    var calls = 0;
    var refreshes = 0;
    final tokens = AccessTokenStore();
    final dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'));
    final client = ApiClient(
      dio: dio,
      accessTokenStore: tokens,
      attachDevUserHeader: false,
      enableLogging: false,
      refresher: () async {
        refreshes += 1;
        tokens.replace(
          'rotated',
          DateTime.now().toUtc().add(const Duration(minutes: 10)),
        );
        return true;
      },
    );
    dio.httpClientAdapter = _ScriptedAdapter((options) async {
      calls += 1;
      if (options.extra['memyRetried'] == true) {
        return ResponseBody.fromString(
          jsonEncode({'ok': true}),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      return ResponseBody.fromString(
        '{}',
        401,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });
    final first = client.get<Map<String, dynamic>>('/me');
    final second = client.get<Map<String, dynamic>>('/me');
    await Future.wait([first, second]);
    expect(refreshes, inInclusiveRange(1, 2));
    expect(calls, greaterThanOrEqualTo(2));
  });
}
