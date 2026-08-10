import 'health_metric_type.dart';

/// A completed workout session read from the platform Health store.
///
/// In-memory boundary type only — not persisted indefinitely (see
/// `HealthRepository` docs).
class HealthWorkout {
  const HealthWorkout({
    required this.id,
    required this.activity,
    required this.startAt,
    required this.endAt,
    this.energyBurnedKcal,
    this.distanceMeters,
    required this.source,
  });

  /// Platform-assigned identifier, used only to de-duplicate within one
  /// fetch — never displayed or logged.
  final String id;
  final HealthWorkoutActivity activity;
  final DateTime startAt;
  final DateTime endAt;
  final double? energyBurnedKcal;
  final double? distanceMeters;
  final HealthSampleSource source;

  Duration get duration => endAt.difference(startAt);

  @override
  String toString() =>
      'HealthWorkout(${activity.name}, duration: ${duration.inMinutes}min)';
}
