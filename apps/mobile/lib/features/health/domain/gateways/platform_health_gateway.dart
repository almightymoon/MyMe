import '../../../../core/integrations/domain/integration_availability.dart';
import '../entities/health_aggregate_result.dart';
import '../entities/health_metric_type.dart';
import '../entities/health_permission_state.dart';
import '../entities/health_workout.dart';
import '../entities/normalized_health_sample.dart';

/// Abstract, read-only boundary between MeMy and the device's Health store
/// (Apple HealthKit / Google Health Connect).
///
/// Implementations: [FakePlatformHealthGateway] (in-memory, controllable —
/// used in `fake` mode and in every health test) and
/// [SystemPlatformHealthGateway] (wraps the `health` plugin — used in
/// `system` mode).
///
/// Contract:
/// - **Read-only.** No implementation may write to the platform Health
///   store. There is no `write*` method on this interface by design.
/// - Only [HealthMetricType]/[HealthMetricGroup] values may ever be
///   requested — never ECG, blood pressure, glucose, SpO2, clinical
///   records, medications, reproductive, or nutrition data.
/// - Throws `IntegrationError` (from `core/integrations`) on failure; never
///   throws a plugin-specific exception type.
abstract interface class PlatformHealthGateway {
  Future<IntegrationAvailability> checkAvailability();

  /// Whether every metric type in [groups] currently has read permission,
  /// without prompting. `null` when the platform cannot disclose read
  /// status without prompting (HealthKit never reveals READ grants).
  Future<bool?> hasPermissions(Set<HealthMetricGroup> groups);

  /// Requests OS permission to read [groups].
  ///
  /// Returns a disposition per requested group:
  /// - iOS: typically [HealthPermissionDisposition.requestCompletedUnverified]
  /// - Android: [HealthPermissionDisposition.grantedVerified] /
  ///   [HealthPermissionDisposition.deniedVerified] after `hasPermissions`
  Future<Map<HealthMetricGroup, HealthPermissionDisposition>>
  requestPermissions(Set<HealthMetricGroup> groups);

  /// Samples for [metricTypes] in `[startUtc, endUtc)`.
  ///
  /// Returns an empty list (never throws) for metric types with no granted
  /// permission — callers distinguish "no permission" via
  /// [hasPermissions]/[HealthPermissionState], not via exceptions here.
  Future<List<NormalizedHealthSample>> readSamples({
    required Set<HealthMetricType> metricTypes,
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Workouts overlapping `[startUtc, endUtc)`.
  Future<List<HealthWorkout>> readWorkouts({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Platform daily step total for `[startUtc, endUtc)` when available.
  ///
  /// Prefer [aggregateSteps] which labels the aggregation strategy.
  Future<int?> readDailyStepTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Platform daily walking/running distance total when available.
  Future<double?> readDailyDistanceTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Platform daily active-energy total when available.
  Future<double?> readDailyActiveEnergyTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Steps aggregate with explicit [HealthAggregateStrategy] labeling.
  Future<HealthAggregateResult> aggregateSteps({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Distance aggregate — may fall back to raw de-duplicated samples.
  Future<HealthAggregateResult> aggregateDistance({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Active energy aggregate — may fall back to raw de-duplicated samples.
  Future<HealthAggregateResult> aggregateActiveEnergy({
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Exercise duration aggregate — raw de-duplicated fallback only.
  Future<HealthAggregateResult> aggregateExerciseDuration({
    required DateTime startUtc,
    required DateTime endUtc,
  });
}
