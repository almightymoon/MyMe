import 'package:shared_preferences/shared_preferences.dart';

import '../../../calendar/data/repositories/fake_calendar_repository.dart';
import '../../../calendar/data/repositories/local_calendar_repository.dart';
import '../../../calendar/domain/entities/calendar_config.dart';
import '../../../calendar/domain/repositories/calendar_repository.dart';
import '../../../finance/data/repositories/fake_finance_repository.dart';
import '../../../finance/data/repositories/local_finance_repository.dart';
import '../../../finance/domain/repositories/finance_repository.dart';
import '../../../goals/data/repositories/api_goal_repository.dart';
import '../../../goals/data/repositories/fake_goal_repository.dart';
import '../../../goals/data/repositories/local_goal_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../habits/data/repositories/fake_habit_repository.dart';
import '../../../habits/data/repositories/local_habit_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../../health/domain/repositories/health_repository.dart';
import '../../domain/entities/deletion_scope.dart';
import '../../domain/services/local_data_deletion_coordinator.dart';
import '../../domain/services/memy_owned_preference_keys.dart';

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

  bool _inFlight = false;

  @override
  bool get requiresTypedConfirmation => true;

  @override
  Future<DeletionPlan> plan(Set<DeletionScope> scopes) async {
    final expanded = _expand(scopes);
    final steps = <DeletionStep>[];
    final whatDeleted = <String>[];
    final whatRemain = <String>[
      'Device calendar events (external stores)',
      'HealthKit / Health Connect platform data',
    ];
    final warnings = <String>[];

    final goalsApi = goalRepository is ApiGoalRepository;
    if (goalsApi) {
      whatRemain.add('Backend Goals (API) — only the local cache is cleared');
    }

    // Merge health scopes: both → single disconnect step.
    final wantsHealthDerived =
        expanded.contains(DeletionScope.healthDerivedCache) ||
        expanded.contains(DeletionScope.healthCache);
    final wantsHealthDisconnect = expanded.contains(
      DeletionScope.healthConnectionConfiguration,
    );

    for (final scope in expanded) {
      if (scope == DeletionScope.healthCache ||
          scope == DeletionScope.healthDerivedCache ||
          scope == DeletionScope.healthConnectionConfiguration) {
        continue; // handled below as merged
      }
      if (scope == DeletionScope.calendarDeviceEvents) {
        warnings.add(
          'Device calendar event deletion is not part of local MeMy wipe '
          'and was skipped in this plan.',
        );
        continue;
      }

      switch (scope) {
        case DeletionScope.goals:
        case DeletionScope.goalsLocalCache:
          final count = await _estimateGoals();
          steps.add(
            DeletionStep(
              scope: goalsApi
                  ? DeletionScope.goalsLocalCache
                  : DeletionScope.goals,
              label: goalsApi ? 'Goals local cache' : 'Goals',
              whatWillBeDeleted: goalsApi
                  ? 'On-device Goals cache snapshot'
                  : 'MeMy Goals stored on this device',
              whatWillRemain: goalsApi
                  ? 'Backend Goals remain on the server'
                  : 'Nothing Goals-related remains locally',
              estimatedCount: count,
            ),
          );
          whatDeleted.add(
            goalsApi ? 'Goals local cache' : 'Goals on this device',
          );
        case DeletionScope.finance:
          final count = await _estimateFinance();
          steps.add(
            DeletionStep(
              scope: DeletionScope.finance,
              label: 'Finance',
              whatWillBeDeleted:
                  'Transactions on this device; custom categories reset '
                  'to seed defaults',
              whatWillRemain: 'Seed finance categories only',
              estimatedCount: count,
            ),
          );
          whatDeleted.add(
            'Finance transactions (categories reset to defaults)',
          );
        case DeletionScope.habits:
          final count = await _estimateHabits();
          steps.add(
            DeletionStep(
              scope: DeletionScope.habits,
              label: 'Habits',
              whatWillBeDeleted: 'Habits and check-ins on this device',
              whatWillRemain: 'Nothing Habits-related remains locally',
              estimatedCount: count,
            ),
          );
          whatDeleted.add('Habits and check-ins');
        case DeletionScope.calendarCache:
          steps.add(
            const DeletionStep(
              scope: DeletionScope.calendarCache,
              label: 'Calendar local cache',
              whatWillBeDeleted:
                  'Imported cache and MeMy-owned local calendar records',
              whatWillRemain:
                  'Device calendar events and connection config '
                  '(unless integration state is also selected)',
            ),
          );
          whatDeleted.add('Calendar local cache / MeMy events');
        case DeletionScope.calendarMeMyLocalRecords:
          steps.add(
            const DeletionStep(
              scope: DeletionScope.calendarMeMyLocalRecords,
              label: 'Calendar MeMy local records',
              whatWillBeDeleted: 'MeMy-authored local calendar events',
              whatWillRemain:
                  'Imported cache, connection config, and device calendars',
            ),
          );
          whatDeleted.add('Calendar MeMy local records');
        case DeletionScope.calendarImportedCache:
          steps.add(
            const DeletionStep(
              scope: DeletionScope.calendarImportedCache,
              label: 'Calendar imported cache',
              whatWillBeDeleted: 'Imported external event cache only',
              whatWillRemain:
                  'MeMy-owned local events, connection config, and '
                  'device calendars',
            ),
          );
          whatDeleted.add('Calendar imported cache');
        case DeletionScope.calendarIntegrationState:
          steps.add(
            const DeletionStep(
              scope: DeletionScope.calendarIntegrationState,
              label: 'Calendar integration state',
              whatWillBeDeleted: 'Calendar connection configuration',
              whatWillRemain: 'Event rows unless also selected separately',
            ),
          );
          whatDeleted.add('Calendar integration configuration');
        case DeletionScope.preferences:
          steps.add(
            const DeletionStep(
              scope: DeletionScope.preferences,
              label: 'Appearance preferences',
              whatWillBeDeleted: 'Theme and reduce-motion preferences',
              whatWillRemain: 'Other app state keys are untouched',
            ),
          );
          whatDeleted.add('Appearance preferences');
        case DeletionScope.allLocalMeMyData:
        case DeletionScope.calendarDeviceEvents:
        case DeletionScope.healthCache:
        case DeletionScope.healthDerivedCache:
        case DeletionScope.healthConnectionConfiguration:
          break;
      }
    }

    if (wantsHealthDerived && wantsHealthDisconnect) {
      steps.add(
        const DeletionStep(
          scope: DeletionScope.healthConnectionConfiguration,
          label: 'Health connection + derived cache',
          whatWillBeDeleted:
              'MeMy Health connection prefs and in-memory summaries',
          whatWillRemain: 'Platform HealthKit / Health Connect data',
          estimatedCount: 1,
        ),
      );
      whatDeleted.add('Health connection configuration and derived cache');
    } else if (wantsHealthDisconnect) {
      steps.add(
        const DeletionStep(
          scope: DeletionScope.healthConnectionConfiguration,
          label: 'Health connection configuration',
          whatWillBeDeleted: 'MeMy Health connection prefs (and derived cache)',
          whatWillRemain: 'Platform HealthKit / Health Connect data',
          estimatedCount: 1,
        ),
      );
      whatDeleted.add('Health connection configuration');
    } else if (wantsHealthDerived) {
      steps.add(
        const DeletionStep(
          scope: DeletionScope.healthDerivedCache,
          label: 'Health derived cache',
          whatWillBeDeleted: 'In-memory Health daily summaries only',
          whatWillRemain: 'Connection prefs and platform Health data',
          estimatedCount: 1,
        ),
      );
      whatDeleted.add('Health derived cache');
    }

    return DeletionPlan(
      requestedScopes: Set<DeletionScope>.from(scopes),
      steps: steps,
      requiresTypedConfirmation: scopes.contains(
        DeletionScope.allLocalMeMyData,
      ),
      whatWillBeDeleted: whatDeleted,
      whatWillRemain: whatRemain,
      warnings: warnings,
    );
  }

  @override
  Future<DeletionExecutionReport> execute(
    DeletionPlan plan, {
    required String? confirmationPhrase,
  }) async {
    if (_inFlight) {
      throw const DeletionInFlightException();
    }

    if (plan.requiresTypedConfirmation) {
      if (!LocalDataDeletionCoordinator.matchesGlobalConfirmation(
        confirmationPhrase,
      )) {
        throw const DeletionConfirmationException();
      }
    }

    return _executeSteps(plan, plan.steps);
  }

  @override
  Future<DeletionExecutionReport> retryFailed(
    DeletionExecutionReport previous, {
    required String? confirmationPhrase,
  }) async {
    final retryScopes = previous.retryableFailedScopes.toSet();
    if (retryScopes.isEmpty) {
      return previous;
    }
    if (previous.plan.requiresTypedConfirmation) {
      if (!LocalDataDeletionCoordinator.matchesGlobalConfirmation(
        confirmationPhrase,
      )) {
        throw const DeletionConfirmationException();
      }
    }

    final retrySteps = previous.plan.steps
        .where((s) => retryScopes.contains(s.scope))
        .toList(growable: false);
    final retryReport = await _executeSteps(previous.plan, retrySteps);

    final merged = <DeletionStepResult>[];
    for (final prior in previous.stepResults) {
      if (prior.status == DeletionStepStatus.completed) {
        merged.add(prior);
        continue;
      }
      final refreshed = retryReport.stepResults
          .where((r) => r.scope == prior.scope)
          .toList();
      if (refreshed.isNotEmpty) {
        merged.add(refreshed.first);
      } else {
        merged.add(prior);
      }
    }

    return DeletionExecutionReport(
      plan: previous.plan,
      stepResults: merged,
      warnings: [
        ...previous.warnings.where((w) => !w.startsWith('Step failed:')),
        ...retryReport.warnings,
      ],
      completedAt: retryReport.completedAt,
    );
  }

  Future<DeletionExecutionReport> _executeSteps(
    DeletionPlan plan,
    List<DeletionStep> steps,
  ) async {
    if (_inFlight) {
      throw const DeletionInFlightException();
    }

    _inFlight = true;
    final results = <DeletionStepResult>[];
    final warnings = List<String>.from(plan.warnings);

    try {
      for (final step in steps) {
        try {
          final count = await _runStep(step.scope);
          results.add(
            DeletionStepResult(
              scope: step.scope,
              status: DeletionStepStatus.completed,
              deletedCount: count,
            ),
          );
        } catch (_) {
          results.add(
            DeletionStepResult(
              scope: step.scope,
              status: DeletionStepStatus.failed,
              retryable: true,
              userSafeMessage:
                  'Could not clear ${step.label}. Other selected items '
                  'continued.',
            ),
          );
          warnings.add('Step failed: ${step.label}');
        }
      }

      warnings.add(
        'External device calendar events and HealthKit / Health Connect '
        'data were not deleted.',
      );

      return DeletionExecutionReport(
        plan: plan,
        stepResults: results,
        warnings: warnings,
        completedAt: (clock?.call() ?? DateTime.now()).toUtc(),
      );
    } finally {
      _inFlight = false;
    }
  }

  Set<DeletionScope> _expand(Set<DeletionScope> scopes) {
    if (!scopes.contains(DeletionScope.allLocalMeMyData)) {
      return Set<DeletionScope>.from(scopes)
        ..remove(DeletionScope.allLocalMeMyData)
        ..remove(DeletionScope.calendarDeviceEvents);
    }
    // Device events intentionally excluded from global expansion.
    return {
      DeletionScope.goals,
      DeletionScope.finance,
      DeletionScope.habits,
      DeletionScope.calendarImportedCache,
      DeletionScope.calendarMeMyLocalRecords,
      DeletionScope.calendarIntegrationState,
      DeletionScope.healthDerivedCache,
      DeletionScope.healthConnectionConfiguration,
      DeletionScope.preferences,
    };
  }

  Future<int> _runStep(DeletionScope scope) async {
    switch (scope) {
      case DeletionScope.goals:
      case DeletionScope.goalsLocalCache:
        return _clearGoals();
      case DeletionScope.finance:
        return _clearFinance();
      case DeletionScope.habits:
        return _clearHabits();
      case DeletionScope.calendarCache:
        final cleared = await _clearCalendarCache(includeMeMyOwned: true);
        return cleared.events + cleared.links + cleared.conflicts + cleared.ops;
      case DeletionScope.calendarMeMyLocalRecords:
        return _clearCalendarMeMyLocalRecords();
      case DeletionScope.calendarImportedCache:
        return _clearCalendarImportedCache();
      case DeletionScope.calendarIntegrationState:
        return _clearCalendarIntegrationState();
      case DeletionScope.healthDerivedCache:
      case DeletionScope.healthCache:
        await _clearHealthDerived();
        return 1;
      case DeletionScope.healthConnectionConfiguration:
        await _disconnectHealth();
        return 1;
      case DeletionScope.preferences:
        return _clearPreferences();
      case DeletionScope.calendarDeviceEvents:
      case DeletionScope.allLocalMeMyData:
        return 0;
    }
  }

  Future<int> _estimateGoals() async {
    final repo = goalRepository;
    if (repo == null) return 0;
    if (repo is ApiGoalRepository) {
      return (await repo.cache.getGoals()).length;
    }
    try {
      return (await repo.getGoals()).length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _estimateFinance() async {
    final repo = financeRepository;
    if (repo == null) return 0;
    try {
      return (await repo.getTransactions()).length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _estimateHabits() async {
    final repo = habitRepository;
    if (repo == null) return 0;
    try {
      return (await repo.getHabits()).length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _clearGoals() async {
    final repo = goalRepository;
    if (repo is ApiGoalRepository) {
      return repo.clearLocalCacheOnly();
    }
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
    if (repo == null) {
      throw StateError('Goals repository unavailable');
    }
    // Never call deleteGoal — that would hit remote DELETE for API repos.
    throw StateError('Goals repository is not locally clearable');
  }

  Future<int> _clearFinance() async {
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
    throw StateError('Finance repository unavailable or not clearable');
  }

  Future<int> _clearHabits() async {
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
    throw StateError('Habits repository unavailable or not clearable');
  }

  Future<({int events, int links, int conflicts, int ops})>
  _clearCalendarCache({required bool includeMeMyOwned}) async {
    final repo = calendarRepository;
    if (repo is LocalCalendarRepository) {
      return repo.clearLocalCache(includeMeMyOwnedEvents: includeMeMyOwned);
    }
    if (repo is FakeCalendarRepository) {
      return repo.clearLocalCache(includeMeMyOwnedEvents: includeMeMyOwned);
    }
    throw StateError('Calendar repository unavailable or not clearable');
  }

  Future<int> _clearCalendarImportedCache() async {
    final repo = calendarRepository;
    if (repo is LocalCalendarRepository) {
      final cleared = await repo.clearImportedCache();
      return cleared.events + cleared.links + cleared.conflicts + cleared.ops;
    }
    if (repo is FakeCalendarRepository) {
      final cleared = await repo.clearImportedCache();
      return cleared.events + cleared.links + cleared.conflicts + cleared.ops;
    }
    throw StateError('Calendar repository unavailable or not clearable');
  }

  Future<int> _clearCalendarMeMyLocalRecords() async {
    final repo = calendarRepository;
    if (repo is LocalCalendarRepository) {
      final cleared = await repo.clearMeMyLocalRecords();
      return cleared.events + cleared.links + cleared.conflicts + cleared.ops;
    }
    if (repo is FakeCalendarRepository) {
      final cleared = await repo.clearMeMyLocalRecords();
      return cleared.events + cleared.links + cleared.conflicts + cleared.ops;
    }
    throw StateError('Calendar repository unavailable or not clearable');
  }

  Future<int> _clearCalendarIntegrationState() async {
    final repo = calendarRepository;
    if (repo is LocalCalendarRepository) {
      return repo.resetIntegrationConfig();
    }
    if (repo is FakeCalendarRepository) {
      return repo.resetIntegrationConfig();
    }
    if (repo == null) {
      throw StateError('Calendar repository unavailable');
    }
    await repo.saveConfig(const CalendarConfig());
    return 1;
  }

  Future<void> _clearHealthDerived() async {
    final repo = healthRepository;
    if (repo == null) {
      throw StateError('Health repository unavailable');
    }
    await repo.clearDerivedCache();
  }

  Future<void> _disconnectHealth() async {
    final repo = healthRepository;
    if (repo == null) {
      throw StateError('Health repository unavailable');
    }
    await repo.disconnect();
  }

  Future<int> _clearPreferences() async {
    final p = prefs;
    if (p == null) {
      throw StateError('SharedPreferences unavailable for preference wipe');
    }
    var cleared = 0;
    for (final key in MemyOwnedPreferenceKeys.preferencesWipeTargets) {
      if (p.containsKey(key)) {
        await p.remove(key);
        cleared++;
      }
    }
    return cleared;
  }
}
