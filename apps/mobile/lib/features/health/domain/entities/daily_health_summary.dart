import '../../../../core/domain/value_objects/local_date.dart';
import 'health_metric_type.dart';
import 'health_workout.dart';

/// Aggregated, display-ready health metrics for one calendar day.
///
/// This is the only health shape MeMy holds onto for more than one
/// aggregation pass, and even then only as a short-lived cache cleared on
/// disconnect (see `HealthRepository` docs) — never a growing history of
/// raw samples.
///
/// MeMy shows wellness metrics only. Nothing here is a diagnosis, a "Health
/// Score", or medical advice.
class DailyHealthSummary {
  const DailyHealthSummary({
    required this.date,
    this.steps,
    this.distanceMeters,
    this.activeEnergyKcal,
    this.latestHeartRateBpm,
    this.restingHeartRateBpm,
    this.sleepDuration,
    this.exerciseMinutes,
    this.weightKg,
    this.workouts = const [],
    required this.generatedAt,
    this.unavailableMetrics = const {},
  });

  final LocalDate date;
  final int? steps;
  final double? distanceMeters;
  final double? activeEnergyKcal;

  /// Most recent heart-rate reading within [date] — a snapshot, not an
  /// average, since MeMy does not compute clinical statistics.
  final double? latestHeartRateBpm;
  final double? restingHeartRateBpm;

  /// Total time asleep attributed to [date] (the night ending that morning).
  final Duration? sleepDuration;
  final double? exerciseMinutes;
  final double? weightKg;
  final List<HealthWorkout> workouts;

  /// When this summary was computed — drives the "last updated" freshness
  /// label; never implies the underlying samples are this recent.
  final DateTime generatedAt;

  /// Metrics with no permission (or no data) for [date], so the UI can show
  /// "not connected" / "no data" instead of a misleading zero.
  final Set<HealthMetricType> unavailableMetrics;

  bool isAvailable(HealthMetricType type) => !unavailableMetrics.contains(type);

  bool get hasAnyData =>
      steps != null ||
      distanceMeters != null ||
      activeEnergyKcal != null ||
      latestHeartRateBpm != null ||
      restingHeartRateBpm != null ||
      sleepDuration != null ||
      exerciseMinutes != null ||
      weightKg != null ||
      workouts.isNotEmpty;

  factory DailyHealthSummary.empty(LocalDate date, DateTime generatedAt) {
    return DailyHealthSummary(
      date: date,
      generatedAt: generatedAt,
      unavailableMetrics: HealthMetricType.values.toSet(),
    );
  }
}
