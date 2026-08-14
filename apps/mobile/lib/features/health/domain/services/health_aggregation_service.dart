import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/daily_health_summary.dart';
import '../entities/health_metric_type.dart';
import '../entities/health_workout.dart';
import '../entities/health_sample_identity.dart';
import '../entities/normalized_health_sample.dart';

/// Pure aggregation of raw platform samples into a [DailyHealthSummary].
///
/// Stateless and side-effect free — takes samples already read for a window
/// and reduces them to one day's display-ready figures. Never persists
/// anything; callers decide what (if anything) to cache.
///
/// Totals sum after de-duplication by [HealthSampleIdentity] (platform +
/// metric + provider id) when present. Samples without a stable id are kept
/// (ephemeral) but are not treated as stable keys for cross-fetch dedupe.
class HealthAggregationService {
  const HealthAggregationService();

  /// Builds the summary for [date] from [samples]/[workouts] already
  /// fetched for a window covering it.
  ///
  /// Attribution:
  /// - Sleep samples are attributed to the date the sleeper **woke up**
  ///   (`endAt`'s local calendar day), matching how sleep apps usually
  ///   label "last night's sleep" on the following morning.
  /// - Sleep is **total time asleep only** (SLEEP_ASLEEP) — no stage
  ///   breakdown (light/deep/REM).
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
    int? stepsOverride,
    double? distanceMetersOverride,
    double? activeEnergyKcalOverride,
    double? exerciseMinutesOverride,
  }) {
    final deduped = dedupeSamples(samples);
    final daySamples = deduped.where((s) => _attributedTo(s) == date).toList();
    final dayWorkouts = dedupeWorkouts(workouts)
        .where((w) => LocalDate.fromDateTime(w.startAt.toLocal()) == date)
        .where(_isValidWorkout)
        .toList(growable: false);

    return DailyHealthSummary(
      date: date,
      steps: stepsOverride ?? _sumInt(daySamples, HealthMetricType.steps),
      distanceMeters:
          distanceMetersOverride ??
          _sum(daySamples, HealthMetricType.distanceWalkingRunning),
      activeEnergyKcal:
          activeEnergyKcalOverride ??
          _sum(daySamples, HealthMetricType.activeEnergyBurned),
      latestHeartRateBpm: _latest(daySamples, HealthMetricType.heartRate),
      restingHeartRateBpm: _latest(
        daySamples,
        HealthMetricType.restingHeartRate,
      ),
      sleepDuration: _sleepDuration(daySamples),
      exerciseMinutes:
          exerciseMinutesOverride ??
          _sum(daySamples, HealthMetricType.exerciseMinutes),
      weightKg: _latest(daySamples, HealthMetricType.weight),
      workouts: dayWorkouts,
      generatedAt: generatedAt,
      unavailableMetrics: unavailableMetrics,
    );
  }

  /// Drops invalid numeric values and de-duplicates by stable provider id.
  ///
  /// Samples without [NormalizedHealthSample.hasStableProviderRecordId] are
  /// retained with an ephemeral identity that is **not** used as a stable
  /// dedupe key (two identical-looking id-less samples both keep).
  List<NormalizedHealthSample> dedupeSamples(
    List<NormalizedHealthSample> samples,
  ) {
    final seenIds = <String>{};
    final result = <NormalizedHealthSample>[];
    for (final sample in samples) {
      if (!_isFiniteNonNegative(sample.value)) continue;
      if (sample.metricType == HealthMetricType.sleep) {
        final duration = sample.endAt.difference(sample.startAt);
        if (duration.isNegative ||
            duration.inMicroseconds.isNaN ||
            !duration.inMicroseconds.isFinite) {
          continue;
        }
      }
      if (sample.hasStableProviderRecordId) {
        final key = HealthSampleIdentity.fromSample(sample).compositeKey;
        if (seenIds.contains(key)) continue;
        seenIds.add(key);
      }
      result.add(sample);
    }
    return result;
  }

  List<HealthWorkout> dedupeWorkouts(List<HealthWorkout> workouts) {
    final seenIds = <String>{};
    final result = <HealthWorkout>[];
    for (final workout in workouts) {
      if (!_isValidWorkout(workout)) continue;
      final id = workout.id;
      if (id.isNotEmpty) {
        if (seenIds.contains(id)) continue;
        seenIds.add(id);
      }
      result.add(workout);
    }
    return result;
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
  /// Total asleep only — no stage breakdown.
  Duration? _sleepDuration(List<NormalizedHealthSample> samples) {
    final minutes = _sum(samples, HealthMetricType.sleep);
    if (minutes == null) return null;
    return Duration(minutes: minutes.round());
  }

  static bool _isFiniteNonNegative(double value) {
    return value.isFinite && !value.isNaN && value >= 0;
  }

  static bool _isValidWorkout(HealthWorkout workout) {
    final duration = workout.duration;
    if (duration.isNegative || !duration.inMicroseconds.isFinite) {
      return false;
    }
    final energy = workout.energyBurnedKcal;
    if (energy != null && !_isFiniteNonNegative(energy)) return false;
    final distance = workout.distanceMeters;
    if (distance != null && !_isFiniteNonNegative(distance)) return false;
    return true;
  }
}
