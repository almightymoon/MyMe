import 'health_metric_type.dart';

/// One night's sleep, summarized to a single asleep-duration figure.
///
/// MeMy's MVP does not surface sleep stage breakdowns (light/deep/REM) —
/// only total time asleep and the overnight window — to stay a simple
/// wellness readout rather than a clinical sleep report.
class HealthSleepSession {
  const HealthSleepSession({
    required this.startAt,
    required this.endAt,
    required this.totalAsleep,
    required this.source,
  });

  /// Overnight window this session covers (may include brief wake periods).
  final DateTime startAt;
  final DateTime endAt;

  /// Total time actually asleep within [startAt, endAt] — excludes awake
  /// and in-bed-but-awake time when the platform reports it separately.
  final Duration totalAsleep;
  final HealthSampleSource source;

  @override
  String toString() =>
      'HealthSleepSession(asleep: ${totalAsleep.inMinutes}min)';
}
