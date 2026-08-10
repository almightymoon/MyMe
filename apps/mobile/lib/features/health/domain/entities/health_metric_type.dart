/// MVP-scoped health metrics MeMy reads from the platform Health store.
///
/// Deliberately excludes anything clinical/sensitive: no ECG, blood
/// pressure, glucose, SpO2, medications, reproductive, or nutrition data.
/// Adding a new type here requires updating [HealthMetricGroup] mapping and
/// the System gateway's platform-type mapping — never widen scope silently.
enum HealthMetricType {
  steps,
  distanceWalkingRunning,
  activeEnergyBurned,
  heartRate,
  restingHeartRate,
  sleep,
  exerciseMinutes,
  weight;

  String get label => switch (this) {
    HealthMetricType.steps => 'Steps',
    HealthMetricType.distanceWalkingRunning => 'Distance',
    HealthMetricType.activeEnergyBurned => 'Active energy',
    HealthMetricType.heartRate => 'Heart rate',
    HealthMetricType.restingHeartRate => 'Resting heart rate',
    HealthMetricType.sleep => 'Sleep',
    HealthMetricType.exerciseMinutes => 'Exercise minutes',
    HealthMetricType.weight => 'Weight',
  };

  HealthUnit get defaultUnit => switch (this) {
    HealthMetricType.steps => HealthUnit.count,
    HealthMetricType.distanceWalkingRunning => HealthUnit.meters,
    HealthMetricType.activeEnergyBurned => HealthUnit.kilocalories,
    HealthMetricType.heartRate => HealthUnit.beatsPerMinute,
    HealthMetricType.restingHeartRate => HealthUnit.beatsPerMinute,
    HealthMetricType.sleep => HealthUnit.minutes,
    HealthMetricType.exerciseMinutes => HealthUnit.minutes,
    HealthMetricType.weight => HealthUnit.kilograms,
  };

  HealthMetricGroup get group => switch (this) {
    HealthMetricType.steps => HealthMetricGroup.activity,
    HealthMetricType.distanceWalkingRunning => HealthMetricGroup.activity,
    HealthMetricType.activeEnergyBurned => HealthMetricGroup.activity,
    HealthMetricType.exerciseMinutes => HealthMetricGroup.activity,
    HealthMetricType.heartRate => HealthMetricGroup.heartRate,
    HealthMetricType.restingHeartRate => HealthMetricGroup.heartRate,
    HealthMetricType.sleep => HealthMetricGroup.sleep,
    HealthMetricType.weight => HealthMetricGroup.bodyMeasurements,
  };
}

/// User-facing permission groups for the connection/permission-selection UI.
///
/// Grouping mirrors how HealthKit/Health Connect present read scopes so a
/// single toggle maps to one OS permission prompt, plus workouts as their
/// own group since they're requested as a distinct data type.
enum HealthMetricGroup {
  activity,
  heartRate,
  sleep,
  bodyMeasurements,
  workouts,
}

extension HealthMetricGroupX on HealthMetricGroup {
  String get label => switch (this) {
    HealthMetricGroup.activity =>
      'Activity (steps, distance, energy, exercise)',
    HealthMetricGroup.heartRate => 'Heart rate',
    HealthMetricGroup.sleep => 'Sleep',
    HealthMetricGroup.bodyMeasurements => 'Weight',
    HealthMetricGroup.workouts => 'Workouts',
  };

  /// Metric types requested together for this group. Empty for
  /// [HealthMetricGroup.workouts], which reads [HealthWorkout]s instead.
  Set<HealthMetricType> get metricTypes {
    return HealthMetricType.values.where((m) => m.group == this).toSet();
  }
}

/// Units used by [NormalizedHealthSample]/[HealthWorkout]/[DailyHealthSummary].
///
/// A small MeMy-owned unit set — never the `health` plugin's `HealthDataUnit`
/// outside `data/gateways/`.
enum HealthUnit {
  count,
  meters,
  kilocalories,
  beatsPerMinute,
  minutes,
  kilograms;

  String get abbreviation => switch (this) {
    HealthUnit.count => '',
    HealthUnit.meters => 'm',
    HealthUnit.kilocalories => 'kcal',
    HealthUnit.beatsPerMinute => 'bpm',
    HealthUnit.minutes => 'min',
    HealthUnit.kilograms => 'kg',
  };
}

/// MeMy-owned mirror of the platform's data-recording provenance.
///
/// Kept separate from the `health` plugin's `RecordingMethod` so that enum
/// never leaks past `data/gateways/`.
enum HealthRecordingMethod { unknown, manual, automatic, active }

/// MeMy-owned mirror of which platform Health store a sample came from.
enum HealthSampleSource { appleHealth, googleHealthConnect, fake }

extension HealthSampleSourceX on HealthSampleSource {
  String get label => switch (this) {
    HealthSampleSource.appleHealth => 'Apple Health',
    HealthSampleSource.googleHealthConnect => 'Health Connect',
    HealthSampleSource.fake => 'Demo data',
  };
}

/// Coarse workout activity buckets MeMy displays.
///
/// The `health` plugin exposes 100+ granular `HealthWorkoutActivityType`
/// values; MeMy only needs enough resolution for a simple workout list, so
/// the System gateway buckets those into this small MeMy-owned enum.
enum HealthWorkoutActivity {
  walking,
  running,
  cycling,
  swimming,
  strengthTraining,
  yoga,
  hiit,
  hiking,
  sports,
  other;

  String get label => switch (this) {
    HealthWorkoutActivity.walking => 'Walking',
    HealthWorkoutActivity.running => 'Running',
    HealthWorkoutActivity.cycling => 'Cycling',
    HealthWorkoutActivity.swimming => 'Swimming',
    HealthWorkoutActivity.strengthTraining => 'Strength training',
    HealthWorkoutActivity.yoga => 'Yoga',
    HealthWorkoutActivity.hiit => 'HIIT',
    HealthWorkoutActivity.hiking => 'Hiking',
    HealthWorkoutActivity.sports => 'Sports',
    HealthWorkoutActivity.other => 'Workout',
  };
}
