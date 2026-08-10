import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/integrations/domain/integration_connection_status.dart';
import '../../data/gateways/fake_platform_health_gateway.dart';
import '../../domain/entities/daily_health_summary.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_permission_state.dart';
import '../../domain/entities/health_workout.dart';
import '../../domain/entities/normalized_health_sample.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import '../../domain/services/health_aggregation_service.dart';

/// Shared fetch-and-aggregate logic for [FakeHealthRepository] and
/// [SystemHealthRepository] so both apply identical permission-gating and
/// windowing rules.
///
/// Reads a window wide enough to attribute overnight sleep to [date] (sleep
/// samples are attributed by wake time — see [HealthAggregationService]),
/// then aggregates only the metric types the user may read per
/// [HealthPermissionState.isReadableForAggregation].
///
/// Prefers gateway aggregates for steps / distance / active energy when
/// available (avoids double-counting overlapping raw samples).
Future<DailyHealthSummary> buildDailySummary({
  required PlatformHealthGateway gateway,
  required HealthAggregationService aggregation,
  required HealthPermissionState permissionState,
  required LocalDate date,
  required DateTime now,
}) async {
  final readableTypes = HealthMetricType.values
      .where((m) => permissionState.isReadableForAggregation(m.group))
      .toSet();
  final unavailable = HealthMetricType.values
      .where((m) => !readableTypes.contains(m))
      .toSet();

  final workoutsReadable = permissionState.isReadableForAggregation(
    HealthMetricGroup.workouts,
  );

  if (readableTypes.isEmpty && !workoutsReadable) {
    return DailyHealthSummary.empty(date, now);
  }

  // Sleep can be attributed to [date] by either the previous night
  // (endAt on [date]) or spill slightly past midnight — read from the day
  // before through the end of [date] to catch both.
  final windowStart = date.addDays(-1).toDateTimeLocal().toUtc();
  final windowEnd = date.addDays(1).toDateTimeLocal().toUtc();
  final dayStart = date.toDateTimeLocal().toUtc();
  final dayEnd = date.addDays(1).toDateTimeLocal().toUtc();

  final List<NormalizedHealthSample> samples = readableTypes.isEmpty
      ? const []
      : await gateway.readSamples(
          metricTypes: readableTypes,
          startUtc: windowStart,
          endUtc: windowEnd,
        );
  final List<HealthWorkout> workouts = workoutsReadable
      ? await gateway.readWorkouts(startUtc: windowStart, endUtc: windowEnd)
      : const [];

  int? stepsOverride;
  double? distanceOverride;
  double? energyOverride;
  double? exerciseOverride;
  if (permissionState.isReadableForAggregation(HealthMetricGroup.activity)) {
    final stepsResult = await gateway.aggregateSteps(
      startUtc: dayStart,
      endUtc: dayEnd,
    );
    stepsOverride = stepsResult.intValue;

    final distanceResult = await gateway.aggregateDistance(
      startUtc: dayStart,
      endUtc: dayEnd,
    );
    distanceOverride = distanceResult.numericValue;

    final energyResult = await gateway.aggregateActiveEnergy(
      startUtc: dayStart,
      endUtc: dayEnd,
    );
    energyOverride = energyResult.numericValue;

    final exerciseResult = await gateway.aggregateExerciseDuration(
      startUtc: dayStart,
      endUtc: dayEnd,
    );
    exerciseOverride = exerciseResult.numericValue;
  }

  return aggregation.summarizeDay(
    date: date,
    samples: samples,
    workouts: workouts,
    unavailableMetrics: unavailable,
    generatedAt: now,
    stepsOverride: stepsOverride,
    distanceMetersOverride: distanceOverride,
    activeEnergyKcalOverride: energyOverride,
    exerciseMinutesOverride: exerciseOverride,
  );
}

/// Re-checks verified permission groups via [gateway.hasPermissions].
///
/// Used on Android refresh (and fake verified mode) to detect mid-session
/// revocations. iOS / unverified fake mode returns [current] unchanged when
/// `hasPermissions` is `null`.
Future<HealthPermissionState> recheckPermissions({
  required PlatformHealthGateway gateway,
  required HealthPermissionState current,
  required bool shouldRecheck,
}) async {
  if (!shouldRecheck) return current;

  final configuredGroups = current.dispositions.keys.toSet();
  if (configuredGroups.isEmpty) return current;

  final updates = <HealthMetricGroup, HealthPermissionDisposition>{};
  for (final group in configuredGroups) {
    final previous = current.dispositionOf(group);
    if (previous == HealthPermissionDisposition.notRequested ||
        previous == HealthPermissionDisposition.requestCancelled ||
        previous == HealthPermissionDisposition.requestFailed ||
        previous == HealthPermissionDisposition.unavailable) {
      continue;
    }

    final hasGroup = await gateway.hasPermissions({group});
    if (hasGroup == null) continue;

    if (hasGroup) {
      updates[group] = HealthPermissionDisposition.grantedVerified;
    } else {
      updates[group] = HealthPermissionDisposition.deniedVerified;
    }
  }

  if (updates.isEmpty) return current;
  return current.merging(updates);
}

/// Derives connection [IntegrationConnectionStatus] after a permission update.
IntegrationConnectionStatus connectionStatusFor(
  HealthPermissionState permissionState,
) {
  if (permissionState.hasAnyReadable) {
    final allRequestedReadable = permissionState.dispositions.entries
        .where(
          (e) =>
              e.value != HealthPermissionDisposition.notRequested &&
              e.value != HealthPermissionDisposition.unavailable,
        )
        .every((e) => permissionState.isReadableForAggregation(e.key));
    return allRequestedReadable
        ? IntegrationConnectionStatus.connected
        : IntegrationConnectionStatus.partiallyConnected;
  }
  if (permissionState.hasCancelledDispositions ||
      permissionState.hasFailedDispositions) {
    return IntegrationConnectionStatus.notConnected;
  }
  return IntegrationConnectionStatus.error;
}

/// Clears in-memory summary cache when any group was revoked.
void clearCacheForRevokedGroups({
  required Map<LocalDate, DailyHealthSummary> cache,
  required HealthPermissionState before,
  required HealthPermissionState after,
}) {
  final revokedGroups = <HealthMetricGroup>{};
  for (final group in before.dispositions.keys) {
    if (before.isReadableForAggregation(group) &&
        !after.isReadableForAggregation(group)) {
      revokedGroups.add(group);
    }
  }
  if (revokedGroups.isEmpty) return;
  cache.clear();
}

/// Whether this gateway mode supports verified permission recheck on refresh.
bool gatewaySupportsPermissionRecheck(PlatformHealthGateway gateway) {
  if (gateway is FakePlatformHealthGateway) {
    return !gateway.treatRequestsAsUnverified;
  }
  return true;
}
