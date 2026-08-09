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

Map<String, dynamic> _houseGoalJson(Map<String, dynamic> body) {
  final milestonesRaw = body['milestones'];
  final milestones = <Map<String, dynamic>>[];
  if (milestonesRaw is List) {
    for (var i = 0; i < milestonesRaw.length; i++) {
      final m = Map<String, dynamic>.from(milestonesRaw[i] as Map);
      milestones.add({
        'id': 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbb$i',
        'goalId': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        'title': m['title'],
        'description': m['description'],
        'targetDate': m['targetDate'],
        'isCompleted': false,
        'completedAt': null,
        'order': m['order'] ?? i,
        'createdAt': '2026-08-08T00:00:00.000Z',
        'updatedAt': '2026-08-08T00:00:00.000Z',
      });
    }
  }
  return {
    'id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    'userId': '00000000-0000-4000-8000-000000000001',
    'name': body['name'],
    'description': body['description'] ?? '',
    'category': body['category'] ?? 'financial',
    'customCategoryName': null,
    'priority': body['priority'] ?? 'high',
    'status': 'active',
    'targetAmountMinor': body['targetAmountMinor'],
    'currentAmountMinor': body['currentAmountMinor'] ?? '0',
    'currencyCode': body['currencyCode'] ?? 'PKR',
    'deadline': body['deadline'],
    'progressPercent': 0,
    'notes': body['notes'] ?? '',
    'archivedAt': null,
    'createdAt': '2026-08-08T00:00:00.000Z',
    'updatedAt': '2026-08-08T00:00:00.000Z',
    'milestones': milestones,
    'forecast': {
      'status': 'onTrack',
      'asOf': '2026-08-08',
      'remainingAmountMinor': body['targetAmountMinor'],
      'requiredMonthlyContributionMinor': '1',
      'requiredWeeklyContributionMinor': '1',
      'message': 'On track if contribution pace is maintained.',
    },
  };
}

class _RecordingAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>> store = [];
  final List<Map<String, dynamic>> createBodies = [];
  int createCount = 0;

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
      createCount += 1;
      final body = Map<String, dynamic>.from(options.data as Map);
      createBodies.add(body);
      final created = _houseGoalJson(body);
      store
        ..clear()
        ..add(created);
      // Simulate brief server latency so duplicate taps hit isSubmitting.
      await Future<void>.delayed(const Duration(milliseconds: 80));
      return _body(created, status: 201);
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
    'Large PKR financial Goal: one create with milestones, Today refresh, no conflicting progress',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        LocalGoalRepository.initializedKey: true,
        LocalGoalRepository.storageKey: '{"schemaVersion":1,"goals":[]}',
      });
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      final adapter = _RecordingAdapter();
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

      await tester.tap(find.byKey(const Key('nav_quick_add')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('quick_add_goal')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('goal_name_field')),
        'Buy a House',
      );
      await tester.enterText(
        find.byKey(const Key('goal_target_amount_field')),
        '150000000',
      );
      await tester.enterText(
        find.byKey(const Key('goal_current_amount_field')),
        '0',
      );
      await tester.enterText(
        find.byKey(const Key('goal_currency_field')),
        'PKR',
      );

      await pickRequiredDeadline(tester);

      // Form uses SingleChildScrollView so milestone fields stay mounted.
      final milestone0 = find.byKey(const Key('goal_milestone_field_0'));
      await tester.ensureVisible(milestone0);
      await tester.pumpAndSettle();
      await tester.enterText(milestone0, 'Build deposit fund');
      await tester.tap(find.byKey(const Key('goal_add_milestone_field')));
      await tester.pumpAndSettle();
      final milestone1 = find.byKey(const Key('goal_milestone_field_1'));
      await tester.ensureVisible(milestone1);
      await tester.pumpAndSettle();
      await tester.enterText(milestone1, 'Complete financing review');

      // Rapid duplicate Save taps — only one request should be sent.
      final save = find.byKey(const Key('goal_save_button'));
      await tester.tap(save);
      await tester.pump(); // start submit
      await tester.tap(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(adapter.createCount, 1);
      expect(adapter.createBodies, hasLength(1));
      final body = adapter.createBodies.single;
      expect(body['targetAmountMinor'], '15000000000');
      expect(body['currentAmountMinor'], '0');
      expect(body['currencyCode'], 'PKR');
      expect(body.containsKey('progressPercent'), isFalse);
      expect(body['milestones'], isA<List>());
      expect((body['milestones'] as List), hasLength(2));
      expect(
        (body['milestones'] as List).map((m) => (m as Map)['title']),
        containsAll(['Build deposit fund', 'Complete financing review']),
      );

      expect(find.text('Buy a House'), findsWidgets);
      expect(find.byKey(const Key('goal_detail_scroll')), findsOneWidget);
      expect(find.textContaining('PKR 150,000,000'), findsWidgets);
      expect(find.text('Build deposit fund'), findsWidgets);
      expect(find.text('Complete financing review'), findsWidgets);
      expect(find.byKey(const Key('goal_forecast_card')), findsOneWidget);

      await tester.tap(find.byKey(const Key('goal_detail_back')));
      await tester.pumpAndSettle();

      final router = GoRouter.of(
        tester.element(find.text('Buy a House').first),
      );
      router.go(RoutePaths.today);
      await tester.pumpAndSettle();
      expect(find.text('Buy a House'), findsWidgets);
      expect(find.textContaining('PKR'), findsWidgets);
    },
  );

  testWidgets('current amount exceeding target shows validation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      LocalGoalRepository.initializedKey: true,
      LocalGoalRepository.storageKey: '{"schemaVersion":1,"goals":[]}',
    });
    final prefs = await SharedPreferences.getInstance();
    await pumpMemyApp(tester, seedGoals: false, prefs: prefs);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick_add_goal')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('goal_name_field')),
      'Overflow',
    );
    await tester.enterText(
      find.byKey(const Key('goal_target_amount_field')),
      '100',
    );
    await tester.enterText(
      find.byKey(const Key('goal_current_amount_field')),
      '200',
    );
    await pickRequiredDeadline(tester);
    await tester.tap(find.byKey(const Key('goal_save_button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('exceeds target'), findsOneWidget);
  });
}
