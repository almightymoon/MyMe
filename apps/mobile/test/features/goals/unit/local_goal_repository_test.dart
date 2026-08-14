import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/goals/domain/entities/goal_milestone.dart';
import 'package:memy/features/goals/domain/value_objects/money_minor.dart';
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
          targetAmountMinor: MoneyMinor.fromInt(100000),
          currentAmountMinor: MoneyMinor.fromInt(10000),
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

  test('new writes persist money amounts as digit strings', () async {
    await repo.ensureInitialized();
    await repo.deleteGoal('seed-1');

    await repo.createGoal(
      Goal(
        id: 'money-1',
        name: 'Big Goal',
        category: GoalCategory.financial,
        priority: GoalPriority.high,
        status: GoalStatus.active,
        targetAmountMinor: MoneyMinor.parse('15000000000'),
        currentAmountMinor: MoneyMinor.fromInt(1000000),
        currencyCode: 'PKR',
        deadline: DateTime.now().add(const Duration(days: 40)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        progressPercent: 0,
      ),
    );

    final raw = prefs.getString(LocalGoalRepository.storageKey)!;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final goals = decoded['goals'] as List<dynamic>;
    final saved = goals.first as Map<String, dynamic>;
    expect(saved['targetAmountMinor'], isA<String>());
    expect(saved['targetAmountMinor'], '15000000000');
    expect(saved['currentAmountMinor'], '1000000');

    final loaded = await repo.getGoal('money-1');
    expect(loaded!.targetAmountMinor, MoneyMinor.parse('15000000000'));
    expect(loaded.currentAmountMinor, MoneyMinor.fromInt(1000000));
  });

  test('legacy int money JSON still loads', () async {
    await prefs.setBool(LocalGoalRepository.initializedKey, true);
    await prefs.setString(
      LocalGoalRepository.storageKey,
      jsonEncode({
        'schemaVersion': 1,
        'goals': [
          {
            'id': 'legacy-1',
            'name': 'Legacy Goal',
            'category': 'financial',
            'priority': 'medium',
            'status': 'active',
            'targetAmountMinor': 1000000,
            'currentAmountMinor': 250000,
            'currencyCode': 'PKR',
            'deadline': '2027-01-01T00:00:00.000',
            'createdAt': '2026-01-01T00:00:00.000',
            'updatedAt': '2026-01-01T00:00:00.000',
            'progressPercent': 25,
            'milestones': [],
          },
        ],
      }),
    );

    final local = LocalGoalRepository(prefs: prefs);
    final goals = await local.getGoals();
    expect(goals, hasLength(1));
    expect(goals.first.targetAmountMinor, MoneyMinor.fromInt(1000000));
    expect(goals.first.currentAmountMinor, MoneyMinor.fromInt(250000));
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
