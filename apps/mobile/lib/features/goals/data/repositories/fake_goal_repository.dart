import 'dart:async';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/services/goal_progress_calculator.dart';
import '../../domain/value_objects/money_minor.dart';

/// In-memory goals repository for UI demos and widget tests.
class FakeGoalRepository implements GoalRepository {
  FakeGoalRepository({List<Goal>? initial})
    : _goals = List<Goal>.from(initial ?? const []);

  final List<Goal> _goals;
  final _controller = StreamController<List<Goal>>.broadcast();

  List<Goal> get snapshot => List.unmodifiable(_goals);

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_goals));
    }
  }

  @override
  Stream<List<Goal>> watchGoals() async* {
    yield List.unmodifiable(_goals);
    yield* _controller.stream;
  }

  @override
  Future<List<Goal>> getGoals() async => List.unmodifiable(_goals);

  @override
  Future<Goal?> getGoal(String id) async {
    for (final goal in _goals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final prepared = GoalProgressCalculator.withRecalculatedProgress(goal);
    _goals.add(prepared);
    _emit();
    return prepared;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index < 0) throw StateError('Goal not found: ${goal.id}');
    final prepared = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(updatedAt: DateTime.now()),
    );
    _goals[index] = prepared;
    _emit();
    return prepared;
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    _emit();
  }

  @override
  Future<Goal> archiveGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index < 0) throw StateError('Goal not found: $id');
    final now = DateTime.now();
    final archived = GoalProgressCalculator.withRecalculatedProgress(
      _goals[index].copyWith(
        status: GoalStatus.archived,
        archivedAt: now,
        updatedAt: now,
      ),
    );
    _goals[index] = archived;
    _emit();
    return archived;
  }

  @override
  Future<GoalMilestone> addMilestone(
    String goalId,
    GoalMilestone milestone,
  ) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw StateError('Goal not found: $goalId');
    final goal = _goals[index];
    final nextMilestones = GoalProgressCalculator.reindex([
      ...goal.milestones,
      milestone.copyWith(goalId: goalId, order: goal.milestones.length),
    ]);
    final updated = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(milestones: nextMilestones, updatedAt: DateTime.now()),
    );
    _goals[index] = updated;
    _emit();
    return updated.milestones.firstWhere((m) => m.id == milestone.id);
  }

  @override
  Future<GoalMilestone> updateMilestone(GoalMilestone milestone) async {
    final index = _goals.indexWhere((g) => g.id == milestone.goalId);
    if (index < 0) throw StateError('Goal not found: ${milestone.goalId}');
    final goal = _goals[index];
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
    _goals[index] = updated;
    _emit();
    return updated.milestones.firstWhere((m) => m.id == milestone.id);
  }

  @override
  Future<void> deleteMilestone(String goalId, String milestoneId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw StateError('Goal not found: $goalId');
    final goal = _goals[index];
    final next = goal.milestones.where((m) => m.id != milestoneId).toList();
    _goals[index] = GoalProgressCalculator.withRecalculatedProgress(
      goal.copyWith(
        milestones: GoalProgressCalculator.reindex(next),
        updatedAt: DateTime.now(),
      ),
    );
    _emit();
  }

  @override
  Future<GoalMilestone> setMilestoneCompletion({
    required String goalId,
    required String milestoneId,
    required bool isCompleted,
  }) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw StateError('Goal not found: $goalId');
    final goal = _goals[index];
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
    _goals[index] = updated;
    _emit();
    return updated.milestones.firstWhere((m) => m.id == milestoneId);
  }

  @override
  Future<Goal> updateGoalProgress({
    required String goalId,
    MoneyMinor? currentAmountMinor,
    double? progressPercent,
  }) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw StateError('Goal not found: $goalId');
    var next = _goals[index].copyWith(updatedAt: DateTime.now());
    if (currentAmountMinor != null) {
      next = next.copyWith(currentAmountMinor: currentAmountMinor);
    }
    if (progressPercent != null && next.targetAmountMinor == null) {
      next = next.copyWith(progressPercent: progressPercent);
    }
    next = GoalProgressCalculator.withRecalculatedProgress(next);
    _goals[index] = next;
    _emit();
    return next;
  }

  void dispose() {
    _controller.close();
  }
}
