import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../../domain/entities/daily_health_summary.dart';
import '../../domain/entities/health_aggregate_result.dart';
import '../../domain/entities/health_connection_config.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_permission_state.dart';
import '../../domain/entities/health_workout.dart';
import '../../domain/entities/normalized_health_sample.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import '../../domain/repositories/health_repository.dart';

/// Health with no platform store — used on Android so MeMy never talks to
/// Google Health Connect.
class DisabledHealthRepository implements HealthRepository {
  const DisabledHealthRepository();

  static const _connection = HealthConnectionConfig();

  @override
  Stream<HealthConnectionConfig> watchConnection() => Stream.value(_connection);

  @override
  Future<HealthConnectionConfig> getConnection() async => _connection;

  @override
  Future<IntegrationAvailability> checkAvailability() async =>
      IntegrationAvailability.notSupported;

  @override
  Future<HealthPermissionState> requestPermissions(
    Set<HealthMetricGroup> groups,
  ) async => const HealthPermissionState();

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> clearDerivedCache() async {}

  @override
  Future<DailyHealthSummary> getDailySummary(
    LocalDate date, {
    bool forceRefresh = false,
  }) async {
    return DailyHealthSummary.empty(
      date,
      DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<HealthConnectionConfig> restoreBackup() async => _connection;

  @override
  Future<void> resetConnection() async {}

  @override
  Future<bool> hasBackupAvailable() async => false;
}

/// Gateway stub so providers stay exhaustive without opening Health Connect.
class DisabledPlatformHealthGateway implements PlatformHealthGateway {
  const DisabledPlatformHealthGateway();

  @override
  Future<IntegrationAvailability> checkAvailability() async =>
      IntegrationAvailability.notSupported;

  @override
  Future<bool?> hasPermissions(Set<HealthMetricGroup> groups) async => false;

  @override
  Future<Map<HealthMetricGroup, HealthPermissionDisposition>>
  requestPermissions(Set<HealthMetricGroup> groups) async {
    return {
      for (final group in groups)
        group: HealthPermissionDisposition.unavailable,
    };
  }

  @override
  Future<List<NormalizedHealthSample>> readSamples({
    required Set<HealthMetricType> metricTypes,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async => const [];

  @override
  Future<List<HealthWorkout>> readWorkouts({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async => const [];

  @override
  Future<int?> readDailyStepTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async => null;

  @override
  Future<double?> readDailyDistanceTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async => null;

  @override
  Future<double?> readDailyActiveEnergyTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async => null;

  @override
  Future<HealthAggregateResult> aggregateSteps({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return const HealthAggregateResult(
      metricType: HealthMetricType.steps,
      strategy: HealthAggregateStrategy.unavailable,
    );
  }

  @override
  Future<HealthAggregateResult> aggregateDistance({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return const HealthAggregateResult(
      metricType: HealthMetricType.distanceWalkingRunning,
      strategy: HealthAggregateStrategy.unavailable,
    );
  }

  @override
  Future<HealthAggregateResult> aggregateActiveEnergy({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return const HealthAggregateResult(
      metricType: HealthMetricType.activeEnergyBurned,
      strategy: HealthAggregateStrategy.unavailable,
    );
  }

  @override
  Future<HealthAggregateResult> aggregateExerciseDuration({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return const HealthAggregateResult(
      metricType: HealthMetricType.exerciseMinutes,
      strategy: HealthAggregateStrategy.unavailable,
    );
  }
}
