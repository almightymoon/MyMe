import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/services/goal_progress_calculator.dart';
import '../../domain/value_objects/money_minor.dart';
import '../seed/goals_seed.dart';

/// Local JSON persistence for goals (SharedPreferences).
///
/// Schema:
/// ```json
/// {
///   "schemaVersion": 1,
///   "goals": [ /* Goal.toJson() */ ]
/// }
/// ```
///
/// Initialization flag `memy_goals_initialized_v1` ensures demo goals seed
/// only once. Deleting all goals does not reseed.
///
/// `schemaVersion` stays `1`: this is a dual-read format, not a breaking
/// schema change. `Goal.toJson()`/`Goal.fromJson()` write monetary amounts
/// as decimal strings going forward, but [MoneyMinor.fromJson] transparently
/// reads legacy `int`/`num` amounts persisted by earlier app versions, so
/// existing on-disk documents keep loading without a migration step.
class LocalGoalRepository implements GoalRepository {
  LocalGoalRepository({required this.prefs, this.seedBuilder});

  static const int schemaVersion = 1;
  static const String storageKey = 'memy_goals_v1';
  static const String initializedKey = 'memy_goals_initialized_v1';

  final SharedPreferences prefs;
  final List<Goal> Function()? seedBuilder;

  final _controller = StreamController<List<Goal>>.broadcast();
  Future<void>? _initFuture;
  List<Goal> _cache = const [];

  Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    final initialized = prefs.getBool(initializedKey) ?? false;
    if (!initialized) {
      _cache = List<Goal>.unmodifiable(
        seedBuilder?.call() ?? GoalsSeed.demoGoals(),
      );
      await _persist(_cache);
      await prefs.setBool(initializedKey, true);
      return;
    }

    _cache = _readFromDisk();
  }

  List<Goal> _readFromDisk() {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const [];
      }
      final map = Map<String, dynamic>.from(decoded);
      final version = (map['schemaVersion'] as num?)?.toInt() ?? 0;
      if (version != schemaVersion) {
        // Future migrations can branch here; for now treat as empty-safe.
        if (version == 0) return const [];
      }
      final list = map['goals'];
      if (list is! List) return const [];
      final goals = <Goal>[];
      for (final item in list) {
        try {
          if (item is Map<String, dynamic>) {
            goals.add(Goal.fromJson(item));
          } else if (item is Map) {
            goals.add(Goal.fromJson(Map<String, dynamic>.from(item)));
          }
        } catch (_) {
          // Skip malformed goal entries.
        }
      }
      return List<Goal>.unmodifiable(goals);
    } catch (_) {
      // Corrupted document — do not crash; keep initialized, return empty.
      return const [];
    }
  }

  Future<void> _persist(List<Goal> goals) async {
    final payload = jsonEncode({
      'schemaVersion': schemaVersion,
      'goals': goals.map((g) => g.toJson()).toList(),
    });
    await prefs.setString(storageKey, payload);
    _cache = List<Goal>.unmodifiable(goals);
    if (!_controller.isClosed) {
      _controller.add(_cache);
    }
  }

  Future<List<Goal>> _requireCache() async {
    await ensureInitialized();
    return _cache;
  }

  Future<void> _replace(List<Goal> next) => _persist(next);

  /// Replace the entire local store (used as API read-cache).
  Future<void> replaceAll(List<Goal> goals) async {
    await ensureInitialized();
    await _persist(List<Goal>.unmodifiable(goals));
  }

  /// Insert or update a single goal in the local store.
  Future<void> upsert(Goal goal) async {
    final goals = [...await _requireCache()];
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index < 0) {
      goals.add(goal);
    } else {
      goals[index] = goal;
    }
    await _persist(goals);
  }

  Goal _requireGoal(List<Goal> goals, String id) {
    return goals.firstWhere(
      (g) => g.id == id,
      orElse: () => throw StateError('Goal not found: $id'),
    );
  }

  @override
  Stream<List<Goal>> watchGoals() async* {
    yield await _requireCache();
    yield* _controller.stream;
  }

  @override
  Future<List<Goal>> getGoals() async => _requireCache();

  @override
  Future<Goal?> getGoal(String id) async {
    final goals = await _requireCache();
    for (final goal in goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final goals = [...await _requireCache()];
    final prepared = GoalProgressCalculator.withRecalculatedProgress(goal);
    goals.add(prepared);
    await _replace(goals);
    return prepared;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final goals = [...await _requireCache()];
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index < 0) throw StateError('Goal not found: ${goal.id}');
    final prepared = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(updatedAt: DateTime.now()),
    );
    goals[index] = prepared;
    await _replace(goals);
    return prepared;
  }

  @override
  Future<void> deleteGoal(String id) async {
    final goals = [...await _requireCache()]..removeWhere((g) => g.id == id);
    await _replace(goals);
  }

  @override
  Future<Goal> archiveGoal(String id) async {
    final goals = [...await _requireCache()];
    final index = goals.indexWhere((g) => g.id == id);
    if (index < 0) throw StateError('Goal not found: $id');
    final now = DateTime.now();
    final archived = GoalProgressCalculator.withRecalculatedProgress(
      goals[index].copyWith(
        status: GoalStatus.archived,
        archivedAt: now,
        updatedAt: now,
      ),
    );
    goals[index] = archived;
    await _replace(goals);
    return archived;
  }

  @override
  Future<GoalMilestone> addMilestone(
    String goalId,
    GoalMilestone milestone,
  ) async {
    final goals = [...await _requireCache()];
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw StateError('Goal not found: $goalId');
    final goal = goals[index];
    final nextMilestones = GoalProgressCalculator.reindex([
      ...goal.milestones,
      milestone.copyWith(goalId: goalId, order: goal.milestones.length),
    ]);
    final updated = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(milestones: nextMilestones, updatedAt: DateTime.now()),
    );
    goals[index] = updated;
    await _replace(goals);
    return updated.milestones.firstWhere((m) => m.id == milestone.id);
  }

  @override
  Future<GoalMilestone> updateMilestone(GoalMilestone milestone) async {
    final goals = [...await _requireCache()];
    final index = goals.indexWhere((g) => g.id == milestone.goalId);
    if (index < 0) throw StateError('Goal not found: ${milestone.goalId}');
    final goal = goals[index];
    final next = [
      for (final m in goal.milestones)
        if (m.id == milestone.id) milestone else m,
    ];
    final updated = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(
        milestones: GoalProgressCalculator.reindex(next),
        updatedAt: DateTime.now(),
      ),
    );
    goals[index] = updated;
    await _replace(goals);
    return updated.milestones.firstWhere((m) => m.id == milestone.id);
  }

  @override
  Future<void> deleteMilestone(String goalId, String milestoneId) async {
    final goals = [...await _requireCache()];
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw StateError('Goal not found: $goalId');
    final goal = goals[index];
    final next = goal.milestones.where((m) => m.id != milestoneId).toList();
    goals[index] = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(
        milestones: GoalProgressCalculator.reindex(next),
        updatedAt: DateTime.now(),
      ),
    );
    await _replace(goals);
  }

  @override
  Future<GoalMilestone> setMilestoneCompletion({
    required String goalId,
    required String milestoneId,
    required bool isCompleted,
  }) async {
    final goals = [...await _requireCache()];
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw StateError('Goal not found: $goalId');
    final goal = goals[index];
    final now = DateTime.now();
    final next = [
      for (final m in goal.milestones)
        if (m.id == milestoneId)
          m.copyWith(
            isCompleted: isCompleted,
            completedAt: isCompleted ? now : null,
            clearCompletedAt: !isCompleted,
          )
        else
          m,
    ];
    final updated = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(milestones: next, updatedAt: now),
    );
    goals[index] = updated;
    await _replace(goals);
    return updated.milestones.firstWhere((m) => m.id == milestoneId);
  }

  @override
  Future<Goal> updateGoalProgress({
    required String goalId,
    MoneyMinor? currentAmountMinor,
    double? progressPercent,
  }) async {
    final goals = [...await _requireCache()];
    final goal = _requireGoal(goals, goalId);
    final index = goals.indexWhere((g) => g.id == goalId);
    var next = goal.copyWith(updatedAt: DateTime.now());
    if (currentAmountMinor != null) {
      next = next.copyWith(currentAmountMinor: currentAmountMinor);
    }
    if (progressPercent != null && next.targetAmountMinor == null) {
      next = next.copyWith(progressPercent: progressPercent);
    }
    next = GoalProgressCalculator.withRecalculatedProgress(next);
    goals[index] = next;
    await _replace(goals);
    return next;
  }

  void dispose() {
    _controller.close();
  }
}
