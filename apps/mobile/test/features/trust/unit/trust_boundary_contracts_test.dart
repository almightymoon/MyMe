import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/finance/data/repositories/local_finance_repository.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/habits/data/repositories/local_habit_repository.dart';
import 'package:memy/features/health/data/repositories/health_connection_storage.dart';
import 'package:memy/features/trust/domain/entities/data_catalog.dart';
import 'package:memy/features/trust/domain/entities/data_module_id.dart';
import 'package:memy/features/trust/domain/entities/deletion_scope.dart';
import 'package:memy/features/trust/domain/entities/support_diagnostics_report.dart';
import 'package:memy/features/trust/domain/services/data_module_capabilities.dart';
import 'package:memy/features/trust/domain/services/data_module_contract_validator.dart';
import 'package:memy/features/trust/domain/services/data_module_registry.dart';
import 'package:memy/features/trust/domain/services/local_data_deletion_coordinator.dart';
import 'package:memy/features/trust/domain/services/memy_owned_preference_keys.dart';
import 'package:memy/features/trust/domain/services/privacy_data_catalog_service.dart';
import 'package:memy/features/trust/presentation/appearance/appearance_preferences.dart';
import 'package:memy/features/goals/data/repositories/fake_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/habits/data/repositories/fake_habit_repository.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_connection_config.dart';
import 'package:memy/features/trust/data/repositories/memy_local_data_deletion_coordinator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Goal _goal(String id) => Goal(
  id: id,
  name: 'G$id',
  category: GoalCategory.health,
  priority: GoalPriority.high,
  status: GoalStatus.active,
  deadline: DateTime(2027),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  progressPercent: 0,
);

class _SpyHealthRepository extends FakeHealthRepository {
  _SpyHealthRepository()
    : super(
        gateway: FakePlatformHealthGateway(),
        initialConnection: const HealthConnectionConfig(),
      );

  int disconnectCalls = 0;
  int clearDerivedCalls = 0;

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    await super.disconnect();
  }

  @override
  Future<void> clearDerivedCache() async {
    clearDerivedCalls++;
    await super.clearDerivedCache();
  }
}

/// Defense-in-depth scanner for forbidden diagnostic key fragments.
void expectNoForbiddenFragments(Object? node, {String path = ''}) {
  const forbidden = [
    'title',
    'eventTitle',
    'description',
    'notes',
    'location',
    'attendee',
    'email',
    'phone',
    'address',
    'token',
    'password',
    'secret',
    'authorization',
    'heartRate',
    'steps',
    'sleep',
    'workout',
    'weight',
    'healthValue',
    'sourceDeviceId',
    'providerRecordId',
    'transaction',
    'amount',
    'goalName',
    'habitName',
  ];

  if (node is Map) {
    for (final entry in node.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      for (final fragment in forbidden) {
        // Allow operational keys that legitimately contain none of these
        // as exact field names — scanner matches key equality / contains.
        if (key == fragment || lower.contains(fragment.toLowerCase())) {
          // Operational allowlist exceptions:
          if (key == 'lastSuccessfulPullAt' ||
              key == 'lastSuccessfulPushAt' ||
              key == 'lastSuccessfulRefreshAt' ||
              key == 'pendingOperationCount' ||
              key == 'permissionDispositions') {
            continue;
          }
          // `steps` appears only as a disposition map key under Health —
          // still forbidden as a diagnostic *value* field name at top level.
          if (path.endsWith('permissionDispositions') && fragment == 'steps') {
            continue;
          }
          fail('Forbidden diagnostic key "$key" at $path');
        }
      }
      expectNoForbiddenFragments(entry.value, path: '$path.$key');
    }
  } else if (node is List) {
    for (var i = 0; i < node.length; i++) {
      expectNoForbiddenFragments(node[i], path: '$path[$i]');
    }
  }
}

void main() {
  test('global wipe expansion never includes device calendar events', () async {
    SharedPreferences.setMockInitialValues({});
    final coordinator = MemyLocalDataDeletionCoordinator();
    final plan = await coordinator.plan({
      DeletionScope.allLocalMeMyData,
      DeletionScope.calendarDeviceEvents,
    });
    expect(
      plan.steps.any((s) => s.scope == DeletionScope.calendarDeviceEvents),
      isFalse,
    );
    expect(
      LocalWipeExclusions.forbiddenScopes.contains(
        DeletionScope.calendarDeviceEvents,
      ),
      isTrue,
    );
    expect(
      plan.whatWillRemain.any((e) => e.toLowerCase().contains('calendar')),
      isTrue,
    );
  });

  test('confirmation phrase trims whitespace', () {
    expect(
      LocalDataDeletionCoordinator.matchesGlobalConfirmation(
        '  DELETE LOCAL DATA  ',
      ),
      isTrue,
    );
    expect(
      LocalDataDeletionCoordinator.matchesGlobalConfirmation(
        'delete local data',
      ),
      isFalse,
    );
  });

  test('health connection wipe disconnects once', () async {
    SharedPreferences.setMockInitialValues({});
    final health = _SpyHealthRepository();
    final coordinator = MemyLocalDataDeletionCoordinator(
      healthRepository: health,
    );
    final plan = await coordinator.plan({
      DeletionScope.healthDerivedCache,
      DeletionScope.healthConnectionConfiguration,
    });
    expect(plan.steps.length, 1);
    expect(
      plan.steps.single.scope,
      DeletionScope.healthConnectionConfiguration,
    );

    await coordinator.execute(plan, confirmationPhrase: null);
    expect(health.disconnectCalls, 1);
    // Derived clear is folded into disconnect for combined selection.
    expect(health.clearDerivedCalls, 0);

    health.dispose();
  });

  test('retryFailed re-runs only failed scopes', () async {
    SharedPreferences.setMockInitialValues({});
    final goals = FakeGoalRepository(initial: [_goal('g1')]);
    final habits = FakeHabitRepository();
    final coordinator = MemyLocalDataDeletionCoordinator(
      goalRepository: goals,
      habitRepository: habits,
    );
    final plan = await coordinator.plan({
      DeletionScope.goals,
      DeletionScope.finance,
      DeletionScope.habits,
    });
    final first = await coordinator.execute(plan, confirmationPhrase: null);
    expect(first.overallStatus, DeletionOverallStatus.completedWithIssues);
    expect(first.retryableFailedScopes, [DeletionScope.finance]);

    // Still no finance repo — retry keeps finance failed; completed stay put.
    final second = await coordinator.retryFailed(
      first,
      confirmationPhrase: null,
    );
    expect(
      second.stepResults
          .where((s) => s.scope == DeletionScope.goals)
          .single
          .status,
      DeletionStepStatus.completed,
    );
    expect(
      second.stepResults
          .where((s) => s.scope == DeletionScope.finance)
          .single
          .status,
      DeletionStepStatus.failed,
    );

    goals.dispose();
    habits.dispose();
  });

  test('preference key registry matches known feature keys', () {
    expect(
      MemyOwnedPreferenceKeys.goals,
      containsAll({
        LocalGoalRepository.storageKey,
        LocalGoalRepository.initializedKey,
      }),
    );
    expect(
      MemyOwnedPreferenceKeys.finance,
      containsAll({
        LocalFinanceRepository.storageKey,
        LocalFinanceRepository.initializedKey,
      }),
    );
    expect(
      MemyOwnedPreferenceKeys.habits,
      containsAll({
        LocalHabitRepository.storageKey,
        LocalHabitRepository.initializedKey,
      }),
    );
    expect(
      MemyOwnedPreferenceKeys.healthConnection,
      containsAll({
        HealthConnectionStorageKeys.primary,
        HealthConnectionStorageKeys.backup,
        HealthConnectionStorageKeys.legacy,
      }),
    );
    expect(
      MemyOwnedPreferenceKeys.appearance,
      containsAll(AppearancePreferences.allKeys),
    );
  });

  test('catalog contracts match registry', () {
    final registry = DataModuleRegistry.builtIn();
    final catalog = PrivacyDataCatalogService(registry);
    DataModuleContractValidator(
      registry,
    ).validateAllCatalogEntries(catalog.entries());

    final health = registry.descriptorFor(DataModuleId.health)!;
    expect(health.rawExport, isFalse);
    expect(health.platformDeletion, isFalse);
    expect(health.aiTransfer, isFalse);

    final calendar = registry.descriptorFor(DataModuleId.calendar)!;
    expect(calendar.deviceEventDeletion, isFalse);
  });

  test('typed diagnostics JSON has no forbidden keys', () {
    final report = SupportDiagnosticsReport(
      generatedAtUtc: DateTime.utc(2026, 8, 10),
      osFamily: 'ios',
      osVersion: '18',
      timezone: 'UTC',
      locale: 'en',
      isDebugBuild: true,
      goalsDataSource: 'local',
      financeDataSource: 'local',
      habitsDataSource: 'local',
      calendarDataSource: 'fake',
      healthDataSource: 'fake',
      calendar: const SupportCalendarDiagnostics(
        gatewayMode: 'fake',
        availability: 'available',
        connectionStatus: 'connected',
        readableCalendarCount: 1,
        hasValidWritableTarget: true,
        calendarSchemaVersion: 3,
        pendingOperationCount: 0,
        conflictCount: 0,
        suspectedMissingCount: 0,
        confirmedMissingCount: 0,
        unresolvedRecoveryCount: 0,
        unknownOutcomeCount: 0,
        requiresUserActionCount: 0,
      ),
      health: const SupportHealthDiagnostics(
        gatewayMode: 'fake',
        availability: 'available',
        connectionStatus: 'connected',
        permissionDispositions: {'activity': 'granted'},
        configSchemaVersion: 1,
        recoveryNeeded: false,
        backupAvailable: false,
      ),
    );

    expectNoForbiddenFragments(report.toJson());
  });

  test('health catalog never advertises raw export', () {
    final entry = PrivacyDataCatalogService(
      DataModuleRegistry.builtIn(),
    ).entryFor(DataModule.health)!;
    expect(entry.exportCapability, DataExportCapability.summaryOnly);
    expect(entry.deletionCapability, DataDeletionCapability.disconnectOnly);
  });
}
