import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/repositories/fake_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/trust/data/repositories/memy_local_data_deletion_coordinator.dart';
import 'package:memy/features/trust/domain/entities/deletion_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('wipe goals clears fake repository', () async {
    SharedPreferences.setMockInitialValues({});
    final goals = FakeGoalRepository(
      initial: [
        Goal(
          id: 'g1',
          name: 'Run',
          category: GoalCategory.health,
          priority: GoalPriority.high,
          status: GoalStatus.active,
          deadline: DateTime(2027),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          progressPercent: 0,
        ),
        Goal(
          id: 'g2',
          name: 'Read',
          category: GoalCategory.personalDevelopment,
          priority: GoalPriority.low,
          status: GoalStatus.active,
          deadline: DateTime(2027),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          progressPercent: 0,
        ),
      ],
    );

    final coordinator = MemyLocalDataDeletionCoordinator(goalRepository: goals);
    final result = await coordinator.delete({DeletionScope.goals});

    expect(result.deletedCounts['goals'], 2);
    expect(await goals.getGoals(), isEmpty);
    expect(
      result.warnings.any(
        (w) => w.contains('HealthKit') || w.contains('calendar'),
      ),
      isTrue,
    );

    goals.dispose();
  });
}
