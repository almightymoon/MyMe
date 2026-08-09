import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/dto/goal_api_mapper.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/goals/domain/entities/goal_milestone.dart';
import 'package:memy/features/goals/domain/value_objects/money_minor.dart';

Goal _goal({
  GoalCategory category = GoalCategory.financial,
  MoneyMinor? target,
  MoneyMinor? current,
  double progressPercent = 42,
  List<GoalMilestone> milestones = const [],
}) {
  final now = DateTime.utc(2026, 8, 8);
  return Goal(
    id: '11111111-1111-4111-8111-111111111111',
    name: 'Buy a House',
    description: '',
    category: category,
    priority: GoalPriority.high,
    status: GoalStatus.active,
    targetAmountMinor: target,
    currentAmountMinor: current,
    currencyCode: target != null || current != null ? 'PKR' : null,
    deadline: DateTime.utc(2027, 12, 31),
    createdAt: now,
    updatedAt: now,
    progressPercent: progressPercent,
    milestones: milestones,
  );
}

void main() {
  group('GoalApiMapper financial progress omission', () {
    test('createGoalBody omits progressPercent when amounts present', () {
      final body = GoalApiMapper.createGoalBody(
        _goal(
          target: MoneyMinor.parse('15000000000'),
          current: MoneyMinor.zero,
          progressPercent: 5,
          milestones: [
            const GoalMilestone(
              id: 'm1',
              goalId: 'g',
              title: 'Build deposit fund',
              order: 0,
            ),
            const GoalMilestone(
              id: 'm2',
              goalId: 'g',
              title: 'Complete financing review',
              order: 1,
            ),
          ],
        ),
      );

      expect(body.containsKey('progressPercent'), isFalse);
      expect(body['targetAmountMinor'], '15000000000');
      expect(body['currentAmountMinor'], '0');
      expect(body['milestones'], hasLength(2));
    });

    test('updateGoalBody omits progressPercent when amounts present', () {
      final body = GoalApiMapper.updateGoalBody(
        _goal(
          target: MoneyMinor.parse('10000'),
          current: MoneyMinor.parse('2500'),
          progressPercent: 80,
        ),
      );

      expect(body.containsKey('progressPercent'), isFalse);
      expect(body['targetAmountMinor'], '10000');
      expect(body['currentAmountMinor'], '2500');
    });

    test('createGoalBody sends progressPercent for non-financial goals', () {
      final body = GoalApiMapper.createGoalBody(
        _goal(category: GoalCategory.fitness, progressPercent: 12),
      );

      expect(body['progressPercent'], 12);
      expect(body.containsKey('targetAmountMinor'), isFalse);
    });

    test('progressBody with amount omits progressPercent', () {
      final body = GoalApiMapper.progressBody(
        currentAmountMinor: MoneyMinor.parse('5000'),
        progressPercent: 99,
      );

      expect(body['currentAmountMinor'], '5000');
      expect(body.containsKey('progressPercent'), isFalse);
    });

    test('progressBody without amount may send progressPercent', () {
      final body = GoalApiMapper.progressBody(progressPercent: 40);

      expect(body['progressPercent'], 40);
      expect(body.containsKey('currentAmountMinor'), isFalse);
    });
  });
}
