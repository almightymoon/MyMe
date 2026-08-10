import '../../../../core/domain/value_objects/local_date.dart';
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
/// Prefers gateway daily totals for steps / distance / active energy when
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
  if (permissionState.isReadableForAggregation(HealthMetricGroup.activity)) {
    stepsOverride = await gateway.readDailyStepTotal(
      startUtc: dayStart,
      endUtc: dayEnd,
    );
    distanceOverride = await gateway.readDailyDistanceTotal(
      startUtc: dayStart,
      endUtc: dayEnd,
    );
    energyOverride = await gateway.readDailyActiveEnergyTotal(
      startUtc: dayStart,
      endUtc: dayEnd,
    );
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
  );
}
