import 'health_metric_type.dart';

/// One platform Health reading, normalized to MeMy's own units/enums.
///
/// This is an in-memory boundary type only — MeMy never persists raw sample
/// values indefinitely (see `HealthRepository` docs). It is safe to hold a
/// short-lived list of these for one aggregation pass, but do not store them
/// in SharedPreferences/DB.
class NormalizedHealthSample {
  const NormalizedHealthSample({
    required this.metricType,
    required this.value,
    required this.unit,
    required this.startAt,
    required this.endAt,
    required this.source,
    this.recordingMethod = HealthRecordingMethod.unknown,
  });

  final HealthMetricType metricType;
  final double value;
  final HealthUnit unit;

  /// UTC instants bounding this reading. Point-in-time samples (e.g. a heart
  /// rate reading) have `startAt == endAt`.
  final DateTime startAt;
  final DateTime endAt;
  final HealthSampleSource source;
  final HealthRecordingMethod recordingMethod;

  @override
  String toString() =>
      'NormalizedHealthSample(${metricType.name}, unit: ${unit.name}, '
      'source: ${source.name})';
}
