import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/goals/domain/entities/goal_forecast.dart';
import 'package:memy/features/goals/domain/entities/goal_milestone.dart';
import 'package:memy/features/goals/domain/services/goal_forecast_service.dart';
import 'package:memy/features/goals/domain/services/goal_progress_calculator.dart';

Goal _financialGoal({
  required int target,
  required int current,
  required DateTime deadline,
  GoalStatus status = GoalStatus.active,
}) {
  return Goal(
    id: 'g1',
    name: 'Emergency Fund',
    category: GoalCategory.financial,
    priority: GoalPriority.high,
    status: status,
    targetAmountMinor: target,
    currentAmountMinor: current,
    currencyCode: 'PKR',
    deadline: deadline,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    progressPercent: 0,
  );
}

void main() {
  const service = GoalForecastService();
  final asOf = DateTime(2026, 8, 8);

  test('serialization round-trip preserves fields', () {
    final goal = Goal(
      id: 'abc',
      name: 'Publish paper',
      description: 'Finish draft',
      category: GoalCategory.education,
      priority: GoalPriority.medium,
      status: GoalStatus.active,
      deadline: DateTime(2026, 12, 15),
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 7, 1),
      progressPercent: 20,
      notes: 'focus block',
      milestones: [
        GoalMilestone(
          id: 'm1',
          goalId: 'abc',
          title: 'Outline',
          order: 0,
          isCompleted: true,
          completedAt: DateTime(2026, 6, 10),
        ),
      ],
    );

    final restored = Goal.fromJson(goal.toJson());
    expect(restored.id, goal.id);
    expect(restored.name, goal.name);
    expect(restored.category, GoalCategory.education);
    expect(restored.milestones, hasLength(1));
    expect(restored.milestones.first.title, 'Outline');
    expect(restored.milestones.first.isCompleted, isTrue);
  });

  test('deserializes unknown enum values with safe fallbacks', () {
    final goal = Goal.fromJson({
      'id': 'x',
      'name': 'X',
      'category': 'not-a-real-category',
      'priority': 'nope',
      'status': 'weird',
      'deadline': '2026-12-01T00:00:00.000',
      'createdAt': '2026-01-01T00:00:00.000',
      'updatedAt': '2026-01-01T00:00:00.000',
      'progressPercent': 10,
      'milestones': 'bad',
    });
    expect(goal.category, GoalCategory.personalDevelopment);
    expect(goal.priority, GoalPriority.medium);
    expect(goal.status, GoalStatus.active);
    expect(goal.milestones, isEmpty);
  });

  test('forecast required monthly uses documented months formula', () {
    final goal = _financialGoal(
      target: 1000000, // 10,000.00
      current: 0,
      deadline: asOf.add(const Duration(days: 60)),
    );
    final forecast = service.forecast(goal, asOf: asOf);
    // ceil(60 / 30.4375) = 2
    expect(forecast.estimatedMonthsRemaining, 2);
    expect(forecast.requiredMonthlyContributionMinor, 500000);
    expect(forecast.status, GoalForecastStatus.onTrack);
  });

  test('forecast overdue when deadline passed', () {
    final goal = _financialGoal(
      target: 100000,
      current: 10000,
      deadline: asOf.subtract(const Duration(days: 3)),
    );
    final forecast = service.forecast(goal, asOf: asOf);
    expect(forecast.status, GoalForecastStatus.overdue);
    expect(forecast.remainingAmountMinor, 90000);
  });

  test('forecast completed when target reached', () {
    final goal = _financialGoal(
      target: 100000,
      current: 100000,
      deadline: asOf.add(const Duration(days: 30)),
    );
    final forecast = service.forecast(goal, asOf: asOf);
    expect(forecast.status, GoalForecastStatus.completed);
    expect(forecast.remainingAmountMinor, 0);
  });

  test('forecast insufficient data without target', () {
    final goal = Goal(
      id: 'g2',
      name: 'Fitness',
      category: GoalCategory.fitness,
      priority: GoalPriority.low,
      status: GoalStatus.active,
      deadline: asOf.add(const Duration(days: 40)),
      createdAt: asOf,
      updatedAt: asOf,
      progressPercent: 10,
    );
    final forecast = service.forecast(goal, asOf: asOf);
    expect(forecast.status, GoalForecastStatus.insufficientData);
  });

  test('deadline today is treated as at-risk runway of one day', () {
    final goal = _financialGoal(target: 10000, current: 0, deadline: asOf);
    final forecast = service.forecast(goal, asOf: asOf);
    expect(forecast.daysRemaining, 0);
    expect(forecast.estimatedMonthsRemaining, 1);
    expect(forecast.requiredMonthlyContributionMinor, 10000);
    expect(forecast.status, GoalForecastStatus.atRisk);
  });

  test('negative current amount is treated as zero remaining basis', () {
    final goal = _financialGoal(
      target: 10000,
      current: -500,
      deadline: asOf.add(const Duration(days: 30)),
    );
    final forecast = service.forecast(goal, asOf: asOf);
    expect(forecast.remainingAmountMinor, 10000);
  });

  test('progress calculator uses amounts then milestones', () {
    final withAmount = GoalProgressCalculator.withRecalculatedProgress(
      _financialGoal(
        target: 10000,
        current: 2500,
        deadline: asOf.add(const Duration(days: 10)),
      ),
    );
    expect(withAmount.progressPercent, 25);

    final withMilestones = GoalProgressCalculator.withRecalculatedProgress(
      Goal(
        id: 'm',
        name: 'M',
        category: GoalCategory.career,
        priority: GoalPriority.medium,
        status: GoalStatus.active,
        deadline: asOf.add(const Duration(days: 10)),
        createdAt: asOf,
        updatedAt: asOf,
        progressPercent: 0,
        milestones: const [
          GoalMilestone(
            id: '1',
            goalId: 'm',
            title: 'A',
            order: 0,
            isCompleted: true,
          ),
          GoalMilestone(id: '2', goalId: 'm', title: 'B', order: 1),
        ],
      ),
    );
    expect(withMilestones.progressPercent, 50);
  });
}
