import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/network/api_client.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_config.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_origin.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';
import 'package:memy/features/finance/data/repositories/fake_finance_repository.dart';
import 'package:memy/features/finance/data/seed/finance_seed.dart';
import 'package:memy/features/finance/domain/entities/finance_category.dart';
import 'package:memy/features/finance/domain/entities/finance_enums.dart';
import 'package:memy/features/goals/data/repositories/api_goal_repository.dart';
import 'package:memy/features/goals/data/repositories/fake_goal_repository.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/habits/data/repositories/fake_habit_repository.dart';
import 'package:memy/features/trust/data/repositories/memy_local_data_deletion_coordinator.dart';
import 'package:memy/features/trust/domain/entities/deletion_scope.dart';
import 'package:memy/features/trust/domain/services/local_data_deletion_coordinator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Goal _goal(String id, String name) => Goal(
  id: id,
  name: name,
  category: GoalCategory.health,
  priority: GoalPriority.high,
  status: GoalStatus.active,
  deadline: DateTime(2027),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  progressPercent: 0,
);

MemyCalendarEvent _event({
  required String id,
  required CalendarEventOrigin origin,
}) {
  final start = DateTime.utc(2026, 8, 10, 10);
  return MemyCalendarEvent(
    id: id,
    title: 'Event $id',
    time: TimedCalendarEventTime(
      startUtc: start,
      endUtc: start.add(const Duration(hours: 1)),
    ),
    origin: origin,
    syncStatus: CalendarEventSyncStatus.synced,
    createdAt: start,
    updatedAt: start,
  );
}

/// Spy ApiGoalRepository that records [deleteGoal] calls.
class _SpyApiGoalRepository extends ApiGoalRepository {
  _SpyApiGoalRepository({required super.client, required super.cache});

  int deleteGoalCalls = 0;

  @override
  Future<void> deleteGoal(String id) async {
    deleteGoalCalls++;
    await cache.deleteGoal(id);
  }
}

void main() {
  test('wipe goals clears fake repository via plan+execute', () async {
    SharedPreferences.setMockInitialValues({});
    final goals = FakeGoalRepository(
      initial: [_goal('g1', 'Run'), _goal('g2', 'Read')],
    );

    final coordinator = MemyLocalDataDeletionCoordinator(goalRepository: goals);
    final plan = await coordinator.plan({DeletionScope.goals});
    final result = await coordinator.execute(plan, confirmationPhrase: null);

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

  test('API goals wipe never calls deleteGoal', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cache = LocalGoalRepository(
      prefs: prefs,
      seedBuilder: () => const [],
    );
    await cache.replaceAll([_goal('g1', 'API cached')]);

    final spy = _SpyApiGoalRepository(
      client: ApiClient(baseUrl: 'http://127.0.0.1/api/v1'),
      cache: cache,
    );
    final coordinator = MemyLocalDataDeletionCoordinator(goalRepository: spy);

    final plan = await coordinator.plan({DeletionScope.goals});
    final report = await coordinator.execute(plan, confirmationPhrase: null);

    expect(spy.deleteGoalCalls, 0);
    expect(report.deletedCounts['goalsLocalCache'], 1);
    expect(await cache.getGoals(), isEmpty);
  });

  test('typed confirmation required for allLocalMeMyData', () async {
    SharedPreferences.setMockInitialValues({});
    final goals = FakeGoalRepository(initial: [_goal('g1', 'Run')]);
    final coordinator = MemyLocalDataDeletionCoordinator(goalRepository: goals);

    final plan = await coordinator.plan({DeletionScope.allLocalMeMyData});
    expect(plan.requiresTypedConfirmation, isTrue);
    expect(
      plan.whatWillRemain.any((e) => e.toLowerCase().contains('calendar')),
      isTrue,
    );
    expect(
      plan.whatWillRemain.any((e) => e.toLowerCase().contains('health')),
      isTrue,
    );

    await expectLater(
      () => coordinator.execute(plan, confirmationPhrase: null),
      throwsA(isA<DeletionConfirmationException>()),
    );
    await expectLater(
      () => coordinator.execute(plan, confirmationPhrase: 'wrong'),
      throwsA(isA<DeletionConfirmationException>()),
    );

    final report = await coordinator.execute(
      plan,
      confirmationPhrase: LocalDataDeletionCoordinator.globalConfirmationPhrase,
    );
    expect(report.cancelled, isFalse);
    expect(report.stepResults, isNotEmpty);

    goals.dispose();
  });

  test('partial failure continues remaining steps', () async {
    SharedPreferences.setMockInitialValues({});
    final goals = FakeGoalRepository(initial: [_goal('g1', 'Run')]);
    final habits = FakeHabitRepository();
    // Finance missing → finance step fails; goals/habits should still run.
    final coordinator = MemyLocalDataDeletionCoordinator(
      goalRepository: goals,
      habitRepository: habits,
    );

    final plan = await coordinator.plan({
      DeletionScope.goals,
      DeletionScope.finance,
      DeletionScope.habits,
    });
    final report = await coordinator.execute(plan, confirmationPhrase: null);

    final byScope = {for (final s in report.stepResults) s.scope: s.status};
    expect(byScope[DeletionScope.goals], DeletionStepStatus.completed);
    expect(byScope[DeletionScope.finance], DeletionStepStatus.failed);
    expect(byScope[DeletionScope.habits], DeletionStepStatus.completed);
    expect(await goals.getGoals(), isEmpty);

    goals.dispose();
    habits.dispose();
  });

  test('calendar imported-only does not wipe config', () async {
    SharedPreferences.setMockInitialValues({});
    final calendar = FakeCalendarRepository(
      seedEvents: [
        _event(id: 'ext1', origin: CalendarEventOrigin.external),
        _event(id: 'loc1', origin: CalendarEventOrigin.local),
      ],
    );
    await calendar.saveConfig(
      const CalendarConfig(
        readableCalendarIds: ['cal_a'],
        defaultWritableCalendarId: 'cal_a',
      ),
    );

    final coordinator = MemyLocalDataDeletionCoordinator(
      calendarRepository: calendar,
    );
    final plan = await coordinator.plan({DeletionScope.calendarImportedCache});
    await coordinator.execute(plan, confirmationPhrase: null);

    final remaining = await calendar.getEventsInRange(
      startUtc: DateTime.utc(2000),
      endUtc: DateTime.utc(2100),
      includeHidden: true,
    );
    expect(remaining.map((e) => e.id), ['loc1']);
    final config = await calendar.getConfig();
    expect(config.defaultWritableCalendarId, 'cal_a');
    expect(config.readableCalendarIds, ['cal_a']);

    calendar.dispose();
  });

  test('finance wipe resets categories to seed defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final finance = FakeFinanceRepository(
      initialTransactions: const [],
      initialCategories: [
        ...FinanceSeed.demoCategories(),
        FinanceCategory(
          id: 'cat_custom',
          name: 'Custom',
          type: TransactionType.expense,
          iconKey: 'other',
          isCustom: true,
          createdAt: DateTime(2026),
        ),
      ],
    );

    final coordinator = MemyLocalDataDeletionCoordinator(
      financeRepository: finance,
    );
    final plan = await coordinator.plan({DeletionScope.finance});
    await coordinator.execute(plan, confirmationPhrase: null);

    final cats = await finance.getCategories();
    expect(cats.any((c) => c.id == 'cat_custom'), isFalse);
    expect(
      cats.map((c) => c.id).toList(),
      FinanceSeed.demoCategories().map((c) => c.id).toList(),
    );

    finance.dispose();
  });
}
