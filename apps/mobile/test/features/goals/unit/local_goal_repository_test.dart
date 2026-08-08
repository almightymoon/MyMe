import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/goals/domain/entities/goal_milestone.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late LocalGoalRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = LocalGoalRepository(
      prefs: prefs,
      seedBuilder: () => [
        Goal(
          id: 'seed-1',
          name: 'Seed Goal',
          category: GoalCategory.financial,
          priority: GoalPriority.medium,
          status: GoalStatus.active,
          targetAmountMinor: 100000,
          currentAmountMinor: 10000,
          currencyCode: 'PKR',
          deadline: DateTime.now().add(const Duration(days: 90)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          progressPercent: 10,
        ),
      ],
    );
  });

  test('seeds once when storage is uninitialized', () async {
    final first = await repo.getGoals();
    expect(first, hasLength(1));
    expect(first.first.name, 'Seed Goal');

    await repo.deleteGoal('seed-1');
    expect(await repo.getGoals(), isEmpty);

    final again = LocalGoalRepository(prefs: prefs, seedBuilder: () => first);
    expect(await again.getGoals(), isEmpty);
  });

  test('create update delete and milestone completion', () async {
    await repo.ensureInitialized();
    await repo.deleteGoal('seed-1');

    final created = await repo.createGoal(
      Goal(
        id: 'new-1',
        name: 'New Goal',
        category: GoalCategory.career,
        priority: GoalPriority.high,
        status: GoalStatus.active,
        deadline: DateTime.now().add(const Duration(days: 40)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        progressPercent: 0,
        milestones: const [
          GoalMilestone(
            id: 'ms-1',
            goalId: 'new-1',
            title: 'First step',
            order: 0,
          ),
        ],
      ),
    );
    expect(created.name, 'New Goal');

    final completed = await repo.setMilestoneCompletion(
      goalId: 'new-1',
      milestoneId: 'ms-1',
      isCompleted: true,
    );
    expect(completed.isCompleted, isTrue);
    expect((await repo.getGoal('new-1'))!.progressPercent, 100);
    expect((await repo.getGoal('new-1'))!.status, GoalStatus.completed);

    final renamed = await repo.updateGoal(
      created.copyWith(name: 'Renamed', status: GoalStatus.active),
    );
    expect(renamed.name, 'Renamed');

    await repo.deleteGoal('new-1');
    expect(await repo.getGoal('new-1'), isNull);
  });

  test('corrupted persistence returns empty without throwing', () async {
    await prefs.setBool(LocalGoalRepository.initializedKey, true);
    await prefs.setString(LocalGoalRepository.storageKey, '{not-json');
    final local = LocalGoalRepository(prefs: prefs);
    expect(await local.getGoals(), isEmpty);

    await prefs.setString(
      LocalGoalRepository.storageKey,
      jsonEncode({
        'schemaVersion': 1,
        'goals': [
          {
            'id': 'good',
            'name': 'Good',
            'category': 'career',
            'priority': 'low',
            'status': 'active',
            'deadline': '2027-01-01',
            'createdAt': '2026-01-01',
            'updatedAt': '2026-01-01',
            'progressPercent': 0,
            'milestones': [],
          },
          'totally-invalid',
          {'id': null},
        ],
      }),
    );
    final mixed = LocalGoalRepository(prefs: prefs);
    final goals = await mixed.getGoals();
    expect(goals, hasLength(1));
    expect(goals.first.name, 'Good');
  });
}
