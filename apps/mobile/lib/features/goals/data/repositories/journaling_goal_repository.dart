import '../../../auth/domain/secure_session_store.dart';
import '../../../sync/domain/sync_models.dart';
import '../../../sync/domain/sync_mutation_journal.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/value_objects/money_minor.dart';

class JournalingGoalRepository implements GoalRepository {
  JournalingGoalRepository({
    required this._inner,
    required this.journal,
    required this.session,
  });

  final GoalRepository _inner;
  final SyncMutationJournal journal;
  final StoredAuthSession? session;

  @override
  Stream<List<Goal>> watchGoals() => _inner.watchGoals();

  @override
  Future<List<Goal>> getGoals() => _inner.getGoals();

  @override
  Future<Goal?> getGoal(String id) => _inner.getGoal(id);

  @override
  Future<Goal> createGoal(Goal goal) async {
    final created = await _inner.createGoal(goal);
    _journal(SyncOperationType.create, created);
    return created;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final updated = await _inner.updateGoal(goal);
    _journal(SyncOperationType.update, updated);
    return updated;
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _inner.deleteGoal(id);
    final current = session;
    if (current == null) return;
    journal.recordDelete(
      accountId: current.userId,
      deviceId: current.deviceId,
      entityType: SyncEntityType.goal,
      entityId: id,
      localVersion: 1,
    );
  }

  @override
  Future<Goal> archiveGoal(String id) async {
    final archived = await _inner.archiveGoal(id);
    _journal(SyncOperationType.update, archived);
    return archived;
  }

  @override
  Future<GoalMilestone> addMilestone(String goalId, GoalMilestone milestone) {
    return _inner.addMilestone(goalId, milestone);
  }

  @override
  Future<GoalMilestone> updateMilestone(GoalMilestone milestone) {
    return _inner.updateMilestone(milestone);
  }

  @override
  Future<void> deleteMilestone(String goalId, String milestoneId) {
    return _inner.deleteMilestone(goalId, milestoneId);
  }

  @override
  Future<GoalMilestone> setMilestoneCompletion({
    required String goalId,
    required String milestoneId,
    required bool isCompleted,
  }) {
    return _inner.setMilestoneCompletion(
      goalId: goalId,
      milestoneId: milestoneId,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<Goal> updateGoalProgress({
    required String goalId,
    MoneyMinor? currentAmountMinor,
    double? progressPercent,
  }) async {
    final updated = await _inner.updateGoalProgress(
      goalId: goalId,
      currentAmountMinor: currentAmountMinor,
      progressPercent: progressPercent,
    );
    _journal(SyncOperationType.update, updated);
    return updated;
  }

  void _journal(SyncOperationType operation, Goal goal) {
    final current = session;
    if (current == null) return;
    final payload = Map<String, Object?>.from(goal.toJson());
    if (operation == SyncOperationType.create) {
      journal.recordCreate(
        accountId: current.userId,
        deviceId: current.deviceId,
        entityType: SyncEntityType.goal,
        entityId: goal.id,
        localVersion: 1,
        payload: payload,
      );
    } else {
      journal.recordUpdate(
        accountId: current.userId,
        deviceId: current.deviceId,
        entityType: SyncEntityType.goal,
        entityId: goal.id,
        localVersion: 1,
        payload: payload,
      );
    }
  }
}
