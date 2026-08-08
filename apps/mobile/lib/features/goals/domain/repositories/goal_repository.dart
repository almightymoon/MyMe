import '../entities/goal.dart';
import '../entities/goal_milestone.dart';

/// Contract for goal persistence.
///
/// Implementations: [LocalGoalRepository], [ApiGoalRepository], [FakeGoalRepository].
abstract class GoalRepository {
  Stream<List<Goal>> watchGoals();

  Future<List<Goal>> getGoals();

  Future<Goal?> getGoal(String id);

  Future<Goal> createGoal(Goal goal);

  Future<Goal> updateGoal(Goal goal);

  Future<void> deleteGoal(String id);

  Future<Goal> archiveGoal(String id);

  Future<GoalMilestone> addMilestone(String goalId, GoalMilestone milestone);

  Future<GoalMilestone> updateMilestone(GoalMilestone milestone);

  Future<void> deleteMilestone(String goalId, String milestoneId);

  Future<GoalMilestone> setMilestoneCompletion({
    required String goalId,
    required String milestoneId,
    required bool isCompleted,
  });

  Future<Goal> updateGoalProgress({
    required String goalId,
    int? currentAmountMinor,
    double? progressPercent,
  });
}
