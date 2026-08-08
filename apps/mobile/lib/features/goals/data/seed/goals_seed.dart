import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/entities/goal_summary.dart';
import '../../domain/services/goal_progress_calculator.dart';
import '../../domain/services/money_format.dart';

/// Demo seed goals inspired by `/app/js/data.js`.
///
/// Used only when local storage has never been initialized.
abstract final class GoalsSeed {
  static List<Goal> demoGoals({DateTime? now}) {
    final asOf = now ?? DateTime.now();
    final goals = <Goal>[
      _goal(
        id: 'house',
        name: 'Buy a House',
        description: 'Long-term home purchase fund.',
        category: GoalCategory.financial,
        priority: GoalPriority.high,
        targetMinor: 15000000000, // PKR 150,000,000
        currentMinor: 1050000000, // ~7%
        deadline: DateTime(asOf.year + 8, 12, 31),
        asOf: asOf,
        milestones: const [],
      ),
      _goal(
        id: 'emergency',
        name: 'Build Emergency Fund',
        description: 'Six months of essential expenses.',
        category: GoalCategory.financial,
        priority: GoalPriority.critical,
        targetMinor: 100000000, // PKR 1,000,000
        currentMinor: 43000000, // 43%
        deadline: DateTime(asOf.year + 1, 6, 30),
        asOf: asOf,
        milestones: [
          _ms(
            'emergency',
            'e1',
            'Save first PKR 250K',
            0,
            true,
            asOf.subtract(const Duration(days: 40)),
          ),
          _ms('emergency', 'e2', 'Reach PKR 500K', 1, false, null),
          _ms('emergency', 'e3', 'Hit full PKR 1M', 2, false, null),
        ],
      ),
      _goal(
        id: 'weight',
        name: 'Lose 5 kg',
        description: 'Reach target weight of 67 kg.',
        category: GoalCategory.fitness,
        priority: GoalPriority.medium,
        targetMinor: null,
        currentMinor: null,
        deadline: asOf.add(const Duration(days: 120)),
        asOf: asOf,
        progressOverride: 65,
        milestones: [
          _ms('weight', 'w1', 'Log meals for 14 days', 0, true, asOf),
          _ms('weight', 'w2', 'Complete 20 workouts', 1, true, asOf),
          _ms('weight', 'w3', 'Hit 67 kg weigh-in', 2, false, null),
        ],
      ),
      _goal(
        id: 'paper',
        name: 'Publish Research Paper',
        description: 'Submit and publish AI research paper.',
        category: GoalCategory.education,
        priority: GoalPriority.high,
        targetMinor: null,
        currentMinor: null,
        deadline: DateTime(2026, 12, 15),
        asOf: asOf,
        progressOverride: 20,
        milestones: [
          _ms('paper', 'p1', 'Finish outline', 0, true, asOf),
          _ms('paper', 'p2', 'Complete draft', 1, false, null),
          _ms('paper', 'p3', 'Submit for review', 2, false, null),
        ],
      ),
    ];
    return goals.map(GoalProgressCalculator.withRecalculatedProgress).toList();
  }

  static Goal get featured {
    return demoGoals().firstWhere(
      (g) => g.id == 'emergency',
      orElse: () => demoGoals().first,
    );
  }

  static List<GoalSummary> get demoGoalSummaries =>
      demoGoals().map(GoalSummary.fromGoal).toList(growable: false);

  static Goal _goal({
    required String id,
    required String name,
    required String description,
    required GoalCategory category,
    required GoalPriority priority,
    required int? targetMinor,
    required int? currentMinor,
    required DateTime deadline,
    required DateTime asOf,
    required List<GoalMilestone> milestones,
    double? progressOverride,
  }) {
    final draft = Goal(
      id: id,
      name: name,
      description: description,
      category: category,
      priority: priority,
      status: GoalStatus.active,
      targetAmountMinor: targetMinor,
      currentAmountMinor: currentMinor,
      currencyCode: targetMinor == null
          ? null
          : MoneyFormat.defaultCurrencyCode,
      deadline: deadline,
      createdAt: asOf.subtract(const Duration(days: 60)),
      updatedAt: asOf,
      progressPercent: progressOverride ?? 0,
      notes: '',
      milestones: milestones,
    );
    if (progressOverride != null && targetMinor == null) {
      return draft;
    }
    return GoalProgressCalculator.withRecalculatedProgress(draft);
  }

  static GoalMilestone _ms(
    String goalId,
    String id,
    String title,
    int order,
    bool done,
    DateTime? completedAt,
  ) {
    return GoalMilestone(
      id: id,
      goalId: goalId,
      title: title,
      order: order,
      isCompleted: done,
      completedAt: done ? completedAt : null,
    );
  }
}
