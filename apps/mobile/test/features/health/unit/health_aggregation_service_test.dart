import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/health_workout.dart';
import 'package:memy/features/health/domain/entities/normalized_health_sample.dart';
import 'package:memy/features/health/domain/services/health_aggregation_service.dart';

void main() {
  const aggregation = HealthAggregationService();
  final day = LocalDate(2026, 6, 15);
  final generatedAt = DateTime.utc(2026, 6, 15, 12);

  NormalizedHealthSample sample({
    required HealthMetricType type,
    required double value,
    required DateTime start,
    DateTime? end,
    HealthRecordingMethod method = HealthRecordingMethod.automatic,
    HealthSampleSource source = HealthSampleSource.fake,
    String? providerRecordId,
  }) {
    return NormalizedHealthSample(
      metricType: type,
      value: value,
      unit: type.defaultUnit,
      startAt: start,
      endAt: end ?? start,
      source: source,
      recordingMethod: method,
      providerRecordId: providerRecordId,
    );
  }

  group('HealthAggregationService', () {
    test('sums steps, distance, and active energy for the day', () {
      final start = DateTime(2026, 6, 15, 8);
      final summary = aggregation.summarizeDay(
        date: day,
        generatedAt: generatedAt,
        samples: [
          sample(type: HealthMetricType.steps, value: 1000, start: start),
          sample(
            type: HealthMetricType.steps,
            value: 2500,
            start: start.add(const Duration(hours: 2)),
          ),
          sample(
            type: HealthMetricType.distanceWalkingRunning,
            value: 1200,
            start: start,
          ),
          sample(
            type: HealthMetricType.activeEnergyBurned,
            value: 180,
            start: start,
          ),
        ],
      );

      expect(summary.steps, 3500);
      expect(summary.distanceMeters, 1200);
      expect(summary.activeEnergyKcal, 180);
    });

    test('deduplicates by providerRecordId before summing', () {
      final start = DateTime(2026, 6, 15, 8);
      final summary = aggregation.summarizeDay(
        date: day,
        generatedAt: generatedAt,
        samples: [
          sample(
            type: HealthMetricType.steps,
            value: 1000,
            start: start,
            providerRecordId: 'rec-1',
          ),
          sample(
            type: HealthMetricType.steps,
            value: 1000,
            start: start,
            providerRecordId: 'rec-1',
          ),
          sample(
            type: HealthMetricType.steps,
            value: 500,
            start: start.add(const Duration(hours: 1)),
            providerRecordId: 'rec-2',
          ),
        ],
      );

      expect(summary.steps, 1500);
    });

    test(
      'keeps id-less samples without treating them as stable duplicates',
      () {
        final start = DateTime(2026, 6, 15, 8);
        final summary = aggregation.summarizeDay(
          date: day,
          generatedAt: generatedAt,
          samples: [
            sample(type: HealthMetricType.steps, value: 100, start: start),
            sample(type: HealthMetricType.steps, value: 100, start: start),
          ],
        );

        // Ephemeral / missing ids are not collapsed — both contribute.
        expect(summary.steps, 200);
      },
    );

    test('rejects NaN, infinity, and negative values', () {
      final start = DateTime(2026, 6, 15, 8);
      final summary = aggregation.summarizeDay(
        date: day,
        generatedAt: generatedAt,
        samples: [
          sample(type: HealthMetricType.steps, value: 40, start: start),
          sample(type: HealthMetricType.steps, value: double.nan, start: start),
          sample(
            type: HealthMetricType.steps,
            value: double.infinity,
            start: start,
          ),
          sample(type: HealthMetricType.steps, value: -5, start: start),
        ],
      );

      expect(summary.steps, 40);
    });

    test('uses the latest heart-rate reading, not an average', () {
      final summary = aggregation.summarizeDay(
        date: day,
        generatedAt: generatedAt,
        samples: [
          sample(
            type: HealthMetricType.heartRate,
            value: 70,
            start: DateTime(2026, 6, 15, 9),
          ),
          sample(
            type: HealthMetricType.heartRate,
            value: 92,
            start: DateTime(2026, 6, 15, 11),
          ),
          sample(
            type: HealthMetricType.restingHeartRate,
            value: 58,
            start: DateTime(2026, 6, 15, 7),
          ),
        ],
      );

      expect(summary.latestHeartRateBpm, 92);
      expect(summary.restingHeartRateBpm, 58);
    });

    test('attributes overnight sleep to the wake-up local date', () {
      final sleepStart = DateTime(2026, 6, 14, 23);
      final sleepEnd = DateTime(2026, 6, 15, 7);
      final summary = aggregation.summarizeDay(
        date: day,
        generatedAt: generatedAt,
        samples: [
          sample(
            type: HealthMetricType.sleep,
            value: 480,
            start: sleepStart,
            end: sleepEnd,
          ),
        ],
      );

      expect(summary.sleepDuration, const Duration(minutes: 480));

      final nightBefore = aggregation.summarizeDay(
        date: LocalDate(2026, 6, 14),
        generatedAt: generatedAt,
        samples: [
          sample(
            type: HealthMetricType.sleep,
            value: 480,
            start: sleepStart,
            end: sleepEnd,
          ),
        ],
      );
      expect(nightBefore.sleepDuration, isNull);
    });

    test('ignores samples and workouts outside the target local date', () {
      final summary = aggregation.summarizeDay(
        date: day,
        generatedAt: generatedAt,
        samples: [
          sample(
            type: HealthMetricType.steps,
            value: 9999,
            start: DateTime(2026, 6, 14, 12),
          ),
        ],
        workouts: [
          HealthWorkout(
            id: 'w1',
            activity: HealthWorkoutActivity.running,
            startAt: DateTime(2026, 6, 14, 18),
            endAt: DateTime(2026, 6, 14, 19),
            source: HealthSampleSource.fake,
          ),
        ],
      );

      expect(summary.steps, isNull);
      expect(summary.workouts, isEmpty);
      expect(summary.hasAnyData, isFalse);
    });

    test(
      'includes same-day workouts and preserves manual recording samples',
      () {
        final summary = aggregation.summarizeDay(
          date: day,
          generatedAt: generatedAt,
          samples: [
            sample(
              type: HealthMetricType.weight,
              value: 72.4,
              start: DateTime(2026, 6, 15, 7),
              method: HealthRecordingMethod.manual,
            ),
          ],
          workouts: [
            HealthWorkout(
              id: 'w2',
              activity: HealthWorkoutActivity.yoga,
              startAt: DateTime(2026, 6, 15, 7),
              endAt: DateTime(2026, 6, 15, 8),
              energyBurnedKcal: 120,
              source: HealthSampleSource.appleHealth,
            ),
          ],
        );

        expect(summary.weightKg, 72.4);
        expect(summary.workouts, hasLength(1));
        expect(summary.workouts.single.activity, HealthWorkoutActivity.yoga);
      },
    );

    test('sample toString never includes the numeric value', () {
      final s = sample(
        type: HealthMetricType.heartRate,
        value: 123,
        start: DateTime.utc(2026, 6, 15),
      );
      expect(s.toString(), isNot(contains('123')));
      expect(s.toString(), contains('heartRate'));
    });
  });
}
