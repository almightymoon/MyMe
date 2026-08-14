import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/health_permission_state.dart';
import 'package:memy/features/health/domain/entities/health_workout.dart';
import 'package:memy/features/health/domain/entities/normalized_health_sample.dart';
import 'package:memy/features/health/domain/services/source_attribution_formatter.dart';

void main() {
  const formatter = SourceAttributionFormatter();

  group('SourceAttributionFormatter', () {
    test('shows platform labels for each source', () {
      expect(
        formatter.platformLabel(HealthSampleSource.appleHealth),
        'Apple Health',
      );
      expect(
        formatter.platformLabel(HealthSampleSource.googleHealthConnect),
        'Health Connect',
      );
      expect(formatter.platformLabel(HealthSampleSource.fake), 'Demo data');
    });

    test('includes app name when present, never device id', () {
      final sample = NormalizedHealthSample(
        metricType: HealthMetricType.steps,
        value: 10,
        unit: HealthUnit.count,
        startAt: DateTime.utc(2026, 6, 15),
        endAt: DateTime.utc(2026, 6, 15),
        source: HealthSampleSource.appleHealth,
        sourceApplicationName: 'Nike Run Club',
        sourceDeviceId: 'SECRET-DEVICE-ID',
        sourceDeviceModel: 'iPhone15,2',
      );

      final text = formatter.forSample(sample);
      expect(text, contains('Apple Health'));
      expect(text, contains('Nike Run Club'));
      expect(text, isNot(contains('SECRET-DEVICE-ID')));
      expect(text, isNot(contains('Apple Watch')));
    });

    test('shows Apple Watch only when model/name clearly indicates watch', () {
      final watchSample = NormalizedHealthSample(
        metricType: HealthMetricType.heartRate,
        value: 70,
        unit: HealthUnit.beatsPerMinute,
        startAt: DateTime.utc(2026, 6, 15),
        endAt: DateTime.utc(2026, 6, 15),
        source: HealthSampleSource.appleHealth,
        sourceDeviceModel: 'Apple Watch Series 9',
      );
      expect(formatter.forSample(watchSample), contains('Apple Watch'));

      final phoneSample = NormalizedHealthSample(
        metricType: HealthMetricType.heartRate,
        value: 70,
        unit: HealthUnit.beatsPerMinute,
        startAt: DateTime.utc(2026, 6, 15),
        endAt: DateTime.utc(2026, 6, 15),
        source: HealthSampleSource.appleHealth,
        sourceDeviceModel: 'iPhone15,2',
      );
      expect(formatter.forSample(phoneSample), isNot(contains('Apple Watch')));
      expect(formatter.forSample(phoneSample), isNot(contains('Watch')));
    });

    test('formats workouts the same way', () {
      final workout = HealthWorkout(
        id: 'w1',
        activity: HealthWorkoutActivity.running,
        startAt: DateTime.utc(2026, 6, 15, 8),
        endAt: DateTime.utc(2026, 6, 15, 9),
        source: HealthSampleSource.googleHealthConnect,
        sourceApplicationName: 'Strava',
        sourceDeviceId: 'opaque',
      );
      final text = formatter.forWorkout(workout);
      expect(text, contains('Health Connect'));
      expect(text, contains('Strava'));
      expect(text, isNot(contains('opaque')));
    });
  });

  group('HealthPermissionState schema migration', () {
    test('migrates v1 granted/denied JSON with platform awareness', () {
      final ios = HealthPermissionState.fromJson({
        'grantedGroups': ['activity', 'sleep'],
        'deniedGroups': ['heartRate'],
      }, platform: 'ios');

      expect(ios.schemaVersion, HealthPermissionState.currentSchemaVersion);
      expect(
        ios.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.requestCompletedUnverified,
      );
      expect(
        ios.dispositionOf(HealthMetricGroup.sleep),
        HealthPermissionDisposition.requestCompletedUnverified,
      );
      expect(
        ios.dispositionOf(HealthMetricGroup.heartRate),
        HealthPermissionDisposition.deniedVerified,
      );
      expect(ios.isReadableForAggregation(HealthMetricGroup.activity), isTrue);
      expect(
        ios.isReadableForAggregation(HealthMetricGroup.heartRate),
        isFalse,
      );
    });

    test('reads v2 dispositions map', () {
      final state = HealthPermissionState.fromJson({
        'schemaVersion': 2,
        'dispositions': {
          'activity': 'requestCompletedUnverified',
          'workouts': 'grantedVerified',
          'bodyMeasurements': 'deniedVerified',
        },
      });

      expect(
        state.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.requestCompletedUnverified,
      );
      expect(
        state.isReadableForAggregation(HealthMetricGroup.activity),
        isTrue,
      );
      expect(
        state.isReadableForAggregation(HealthMetricGroup.workouts),
        isTrue,
      );
      expect(
        state.isReadableForAggregation(HealthMetricGroup.bodyMeasurements),
        isFalse,
      );
      expect(state.hasUnverifiedDispositions, isTrue);
    });
  });
}
