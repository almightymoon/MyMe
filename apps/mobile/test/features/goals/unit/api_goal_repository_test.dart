import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/errors/app_exception.dart';
import 'package:memy/core/network/api_client.dart';
import 'package:memy/core/network/api_error_parser.dart';
import 'package:memy/features/goals/data/repositories/api_goal_repository.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _goalJson({
  String id = '11111111-1111-4111-8111-111111111111',
  String name = 'Emergency fund',
  double progress = 20,
  int current = 100000,
}) {
  return {
    'id': id,
    'userId': '00000000-0000-4000-8000-000000000001',
    'name': name,
    'description': '',
    'category': 'financial',
    'customCategoryName': null,
    'priority': 'high',
    'status': 'active',
    'targetAmountMinor': 1000000,
    'currentAmountMinor': current,
    'currencyCode': 'PKR',
    'deadline': '2026-12-31T00:00:00.000Z',
    'progressPercent': progress,
    'notes': '',
    'archivedAt': null,
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
    'milestones': <Map<String, dynamic>>[],
    'forecast': {
      'status': 'onTrack',
      'asOf': '2026-08-08',
      'message': 'On track',
    },
  };
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }
}

ResponseBody _json(Object data, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Future<ApiGoalRepository> _repoWithAdapter(
  Future<ResponseBody> Function(RequestOptions options) handler,
) async {
  SharedPreferences.setMockInitialValues({
    LocalGoalRepository.initializedKey: true,
    LocalGoalRepository.storageKey: '{"schemaVersion":1,"goals":[]}',
  });
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
  dio.httpClientAdapter = _ScriptedAdapter(handler);
  final client = ApiClient(dio: dio, enableLogging: false);
  final cache = LocalGoalRepository(prefs: prefs, seedBuilder: () => const []);
  return ApiGoalRepository(client: client, cache: cache);
}

void main() {
  group('ApiErrorParser', () {
    test('maps validation body', () {
      final error = ApiErrorParser.fromStatusAndBody(
        statusCode: 400,
        data: {
          'statusCode': 400,
          'code': 'GOAL_VALIDATION_ERROR',
          'message': 'Name is required',
          'details': {},
        },
      );
      expect(error.kind, AppErrorKind.validation);
      expect(error.userMessage, 'Name is required');
    });

    test('maps unauthorized', () {
      final error = ApiErrorParser.fromStatusAndBody(
        statusCode: 401,
        data: {'message': 'Dev auth required', 'code': 'DEV_AUTH_REQUIRED'},
      );
      expect(error.kind, AppErrorKind.unauthorized);
    });
  });

  group('ApiClient mapDioException', () {
    test('maps timeout', () {
      final error = ApiClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/goals'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      expect(error.kind, AppErrorKind.timeout);
    });
  });

  group('ApiGoalRepository', () {
    test('list goals maps DTO to domain', () async {
      final repo = await _repoWithAdapter((options) async {
        expect(options.path, '/goals');
        return _json([_goalJson()]);
      });

      final goals = await repo.getGoals();
      expect(goals, hasLength(1));
      expect(goals.first.name, 'Emergency fund');
      expect(goals.first.targetAmountMinor, 1000000);
    });

    test('create goal posts body and returns server goal', () async {
      final repo = await _repoWithAdapter((options) async {
        expect(options.method, 'POST');
        expect(options.path, '/goals');
        return _json(_goalJson(name: 'Run marathon', progress: 0, current: 0));
      });

      final created = await repo.createGoal(
        Goal(
          id: 'client-temp',
          name: 'Run marathon',
          category: GoalCategory.fitness,
          priority: GoalPriority.medium,
          status: GoalStatus.active,
          deadline: DateTime.utc(2026, 12, 31),
          createdAt: DateTime.utc(2026, 8, 8),
          updatedAt: DateTime.utc(2026, 8, 8),
          progressPercent: 0,
        ),
      );
      expect(created.id, '11111111-1111-4111-8111-111111111111');
      expect(created.name, 'Run marathon');
    });

    test('update goal patches', () async {
      final repo = await _repoWithAdapter((options) async {
        expect(options.method, 'PATCH');
        return _json(_goalJson(name: 'Updated'));
      });

      final updated = await repo.updateGoal(
        Goal(
          id: '11111111-1111-4111-8111-111111111111',
          name: 'Updated',
          category: GoalCategory.financial,
          priority: GoalPriority.high,
          status: GoalStatus.active,
          deadline: DateTime.utc(2026, 12, 31),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 8, 8),
          progressPercent: 20,
          targetAmountMinor: 1000000,
          currentAmountMinor: 100000,
          currencyCode: 'PKR',
        ),
      );
      expect(updated.name, 'Updated');
    });

    test('delete goal', () async {
      var deleted = false;
      final repo = await _repoWithAdapter((options) async {
        expect(options.method, 'DELETE');
        deleted = true;
        return ResponseBody.fromString('', 204);
      });
      await repo.deleteGoal('11111111-1111-4111-8111-111111111111');
      expect(deleted, isTrue);
    });

    test('validation error mapping', () async {
      final repo = await _repoWithAdapter((options) async {
        return _json({
          'statusCode': 400,
          'code': 'GOAL_VALIDATION_ERROR',
          'message': 'customCategoryName is required',
          'details': {},
        }, status: 400);
      });

      expect(
        () => repo.createGoal(
          Goal(
            id: 'x',
            name: 'X',
            category: GoalCategory.custom,
            priority: GoalPriority.low,
            status: GoalStatus.active,
            deadline: DateTime.utc(2026, 12, 31),
            createdAt: DateTime.utc(2026, 8, 8),
            updatedAt: DateTime.utc(2026, 8, 8),
            progressPercent: 0,
          ),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.kind,
            'kind',
            AppErrorKind.validation,
          ),
        ),
      );
    });

    test('unauthorized mapping', () async {
      final repo = await _repoWithAdapter((options) async {
        return _json({
          'statusCode': 401,
          'code': 'DEV_AUTH_REQUIRED',
          'message': 'Provide X-Dev-User-Id',
        }, status: 401);
      });

      expect(
        () => repo.getGoals(),
        throwsA(
          isA<AppException>().having(
            (e) => e.kind,
            'kind',
            AppErrorKind.unauthorized,
          ),
        ),
      );
    });

    test('timeout mapping', () async {
      SharedPreferences.setMockInitialValues({
        LocalGoalRepository.initializedKey: true,
        LocalGoalRepository.storageKey: '{"schemaVersion":1,"goals":[]}',
      });
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'));
      dio.httpClientAdapter = _ScriptedAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });
      final repo = ApiGoalRepository(
        client: ApiClient(dio: dio),
        cache: LocalGoalRepository(prefs: prefs, seedBuilder: () => const []),
      );

      // Empty cache + timeout on list → networkish → returns cache (empty)
      final goals = await repo.getGoals();
      expect(goals, isEmpty);
    });

    test('offline cached read after successful list', () async {
      var calls = 0;
      final repo = await _repoWithAdapter((options) async {
        calls++;
        if (calls == 1) {
          return _json([_goalJson()]);
        }
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      final first = await repo.getGoals();
      expect(first, hasLength(1));

      final second = await repo.getGoals();
      expect(second, hasLength(1));
      expect(second.first.name, 'Emergency fund');
      expect(calls, 2);
    });

    test('offline write throws connection required', () async {
      final repo = await _repoWithAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      expect(
        () => repo.createGoal(
          Goal(
            id: 'x',
            name: 'Offline',
            category: GoalCategory.fitness,
            priority: GoalPriority.low,
            status: GoalStatus.active,
            deadline: DateTime.utc(2026, 12, 31),
            createdAt: DateTime.utc(2026, 8, 8),
            updatedAt: DateTime.utc(2026, 8, 8),
            progressPercent: 0,
          ),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.kind,
            'kind',
            AppErrorKind.connectionRequired,
          ),
        ),
      );
    });
  });
}
