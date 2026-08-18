import 'dart:io';

import 'package:health/health.dart' as hp;

import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../../../core/integrations/privacy/integration_redaction.dart';
import '../../domain/entities/health_aggregate_result.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_permission_state.dart';
import '../../domain/entities/health_workout.dart';
import '../../domain/entities/normalized_health_sample.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import '../../domain/services/health_aggregation_service.dart';

/// [PlatformHealthGateway] backed by the real `health` plugin (Apple
/// HealthKit / Google Health Connect).
///
/// Plugin types (`hp.HealthDataType`, `hp.HealthDataPoint`,
/// `hp.HealthValue`, `hp.RecordingMethod`, `hp.HealthWorkoutActivityType`…)
/// are mapped to MeMy domain types at every method boundary and never
/// returned to callers. **Read-only**: this class never calls
/// `writeHealthData`/`writeWorkoutData`/etc. on the plugin, and never
/// requests `HealthDataAccess.WRITE`.
///
/// Only requests [_metricTypePlugin]/[_workoutType] — i.e. exactly the MVP
/// metrics (steps, distance, active energy, heart rate, resting heart rate,
/// sleep, exercise minutes, weight, workouts). Never ECG, blood pressure,
/// glucose, SpO2, clinical records, medications, reproductive, or nutrition
/// types, even though the plugin supports requesting them.
///
/// Sleep uses `SLEEP_ASLEEP` only (total asleep minutes) — no stage types.
class SystemPlatformHealthGateway implements PlatformHealthGateway {
  SystemPlatformHealthGateway({hp.Health? health})
    : _health = health ?? hp.Health();

  final hp.Health _health;
  final _aggregation = const HealthAggregationService();
  bool _configured = false;

  static const Map<HealthMetricType, hp.HealthDataType> _metricTypePlugin = {
    HealthMetricType.steps: hp.HealthDataType.STEPS,
    HealthMetricType.distanceWalkingRunning:
        hp.HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthMetricType.activeEnergyBurned: hp.HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthMetricType.heartRate: hp.HealthDataType.HEART_RATE,
    HealthMetricType.restingHeartRate: hp.HealthDataType.RESTING_HEART_RATE,
    // Total asleep only — do not request SLEEP_LIGHT / DEEP / REM / etc.
    HealthMetricType.sleep: hp.HealthDataType.SLEEP_ASLEEP,
    HealthMetricType.exerciseMinutes: hp.HealthDataType.EXERCISE_TIME,
    HealthMetricType.weight: hp.HealthDataType.WEIGHT,
  };

  static final Map<hp.HealthDataType, HealthMetricType> _pluginToMetricType = {
    for (final entry in _metricTypePlugin.entries) entry.value: entry.key,
  };

  static const hp.HealthDataType _workoutType = hp.HealthDataType.WORKOUT;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Set<hp.HealthDataType> _pluginTypesFor(Set<HealthMetricGroup> groups) {
    final types = <hp.HealthDataType>{};
    for (final group in groups) {
      if (group == HealthMetricGroup.workouts) {
        types.add(_workoutType);
        continue;
      }
      for (final metric in group.metricTypes) {
        final pluginType = _metricTypePlugin[metric];
        if (pluginType != null) types.add(pluginType);
      }
    }
    return types;
  }

  @override
  Future<IntegrationAvailability> checkAvailability() async {
    try {
      await _ensureConfigured();
      if (Platform.isAndroid) {
        return IntegrationAvailability.notSupported;
      }
      return IntegrationAvailability.available;
    } catch (_) {
      return IntegrationAvailability.unavailable;
    }
  }

  @override
  Future<bool?> hasPermissions(Set<HealthMetricGroup> groups) async {
    final types = _pluginTypesFor(groups).toList();
    if (types.isEmpty) return true;
    try {
      await _ensureConfigured();
      return await _health.hasPermissions(
        types,
        permissions: List.filled(types.length, hp.HealthDataAccess.READ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<HealthMetricGroup, HealthPermissionDisposition>>
  requestPermissions(Set<HealthMetricGroup> groups) async {
    final types = _pluginTypesFor(groups).toList();
    if (types.isEmpty) return const {};
    await _ensureConfigured();
    bool authorized;
    try {
      authorized = await _health.requestAuthorization(
        types,
        permissions: List.filled(types.length, hp.HealthDataAccess.READ),
      );
    } catch (e) {
      // Plugin exceptions may echo requested values back in their message —
      // never store/log the raw object, only its type (IntegrationLogSanitizer).
      if (Platform.isIOS) {
        return {
          for (final g in groups) g: HealthPermissionDisposition.requestFailed,
        };
      }
      throw IntegrationError.unknown(
        IntegrationProvider.health,
        'Could not request Health permissions.',
        IntegrationLogSanitizer.describeException(e),
      );
    }

    if (Platform.isIOS) {
      // HealthKit never discloses per-type READ grants (privacy by design):
      // a successful requestAuthorization only means the permission sheet
      // was shown without error, not that every type was switched on.
      // Do NOT map !authorized to deniedVerified — that is not verifiable.
      if (!authorized) {
        return {
          for (final g in groups)
            g: HealthPermissionDisposition.requestCancelled,
        };
      }
      return {
        for (final g in groups)
          g: HealthPermissionDisposition.requestCompletedUnverified,
      };
    }

    // Android/Health Connect reports real per-type grants — verify.
    if (!authorized) {
      return {
        for (final g in groups) g: HealthPermissionDisposition.deniedVerified,
      };
    }
    final result = <HealthMetricGroup, HealthPermissionDisposition>{};
    for (final group in groups) {
      final hasGroup = await hasPermissions({group});
      if (hasGroup == true) {
        result[group] = HealthPermissionDisposition.grantedVerified;
      } else if (hasGroup == false) {
        result[group] = HealthPermissionDisposition.deniedVerified;
      } else {
        // Unexpected null on Android — treat as unverified attempt.
        result[group] = HealthPermissionDisposition.requestCompletedUnverified;
      }
    }
    return result;
  }

  @override
  Future<List<NormalizedHealthSample>> readSamples({
    required Set<HealthMetricType> metricTypes,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final pluginTypes = <hp.HealthDataType>[];
    for (final metric in metricTypes) {
      final pluginType = _metricTypePlugin[metric];
      if (pluginType != null) pluginTypes.add(pluginType);
    }
    if (pluginTypes.isEmpty) return const [];

    await _ensureConfigured();
    List<hp.HealthDataPoint> points;
    try {
      points = await _health.getHealthDataFromTypes(
        types: pluginTypes,
        startTime: startUtc,
        endTime: endUtc,
      );
    } catch (e) {
      throw IntegrationError.unknown(
        IntegrationProvider.health,
        'Could not read Health data.',
        IntegrationLogSanitizer.describeException(e),
      );
    }

    final fetchedAt = DateTime.now().toUtc();
    final samples = <NormalizedHealthSample>[];
    for (final point in points) {
      final metricType = _pluginToMetricType[point.type];
      if (metricType == null) continue;
      final value = point.value;
      if (value is! hp.NumericHealthValue) continue;
      samples.add(
        NormalizedHealthSample(
          metricType: metricType,
          value: value.numericValue.toDouble(),
          unit: metricType.defaultUnit,
          startAt: point.dateFrom.toUtc(),
          endAt: point.dateTo.toUtc(),
          source: _sourceFor(point.sourcePlatform),
          recordingMethod: _recordingMethodFor(point.recordingMethod),
          providerRecordId: point.uuid.isEmpty ? null : point.uuid,
          sourceApplicationId: point.sourceId.isEmpty ? null : point.sourceId,
          sourceApplicationName: point.sourceName.isEmpty
              ? null
              : point.sourceName,
          sourceDeviceId: point.sourceDeviceId.isEmpty
              ? null
              : point.sourceDeviceId,
          sourceDeviceModel: point.deviceModel,
          fetchedAt: fetchedAt,
        ),
      );
    }
    return samples;
  }

  @override
  Future<List<HealthWorkout>> readWorkouts({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    await _ensureConfigured();
    List<hp.HealthDataPoint> points;
    try {
      points = await _health.getHealthDataFromTypes(
        types: [_workoutType],
        startTime: startUtc,
        endTime: endUtc,
      );
    } catch (e) {
      throw IntegrationError.unknown(
        IntegrationProvider.health,
        'Could not read workouts.',
        IntegrationLogSanitizer.describeException(e),
      );
    }

    final fetchedAt = DateTime.now().toUtc();
    final workouts = <HealthWorkout>[];
    for (final point in points) {
      final value = point.value;
      if (value is! hp.WorkoutHealthValue) continue;
      workouts.add(
        HealthWorkout(
          id: point.uuid,
          activity: _bucketActivity(value.workoutActivityType),
          startAt: point.dateFrom.toUtc(),
          endAt: point.dateTo.toUtc(),
          energyBurnedKcal: value.totalEnergyBurned?.toDouble(),
          distanceMeters: value.totalDistance?.toDouble(),
          source: _sourceFor(point.sourcePlatform),
          sourceApplicationId: point.sourceId.isEmpty ? null : point.sourceId,
          sourceApplicationName: point.sourceName.isEmpty
              ? null
              : point.sourceName,
          sourceDeviceId: point.sourceDeviceId.isEmpty
              ? null
              : point.sourceDeviceId,
          sourceDeviceModel: point.deviceModel,
          fetchedAt: fetchedAt,
        ),
      );
    }
    return workouts;
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
    try {
      await _ensureConfigured();
      final total = await _health.getTotalStepsInInterval(startUtc, endUtc);
      if (total != null) {
        return HealthAggregateResult(
          metricType: HealthMetricType.steps,
          strategy: HealthAggregateStrategy.platformTotal,
          numericValue: total.toDouble(),
        );
      }
    } catch (_) {
      // Fall through to raw + dedupe.
    }
    final fallback = await _sumDeduped(
      metricType: HealthMetricType.steps,
      startUtc: startUtc,
      endUtc: endUtc,
    );
    if (fallback == null) {
      return const HealthAggregateResult(
        metricType: HealthMetricType.steps,
        strategy: HealthAggregateStrategy.unavailable,
      );
    }
    return HealthAggregateResult(
      metricType: HealthMetricType.steps,
      strategy: HealthAggregateStrategy.rawDeduplicatedFallback,
      numericValue: fallback,
    );
  }

  /// health 13.3.1 has `getHealthIntervalDataFromTypes` for interval
  /// aggregates, but no dedicated daily distance total API analogous to
  /// [hp.Health.getTotalStepsInInterval]. Fall back to raw samples +
  /// dedupe to avoid double-counting overlapping records.
  @override
  Future<HealthAggregateResult> aggregateDistance({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final fallback = await _sumDeduped(
      metricType: HealthMetricType.distanceWalkingRunning,
      startUtc: startUtc,
      endUtc: endUtc,
    );
    if (fallback == null) {
      return const HealthAggregateResult(
        metricType: HealthMetricType.distanceWalkingRunning,
        strategy: HealthAggregateStrategy.unavailable,
      );
    }
    return HealthAggregateResult(
      metricType: HealthMetricType.distanceWalkingRunning,
      strategy: HealthAggregateStrategy.rawDeduplicatedFallback,
      numericValue: fallback,
    );
  }

  /// Same limitation as [aggregateDistance] — no plugin daily energy total.
  @override
  Future<HealthAggregateResult> aggregateActiveEnergy({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final fallback = await _sumDeduped(
      metricType: HealthMetricType.activeEnergyBurned,
      startUtc: startUtc,
      endUtc: endUtc,
    );
    if (fallback == null) {
      return const HealthAggregateResult(
        metricType: HealthMetricType.activeEnergyBurned,
        strategy: HealthAggregateStrategy.unavailable,
      );
    }
    return HealthAggregateResult(
      metricType: HealthMetricType.activeEnergyBurned,
      strategy: HealthAggregateStrategy.rawDeduplicatedFallback,
      numericValue: fallback,
    );
  }

  /// health 13.3.1 has no daily exercise-duration aggregate — raw + dedupe.
  @override
  Future<HealthAggregateResult> aggregateExerciseDuration({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final fallback = await _sumDeduped(
      metricType: HealthMetricType.exerciseMinutes,
      startUtc: startUtc,
      endUtc: endUtc,
    );
    if (fallback == null) {
      return const HealthAggregateResult(
        metricType: HealthMetricType.exerciseMinutes,
        strategy: HealthAggregateStrategy.unavailable,
      );
    }
    return HealthAggregateResult(
      metricType: HealthMetricType.exerciseMinutes,
      strategy: HealthAggregateStrategy.rawDeduplicatedFallback,
      numericValue: fallback,
    );
  }

  Future<double?> _sumDeduped({
    required HealthMetricType metricType,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final samples = await readSamples(
      metricTypes: {metricType},
      startUtc: startUtc,
      endUtc: endUtc,
    );
    final deduped = _aggregation.dedupeSamples(samples);
    if (deduped.isEmpty) return null;
    return deduped.fold<double>(0, (acc, s) => acc + s.value);
  }

  HealthSampleSource _sourceFor(hp.HealthPlatformType platform) {
    return switch (platform) {
      hp.HealthPlatformType.appleHealth => HealthSampleSource.appleHealth,
      hp.HealthPlatformType.googleHealthConnect =>
        HealthSampleSource.googleHealthConnect,
    };
  }

  HealthRecordingMethod _recordingMethodFor(hp.RecordingMethod method) {
    return switch (method) {
      hp.RecordingMethod.manual => HealthRecordingMethod.manual,
      hp.RecordingMethod.automatic => HealthRecordingMethod.automatic,
      hp.RecordingMethod.active => HealthRecordingMethod.active,
      hp.RecordingMethod.unknown => HealthRecordingMethod.unknown,
    };
  }

  HealthWorkoutActivity _bucketActivity(hp.HealthWorkoutActivityType type) {
    const walking = {
      hp.HealthWorkoutActivityType.WALKING,
      hp.HealthWorkoutActivityType.WALKING_TREADMILL,
      hp.HealthWorkoutActivityType.HIKING,
    };
    const running = {
      hp.HealthWorkoutActivityType.RUNNING,
      hp.HealthWorkoutActivityType.RUNNING_TREADMILL,
      hp.HealthWorkoutActivityType.TRACK_AND_FIELD,
    };
    const cycling = {
      hp.HealthWorkoutActivityType.BIKING,
      hp.HealthWorkoutActivityType.BIKING_STATIONARY,
      hp.HealthWorkoutActivityType.HAND_CYCLING,
    };
    const swimming = {
      hp.HealthWorkoutActivityType.SWIMMING_POOL,
      hp.HealthWorkoutActivityType.SWIMMING_OPEN_WATER,
    };
    const strength = {
      hp.HealthWorkoutActivityType.STRENGTH_TRAINING,
      hp.HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
      hp.HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING,
      hp.HealthWorkoutActivityType.CORE_TRAINING,
      hp.HealthWorkoutActivityType.WEIGHTLIFTING,
      hp.HealthWorkoutActivityType.CALISTHENICS,
    };
    const yoga = {
      hp.HealthWorkoutActivityType.YOGA,
      hp.HealthWorkoutActivityType.MIND_AND_BODY,
      hp.HealthWorkoutActivityType.PILATES,
      hp.HealthWorkoutActivityType.BARRE,
      hp.HealthWorkoutActivityType.FLEXIBILITY,
    };
    const hiit = {
      hp.HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING,
      hp.HealthWorkoutActivityType.CROSS_TRAINING,
    };
    const hiking = {hp.HealthWorkoutActivityType.HIKING};
    const sports = {
      hp.HealthWorkoutActivityType.SOCCER,
      hp.HealthWorkoutActivityType.BASKETBALL,
      hp.HealthWorkoutActivityType.TENNIS,
      hp.HealthWorkoutActivityType.BADMINTON,
      hp.HealthWorkoutActivityType.VOLLEYBALL,
      hp.HealthWorkoutActivityType.GOLF,
      hp.HealthWorkoutActivityType.BASEBALL,
      hp.HealthWorkoutActivityType.RUGBY,
      hp.HealthWorkoutActivityType.CRICKET,
      hp.HealthWorkoutActivityType.HOCKEY,
      hp.HealthWorkoutActivityType.TABLE_TENNIS,
    };

    if (walking.contains(type)) return HealthWorkoutActivity.walking;
    if (running.contains(type)) return HealthWorkoutActivity.running;
    if (cycling.contains(type)) return HealthWorkoutActivity.cycling;
    if (swimming.contains(type)) return HealthWorkoutActivity.swimming;
    if (strength.contains(type)) return HealthWorkoutActivity.strengthTraining;
    if (yoga.contains(type)) return HealthWorkoutActivity.yoga;
    if (hiit.contains(type)) return HealthWorkoutActivity.hiit;
    if (hiking.contains(type)) return HealthWorkoutActivity.hiking;
    if (sports.contains(type)) return HealthWorkoutActivity.sports;
    return HealthWorkoutActivity.other;
  }
}
