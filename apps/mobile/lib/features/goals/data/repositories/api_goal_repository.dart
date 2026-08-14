import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/value_objects/money_minor.dart';
import '../dto/goal_api_mapper.dart';
import 'local_goal_repository.dart';

/// Remote [GoalRepository] backed by NestJS `/api/v1/goals`.
///
/// Uses [LocalGoalRepository] as a read cache:
/// - successful list/detail responses refresh the cache
/// - network failures on reads fall back to cached goals
/// - writes require connectivity (no fake offline sync)
class ApiGoalRepository implements GoalRepository {
  ApiGoalRepository({required this.client, required this.cache});

  final ApiClient client;
  final LocalGoalRepository cache;
  final _controller = StreamController<List<Goal>>.broadcast();

  void _emit(List<Goal> goals) {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(goals));
    }
  }

  Future<List<Goal>> _fetchAndCache() async {
    final response = await client.get<dynamic>(
      '/goals',
      queryParameters: const {'includeArchived': true},
    );
    final goals = GoalApiMapper.goalsFromList(response.data);
    await cache.replaceAll(goals);
    _emit(goals);
    return goals;
  }

  Future<Goal> _getAndCache(String id) async {
    final response = await client.get<dynamic>('/goals/$id');
    final goal = GoalApiMapper.goalFromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
    await cache.upsert(goal);
    final all = await cache.getGoals();
    _emit(all);
    return goal;
  }

  Future<T> _write<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AppException catch (error) {
      if (error.isNetworkish) {
        throw AppException.connectionRequired();
      }
      rethrow;
    }
  }

  @override
  Stream<List<Goal>> watchGoals() async* {
    try {
      yield await _fetchAndCache();
    } on AppException catch (error) {
      if (error.isNetworkish) {
        yield await cache.getGoals();
      } else {
        rethrow;
      }
    }
    yield* _controller.stream;
  }

  @override
  Future<List<Goal>> getGoals() async {
    try {
      return await _fetchAndCache();
    } on AppException catch (error) {
      if (error.isNetworkish) {
        return cache.getGoals();
      }
      rethrow;
    }
  }

  @override
  Future<Goal?> getGoal(String id) async {
    try {
      return await _getAndCache(id);
    } on AppException catch (error) {
      if (error.kind == AppErrorKind.notFound) {
        return null;
      }
      if (error.isNetworkish) {
        return cache.getGoal(id);
      }
      rethrow;
    }
  }

  @override
  Future<Goal> createGoal(Goal goal) {
    return _write(() async {
      // Draft milestones are nested in the create body — a single request,
      // server assigns milestone ids alongside the goal id.
      final response = await client.post<dynamic>(
        '/goals',
        data: GoalApiMapper.createGoalBody(goal),
      );
      final created = GoalApiMapper.goalFromJson(
        Map<String, dynamic>.from(response.data as Map),
      );

      await cache.upsert(created);
      _emit(await cache.getGoals());
      return created;
    });
  }

  @override
  Future<Goal> updateGoal(Goal goal) {
    return _write(() async {
      final response = await client.patch<dynamic>(
        '/goals/${goal.id}',
        data: GoalApiMapper.updateGoalBody(goal),
      );
      final updated = GoalApiMapper.goalFromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await cache.upsert(updated);
      _emit(await cache.getGoals());
      return updated;
    });
  }

  @override
  Future<void> deleteGoal(String id) {
    return _write(() async {
      await client.delete<dynamic>('/goals/$id');
      await cache.deleteGoal(id);
      _emit(await cache.getGoals());
    });
  }

  /// Clears the local Goals cache only. Never calls the backend.
  Future<int> clearLocalCacheOnly() async {
    final before = (await cache.getGoals()).length;
    await cache.clearAllLocalData();
    _emit(const []);
    return before;
  }

  @override
  Future<Goal> archiveGoal(String id) {
    return _write(() async {
      final response = await client.post<dynamic>('/goals/$id/archive');
      final updated = GoalApiMapper.goalFromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await cache.upsert(updated);
      _emit(await cache.getGoals());
      return updated;
    });
  }

  @override
  Future<GoalMilestone> addMilestone(String goalId, GoalMilestone milestone) {
    return _write(() async {
      final response = await client.post<dynamic>(
        '/goals/$goalId/milestones',
        data: GoalApiMapper.createMilestoneBody(milestone),
      );
      final data = response.data;
      if (data is! Map) {
        throw AppException.serverFailure(
          'Unexpected response shape from milestone creation.',
        );
      }
      final result = GoalApiMapper.milestoneCreationFromJson(
        Map<String, dynamic>.from(data),
      );
      await cache.upsert(result.goal);
      _emit(await cache.getGoals());
      return result.createdMilestone;
    });
  }

  @override
  Future<GoalMilestone> updateMilestone(GoalMilestone milestone) {
    return _write(() async {
      final response = await client.patch<dynamic>(
        '/goals/${milestone.goalId}/milestones/${milestone.id}',
        data: GoalApiMapper.updateMilestoneBody(milestone),
      );
      final goal = GoalApiMapper.goalFromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await cache.upsert(goal);
      _emit(await cache.getGoals());
      return goal.milestones.firstWhere(
        (m) => m.id == milestone.id,
        orElse: () => throw AppException.notFound('Milestone not found'),
      );
    });
  }

  @override
  Future<void> deleteMilestone(String goalId, String milestoneId) {
    return _write(() async {
      final response = await client.delete<dynamic>(
        '/goals/$goalId/milestones/$milestoneId',
      );
      final goal = GoalApiMapper.goalFromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await cache.upsert(goal);
      _emit(await cache.getGoals());
    });
  }

  @override
  Future<GoalMilestone> setMilestoneCompletion({
    required String goalId,
    required String milestoneId,
    required bool isCompleted,
  }) {
    return _write(() async {
      final path = isCompleted
          ? '/goals/$goalId/milestones/$milestoneId/complete'
          : '/goals/$goalId/milestones/$milestoneId/reopen';
      final response = await client.post<dynamic>(path);
      final goal = GoalApiMapper.goalFromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await cache.upsert(goal);
      _emit(await cache.getGoals());
      return goal.milestones.firstWhere(
        (m) => m.id == milestoneId,
        orElse: () => throw AppException.notFound('Milestone not found'),
      );
    });
  }

  @override
  Future<Goal> updateGoalProgress({
    required String goalId,
    MoneyMinor? currentAmountMinor,
    double? progressPercent,
  }) {
    return _write(() async {
      final response = await client.post<dynamic>(
        '/goals/$goalId/progress',
        data: GoalApiMapper.progressBody(
          currentAmountMinor: currentAmountMinor,
          progressPercent: progressPercent,
        ),
      );
      final updated = GoalApiMapper.goalFromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await cache.upsert(updated);
      _emit(await cache.getGoals());
      return updated;
    });
  }

  void dispose() {
    _controller.close();
  }
}
