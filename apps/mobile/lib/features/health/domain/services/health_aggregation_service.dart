import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/daily_health_summary.dart';
import '../entities/health_metric_type.dart';
import '../entities/health_workout.dart';
import '../entities/normalized_health_sample.dart';

/// Pure aggregation of raw platform samples into a [DailyHealthSummary].
///
/// Stateless and side-effect free — takes samples already read for a window
/// and reduces them to one day's display-ready figures. Never persists
/// anything; callers decide what (if anything) to cache.
class HealthAggregationService {
  const HealthAggregationService();

  /// Builds the summary for [date] from [samples]/[workouts] already
  /// fetched for a window covering it.
  ///
  /// Attribution:
  /// - Sleep samples are attributed to the date the sleeper **woke up**
  ///   (`endAt`'s local calendar day), matching how sleep apps usually
  ///   label "last night's sleep" on the following morning.
  /// - Every other sample is attributed by its `startAt`'s local calendar
  ///   day.
  /// - Weight/heart-rate use the most recent in-day reading (a snapshot),
  ///   never an average — MeMy does not compute clinical statistics.
  DailyHealthSummary summarizeDay({
    required LocalDate date,
    required List<NormalizedHealthSample> samples,
    List<HealthWorkout> workouts = const [],
    Set<HealthMetricType> unavailableMetrics = const {},
    required DateTime generatedAt,
  }) {
    final daySamples = samples.where((s) => _attributedTo(s) == date).toList();
    final dayWorkouts = workouts
        .where((w) => LocalDate.fromDateTime(w.startAt.toLocal()) == date)
        .toList(growable: false);

    return DailyHealthSummary(
      date: date,
      steps: _sumInt(daySamples, HealthMetricType.steps),
      distanceMeters: _sum(daySamples, HealthMetricType.distanceWalkingRunning),
      activeEnergyKcal: _sum(daySamples, HealthMetricType.activeEnergyBurned),
      latestHeartRateBpm: _latest(daySamples, HealthMetricType.heartRate),
      restingHeartRateBpm: _latest(
        daySamples,
        HealthMetricType.restingHeartRate,
      ),
      sleepDuration: _sleepDuration(daySamples),
      exerciseMinutes: _sum(daySamples, HealthMetricType.exerciseMinutes),
      weightKg: _latest(daySamples, HealthMetricType.weight),
      workouts: dayWorkouts,
      generatedAt: generatedAt,
      unavailableMetrics: unavailableMetrics,
    );
  }

  LocalDate _attributedTo(NormalizedHealthSample sample) {
    final anchor = sample.metricType == HealthMetricType.sleep
        ? sample.endAt
        : sample.startAt;
    return LocalDate.fromDateTime(anchor.toLocal());
  }

  Iterable<NormalizedHealthSample> _of(
    List<NormalizedHealthSample> samples,
    HealthMetricType type,
  ) => samples.where((s) => s.metricType == type);

  double? _sum(List<NormalizedHealthSample> samples, HealthMetricType type) {
    final matching = _of(samples, type).toList();
    if (matching.isEmpty) return null;
    return matching.fold<double>(0, (acc, s) => acc + s.value);
  }

  int? _sumInt(List<NormalizedHealthSample> samples, HealthMetricType type) {
    final total = _sum(samples, type);
    return total?.round();
  }

  /// Most recent reading by [NormalizedHealthSample.startAt] — a point-in-
  /// time snapshot, not an average.
  double? _latest(List<NormalizedHealthSample> samples, HealthMetricType type) {
    final matching = _of(samples, type).toList();
    if (matching.isEmpty) return null;
    matching.sort((a, b) => a.startAt.compareTo(b.startAt));
    return matching.last.value;
  }

  /// Sums sleep sample durations (already minutes) into a [Duration].
  Duration? _sleepDuration(List<NormalizedHealthSample> samples) {
    final minutes = _sum(samples, HealthMetricType.sleep);
    if (minutes == null) return null;
    return Duration(minutes: minutes.round());
  }
}
