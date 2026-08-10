import 'package:shared_preferences/shared_preferences.dart';

import '../../../calendar/data/repositories/fake_calendar_repository.dart';
import '../../../calendar/data/repositories/local_calendar_repository.dart';
import '../../../calendar/domain/repositories/calendar_repository.dart';
import '../../../finance/data/repositories/fake_finance_repository.dart';
import '../../../finance/data/repositories/local_finance_repository.dart';
import '../../../finance/domain/repositories/finance_repository.dart';
import '../../../goals/data/repositories/fake_goal_repository.dart';
import '../../../goals/data/repositories/local_goal_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../habits/data/repositories/fake_habit_repository.dart';
import '../../../habits/data/repositories/local_habit_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../../health/domain/repositories/health_repository.dart';
import '../../domain/entities/deletion_scope.dart';
import '../../domain/services/local_data_deletion_coordinator.dart';
import '../../presentation/appearance/appearance_preferences.dart';

/// Wipes MeMy-owned local data without deleting external calendar events
/// or platform Health store contents.
class MemyLocalDataDeletionCoordinator implements LocalDataDeletionCoordinator {
  MemyLocalDataDeletionCoordinator({
    this.goalRepository,
    this.financeRepository,
    this.habitRepository,
    this.calendarRepository,
    this.healthRepository,
    this.prefs,
    this.clock,
  });

  final GoalRepository? goalRepository;
  final FinanceRepository? financeRepository;
  final HabitRepository? habitRepository;
  final CalendarRepository? calendarRepository;
  final HealthRepository? healthRepository;
  final SharedPreferences? prefs;
  final DateTime Function()? clock;

  @override
  Future<DeletionResult> delete(Set<DeletionScope> scopes) async {
    final expanded = _expand(scopes);
    final counts = <String, int>{};
    final warnings = <String>[];

    for (final scope in expanded) {
      switch (scope) {
        case DeletionScope.goals:
          counts['goals'] = await _clearGoals(warnings);
        case DeletionScope.finance:
          counts['finance'] = await _clearFinance(warnings);
        case DeletionScope.habits:
          counts['habits'] = await _clearHabits(warnings);
        case DeletionScope.calendarCache:
          final cleared = await _clearCalendarCache(warnings);
          counts['calendarEvents'] = cleared.events;
          counts['calendarLinks'] = cleared.links;
          counts['calendarConflicts'] = cleared.conflicts;
          counts['calendarOps'] = cleared.ops;
        case DeletionScope.healthCache:
        case DeletionScope.healthConnectionConfiguration:
          counts['healthDisconnect'] = await _clearHealth(warnings);
        case DeletionScope.preferences:
          counts['preferences'] = await _clearPreferences(warnings);
        case DeletionScope.allLocalMeMyData:
          // Expanded away.
          break;
      }
    }

    warnings.add(
      'External device calendar events and HealthKit / Health Connect '
      'data were not deleted.',
    );

    return DeletionResult(
      scopes: expanded.toList(growable: false),
      deletedCounts: counts,
      warnings: warnings,
      completedAt: (clock?.call() ?? DateTime.now()).toUtc(),
    );
  }

  Set<DeletionScope> _expand(Set<DeletionScope> scopes) {
    if (!scopes.contains(DeletionScope.allLocalMeMyData)) {
      return Set<DeletionScope>.from(scopes)
        ..remove(DeletionScope.allLocalMeMyData);
    }
    return {
      DeletionScope.goals,
      DeletionScope.finance,
      DeletionScope.habits,
      DeletionScope.calendarCache,
      DeletionScope.healthCache,
      DeletionScope.healthConnectionConfiguration,
      DeletionScope.preferences,
    };
  }

  Future<int> _clearGoals(List<String> warnings) async {
    final repo = goalRepository;
    if (repo is LocalGoalRepository) {
      final before = (await repo.getGoals()).length;
      await repo.clearAllLocalData();
      return before;
    }
    if (repo is FakeGoalRepository) {
      final before = (await repo.getGoals()).length;
      await repo.clearAllLocalData();
      return before;
    }
    if (repo != null) {
      final goals = await repo.getGoals();
      for (final g in goals) {
        await repo.deleteGoal(g.id);
      }
      warnings.add(
        'Goals cleared via per-item delete (repository has no clearAll).',
      );
      return goals.length;
    }
    warnings.add('Goals repository unavailable.');
    return 0;
  }

  Future<int> _clearFinance(List<String> warnings) async {
    final repo = financeRepository;
    if (repo is LocalFinanceRepository) {
      final before = (await repo.getTransactions()).length;
      await repo.clearAllLocalData();
      return before;
    }
    if (repo is FakeFinanceRepository) {
      final before = (await repo.getTransactions()).length;
      await repo.clearAllLocalData();
      return before;
    }
    if (repo != null) {
      final txs = await repo.getTransactions();
      for (final tx in txs) {
        await repo.deleteTransaction(tx.id);
      }
      warnings.add(
        'Finance cleared via per-item delete (repository has no clearAll).',
      );
      return txs.length;
    }
    warnings.add('Finance repository unavailable.');
    return 0;
  }

  Future<int> _clearHabits(List<String> warnings) async {
    final repo = habitRepository;
    if (repo is LocalHabitRepository) {
      final before = (await repo.getHabits()).length;
      await repo.clearAllLocalData();
      return before;
    }
    if (repo is FakeHabitRepository) {
      final before = (await repo.getHabits()).length;
      await repo.clearAllLocalData();
      return before;
    }
    warnings.add('Habits repository unavailable or not clearable.');
    return 0;
  }

  Future<({int events, int links, int conflicts, int ops})> _clearCalendarCache(
    List<String> warnings,
  ) async {
    final repo = calendarRepository;
    if (repo is LocalCalendarRepository) {
      // Include MeMy-owned local events for a full MeMy calendar cache wipe.
      // Never calls the device calendar gateway.
      return repo.clearLocalCache(includeMeMyOwnedEvents: true);
    }
    if (repo is FakeCalendarRepository) {
      return repo.clearLocalCache(includeMeMyOwnedEvents: true);
    }
    warnings.add('Calendar repository unavailable or not clearable.');
    return (events: 0, links: 0, conflicts: 0, ops: 0);
  }

  Future<int> _clearHealth(List<String> warnings) async {
    final repo = healthRepository;
    if (repo == null) {
      warnings.add('Health repository unavailable.');
      return 0;
    }
    await repo.disconnect();
    return 1;
  }

  Future<int> _clearPreferences(List<String> warnings) async {
    final p = prefs;
    if (p == null) {
      warnings.add('SharedPreferences unavailable for preference wipe.');
      return 0;
    }
    var cleared = 0;
    for (final key in AppearancePreferences.allKeys) {
      if (p.containsKey(key)) {
        await p.remove(key);
        cleared++;
      }
    }
    return cleared;
  }
}
