import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/environment_config.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../../data/gateways/fake_platform_health_gateway.dart';
import '../../data/gateways/system_platform_health_gateway.dart';
import '../../data/repositories/disabled_health_repository.dart';
import '../../data/repositories/fake_health_repository.dart';
import '../../data/repositories/system_health_repository.dart';
import '../../domain/entities/daily_health_summary.dart';
import '../../domain/entities/health_connection_config.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_permission_state.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import '../../domain/repositories/health_repository.dart';

final healthDataSourceProvider = Provider<HealthDataSource>((ref) {
  return EnvironmentConfig.resolveHealthDataSource();
});

/// Shared fake gateway instance so `HEALTH_DATA_SOURCE=fake` tests/demo mode
/// can seed samples through the same object the repository reads from.
final fakePlatformHealthGatewayProvider = Provider<FakePlatformHealthGateway>(
  (ref) => FakePlatformHealthGateway(),
);

final platformHealthGatewayProvider = Provider<PlatformHealthGateway>((ref) {
  switch (ref.watch(healthDataSourceProvider)) {
    case HealthDataSource.fake:
      return ref.watch(fakePlatformHealthGatewayProvider);
    case HealthDataSource.system:
      return SystemPlatformHealthGateway();
    case HealthDataSource.disabled:
      return const DisabledPlatformHealthGateway();
  }
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final clock = ref.watch(appClockProvider);
  switch (ref.watch(healthDataSourceProvider)) {
    case HealthDataSource.fake:
      final repo = FakeHealthRepository(
        gateway: ref.watch(platformHealthGatewayProvider),
        clock: clock,
      );
      ref.onDispose(repo.dispose);
      return repo;
    case HealthDataSource.system:
      final repo = SystemHealthRepository(
        gateway: ref.watch(platformHealthGatewayProvider),
        prefs: ref.watch(sharedPreferencesProvider),
        clock: clock,
      );
      ref.onDispose(repo.dispose);
      return repo;
    case HealthDataSource.disabled:
      return const DisabledHealthRepository();
  }
});

final healthConnectionProvider = StreamProvider<HealthConnectionConfig>((ref) {
  return ref.watch(healthRepositoryProvider).watchConnection();
});

final healthAvailabilityProvider =
    FutureProvider.autoDispose<IntegrationAvailability>((ref) {
      return ref.watch(healthRepositoryProvider).checkAvailability();
    });

/// Selected date for the Health overview — defaults to today, independent
/// of Habits'/Goals' own selected-date providers.
final healthSelectedDateProvider = StateProvider<LocalDate>((ref) {
  return LocalDate.fromDateTime(ref.watch(appClockProvider).now());
});

final dailyHealthSummaryProvider =
    FutureProvider.autoDispose<DailyHealthSummary>((ref) async {
      final date = ref.watch(healthSelectedDateProvider);
      // Re-fetch whenever the connection changes (e.g. permissions granted).
      ref.watch(healthConnectionProvider);
      return ref.watch(healthRepositoryProvider).getDailySummary(date);
    });

/// Today's summary specifically — used by the compact Today card, kept
/// independent of whatever date the full Health overview screen is browsing.
final todayHealthSummaryProvider =
    FutureProvider.autoDispose<DailyHealthSummary>((ref) async {
      final today = LocalDate.fromDateTime(ref.watch(appClockProvider).now());
      ref.watch(healthConnectionProvider);
      return ref.watch(healthRepositoryProvider).getDailySummary(today);
    });

/// Controller for permission-selection/connect actions — kept out of a
/// [FutureProvider] since it represents a one-shot user action, not a value
/// to watch.
class HealthConnectionController {
  HealthConnectionController(this._ref);

  final Ref _ref;

  HealthRepository get _repository => _ref.read(healthRepositoryProvider);

  Future<HealthPermissionState> requestPermissions(
    Set<HealthMetricGroup> groups,
  ) async {
    return _repository.requestPermissions(groups);
  }

  Future<void> disconnect() => _repository.disconnect();

  Future<void> refresh() => _repository.refresh();

  Future<HealthConnectionConfig> restoreBackup() => _repository.restoreBackup();

  Future<void> resetConnection() => _repository.resetConnection();

  Future<bool> hasBackupAvailable() => _repository.hasBackupAvailable();
}

final healthConnectionControllerProvider = Provider<HealthConnectionController>(
  (ref) => HealthConnectionController(ref),
);
