import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/config/environment_config.dart';
import 'package:memy/core/network/api_client.dart';
import 'package:memy/features/goals/application/providers/goal_providers.dart';
import 'package:memy/features/goals/data/repositories/api_goal_repository.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/test_app.dart';

Map<String, dynamic> _goalJson(String name) {
  return {
    'id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    'userId': '00000000-0000-4000-8000-000000000001',
    'name': name,
    'description': '',
    'category': 'fitness',
    'customCategoryName': null,
    'priority': 'medium',
    'status': 'active',
    'targetAmountMinor': null,
    'currentAmountMinor': null,
    'currencyCode': null,
    'deadline': '2026-12-31T00:00:00.000Z',
    'progressPercent': 0,
    'notes': '',
    'archivedAt': null,
    'createdAt': '2026-08-08T00:00:00.000Z',
    'updatedAt': '2026-08-08T00:00:00.000Z',
    'milestones': <Map<String, dynamic>>[],
    'forecast': {
      'status': 'insufficientData',
      'asOf': '2026-08-08',
      'message': 'No target',
    },
  };
}

class _Adapter implements HttpClientAdapter {
  final List<Map<String, dynamic>> store = [];

  @override
  void close({bool force = false}) {}

  ResponseBody _body(Object data, {int status = 200}) {
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method == 'GET' && options.path == '/goals') {
      return _body(store);
    }
    if (options.method == 'POST' && options.path == '/goals') {
      final body = Map<String, dynamic>.from(options.data as Map);
      final created = _goalJson(body['name'] as String);
      store
        ..clear()
        ..add(created);
      return _body(created);
    }
    if (options.method == 'GET' &&
        options.path.startsWith('/goals/') &&
        !options.path.contains('/milestones')) {
      return _body(store.first);
    }
    return _body({
      'statusCode': 404,
      'code': 'RESOURCE_NOT_FOUND',
      'message': 'Not found',
    }, status: 404);
  }
}

void main() {
  testWidgets(
    'Quick Add → Add Goal → API repository → Goals list → Today update',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        LocalGoalRepository.initializedKey: true,
        LocalGoalRepository.storageKey: '{"schemaVersion":1,"goals":[]}',
      });
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      final adapter = _Adapter();
      dio.httpClientAdapter = adapter;
      final cache = LocalGoalRepository(
        prefs: prefs,
        seedBuilder: () => const [],
      );
      final apiRepo = ApiGoalRepository(
        client: ApiClient(dio: dio),
        cache: cache,
      );

      await pumpMemyApp(
        tester,
        seedGoals: false,
        prefs: prefs,
        overrides: [
          goalsDataSourceProvider.overrideWithValue(GoalsDataSource.api),
          localGoalRepositoryProvider.overrideWithValue(cache),
          apiClientProvider.overrideWithValue(ApiClient(dio: dio)),
          goalRepositoryProvider.overrideWithValue(apiRepo),
        ],
      );
      await signInToToday(tester);

      expect(find.text('Run marathon'), findsNothing);

      await tester.tap(find.byKey(const Key('nav_quick_add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quick_add_goal')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('goal_name_field')),
        'Run marathon',
      );
      await pickRequiredDeadline(tester);

      await tester.tap(find.byKey(const Key('goal_save_button')));
      await tester.pumpAndSettle();

      expect(adapter.store, hasLength(1));
      expect(find.text('Run marathon'), findsWidgets);
      expect(find.byKey(const Key('goal_detail_scroll')), findsOneWidget);

      await tester.tap(find.byKey(const Key('goal_detail_back')));
      await tester.pumpAndSettle();
      expect(find.text('Run marathon'), findsWidgets);

      final router = GoRouter.of(
        tester.element(find.text('Run marathon').first),
      );
      router.go(RoutePaths.today);
      await tester.pumpAndSettle();
      expect(find.text('Run marathon'), findsWidgets);
    },
  );
}
