import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../domain/entities/health_aggregate_result.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_permission_state.dart';
import '../../domain/entities/health_workout.dart';
import '../../domain/entities/normalized_health_sample.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import '../../domain/services/health_aggregation_service.dart';

/// Fully in-memory, controllable [PlatformHealthGateway].
///
/// Backs `HEALTH_DATA_SOURCE=fake` (default, CI-safe) and is the gateway
/// used by every health test — no real device/plugin involved. Tests seed
/// samples/workouts directly and control availability/permission state to
/// exercise disconnected, partial-permission, and error states.
class FakePlatformHealthGateway implements PlatformHealthGateway {
  FakePlatformHealthGateway({
    this._availability = IntegrationAvailability.available,
    Set<HealthMetricGroup> grantedGroups = const {},
    this.treatRequestsAsUnverified = false,
  }) : _grantedGroups = {...grantedGroups};

  IntegrationAvailability _availability;
  final Set<HealthMetricGroup> _grantedGroups;

  /// When true, [requestPermissions] marks every requested group as
  /// [HealthPermissionDisposition.requestCompletedUnverified] (HealthKit-
  /// style) instead of verified grant/deny.
  bool treatRequestsAsUnverified;

  /// When set, the next [requestPermissions] call returns this outcome
  /// instead of the default verified grant/deny flow.
  FakePermissionRequestOutcome? nextRequestOutcome;

  /// Groups the next [requestPermissions] call should grant. Defaults to
  /// "grant everything requested" — set to a subset to simulate a partial
  /// grant, or to `{}` to simulate the user declining everything.
  /// Ignored when [treatRequestsAsUnverified] is true.
  Set<HealthMetricGroup>? nextRequestGrantsOverride;

  final List<NormalizedHealthSample> _samples = [];
  final List<HealthWorkout> _workouts = [];
  final _aggregation = const HealthAggregationService();

  void seedSample(NormalizedHealthSample sample) {
    _samples.add(sample);
  }

  void seedWorkout(HealthWorkout workout) {
    _workouts.add(workout);
  }

  void clearSeeded() {
    _samples.clear();
    _workouts.clear();
  }

  void setAvailability(IntegrationAvailability availability) {
    _availability = availability;
  }

  void grantGroups(Set<HealthMetricGroup> groups) {
    _grantedGroups.addAll(groups);
  }

  void revokeGroups(Set<HealthMetricGroup> groups) {
    _grantedGroups.removeAll(groups);
  }

  /// Simulates mid-session permission revocation for refresh-recheck tests.
  void simulatePermissionRevocation(Set<HealthMetricGroup> groups) {
    revokeGroups(groups);
  }

  Set<HealthMetricGroup> get grantedGroups => Set.unmodifiable(_grantedGroups);

  @override
  Future<IntegrationAvailability> checkAvailability() async => _availability;

  @override
  Future<bool?> hasPermissions(Set<HealthMetricGroup> groups) async {
    if (treatRequestsAsUnverified) return null;
    return groups.every(_grantedGroups.contains);
  }

  @override
  Future<Map<HealthMetricGroup, HealthPermissionDisposition>>
  requestPermissions(Set<HealthMetricGroup> groups) async {
    if (_availability != IntegrationAvailability.available) {
      throw IntegrationError.unavailable(IntegrationProvider.health);
    }

    final outcome = nextRequestOutcome;
    nextRequestOutcome = null;

    if (outcome == FakePermissionRequestOutcome.cancelled) {
      return {
        for (final g in groups) g: HealthPermissionDisposition.requestCancelled,
      };
    }
    if (outcome == FakePermissionRequestOutcome.failed) {
      return {
        for (final g in groups) g: HealthPermissionDisposition.requestFailed,
      };
    }

    if (treatRequestsAsUnverified) {
      _grantedGroups.addAll(groups);
      return {
        for (final g in groups)
          g: HealthPermissionDisposition.requestCompletedUnverified,
      };
    }

    final granted = nextRequestGrantsOverride ?? groups;
    final actuallyGranted = groups.intersection(granted);
    _grantedGroups
      ..removeAll(groups)
      ..addAll(actuallyGranted);
    return {
      for (final g in groups)
        g: actuallyGranted.contains(g)
            ? HealthPermissionDisposition.grantedVerified
            : HealthPermissionDisposition.deniedVerified,
    };
  }

  bool _hasPermissionFor(HealthMetricType type) =>
      _grantedGroups.contains(type.group);

  @override
  Future<List<NormalizedHealthSample>> readSamples({
    required Set<HealthMetricType> metricTypes,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return _samples
        .where(
          (s) =>
              metricTypes.contains(s.metricType) &&
              _hasPermissionFor(s.metricType) &&
              s.startAt.isBefore(endUtc) &&
              s.endAt.isAfter(startUtc),
        )
        .toList(growable: false);
  }

  @override
  Future<List<HealthWorkout>> readWorkouts({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    if (!_grantedGroups.contains(HealthMetricGroup.workouts)) return const [];
    return _workouts
        .where((w) => w.startAt.isBefore(endUtc) && w.endAt.isAfter(startUtc))
        .toList(growable: false);
  }

  @override
  Future<int?> readDailyStepTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final result = await aggregateSteps(startUtc: startUtc, endUtc: endUtc);
    return result.intValue;
  }

  @override
  Future<double?> readDailyDistanceTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final result = await aggregateDistance(startUtc: startUtc, endUtc: endUtc);
    return result.numericValue;
  }

  @override
  Future<double?> readDailyActiveEnergyTotal({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final result = await aggregateActiveEnergy(
      startUtc: startUtc,
      endUtc: endUtc,
    );
    return result.numericValue;
  }

  @override
  Future<HealthAggregateResult> aggregateSteps({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return _aggregate(
      metricType: HealthMetricType.steps,
      startUtc: startUtc,
      endUtc: endUtc,
      strategy: treatRequestsAsUnverified
          ? HealthAggregateStrategy.rawDeduplicatedFallback
          : HealthAggregateStrategy.platformTotal,
    );
  }

  @override
  Future<HealthAggregateResult> aggregateDistance({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return _aggregate(
      metricType: HealthMetricType.distanceWalkingRunning,
      startUtc: startUtc,
      endUtc: endUtc,
      strategy: HealthAggregateStrategy.rawDeduplicatedFallback,
    );
  }

  @override
  Future<HealthAggregateResult> aggregateActiveEnergy({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return _aggregate(
      metricType: HealthMetricType.activeEnergyBurned,
      startUtc: startUtc,
      endUtc: endUtc,
      strategy: HealthAggregateStrategy.rawDeduplicatedFallback,
    );
  }

  @override
  Future<HealthAggregateResult> aggregateExerciseDuration({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return _aggregate(
      metricType: HealthMetricType.exerciseMinutes,
      startUtc: startUtc,
      endUtc: endUtc,
      strategy: HealthAggregateStrategy.rawDeduplicatedFallback,
    );
  }

  Future<HealthAggregateResult> _aggregate({
    required HealthMetricType metricType,
    required DateTime startUtc,
    required DateTime endUtc,
    required HealthAggregateStrategy strategy,
  }) async {
    if (!_grantedGroups.contains(HealthMetricGroup.activity)) {
      return HealthAggregateResult(
        metricType: metricType,
        strategy: HealthAggregateStrategy.unavailable,
      );
    }
    final samples = await readSamples(
      metricTypes: {metricType},
      startUtc: startUtc,
      endUtc: endUtc,
    );
    final deduped = _aggregation.dedupeSamples(samples);
    if (deduped.isEmpty) {
      return HealthAggregateResult(
        metricType: metricType,
        strategy: HealthAggregateStrategy.unavailable,
      );
    }
    final total = deduped.fold<double>(0, (acc, s) => acc + s.value);
    return HealthAggregateResult(
      metricType: metricType,
      strategy: strategy,
      numericValue: total,
    );
  }
}

/// Outcome override for the next fake permission request (iOS-style tests).
enum FakePermissionRequestOutcome { cancelled, failed }
