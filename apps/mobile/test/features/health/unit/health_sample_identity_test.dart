import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/normalized_health_sample.dart';
import 'package:memy/features/health/domain/services/health_aggregation_service.dart';

void main() {
  const aggregation = HealthAggregationService();
  final day = LocalDate(2026, 6, 15);
  final generatedAt = DateTime.utc(2026, 6, 15, 12);
  final start = DateTime(2026, 6, 15, 8);

  NormalizedHealthSample sample({
    required HealthMetricType type,
    required double value,
    required HealthSampleSource source,
    String? providerRecordId,
  }) {
    return NormalizedHealthSample(
      metricType: type,
      value: value,
      unit: type.defaultUnit,
      startAt: start,
      endAt: start,
      source: source,
      providerRecordId: providerRecordId,
    );
  }

  test('same provider id across metrics counts both', () {
    final summary = aggregation.summarizeDay(
      date: day,
      generatedAt: generatedAt,
      samples: [
        sample(
          type: HealthMetricType.steps,
          value: 1000,
          source: HealthSampleSource.appleHealth,
          providerRecordId: 'shared-id',
        ),
        sample(
          type: HealthMetricType.distanceWalkingRunning,
          value: 500,
          source: HealthSampleSource.appleHealth,
          providerRecordId: 'shared-id',
        ),
      ],
    );

    expect(summary.steps, 1000);
    expect(summary.distanceMeters, 500);
  });

  test('same id on different platforms counts both', () {
    final summary = aggregation.summarizeDay(
      date: day,
      generatedAt: generatedAt,
      samples: [
        sample(
          type: HealthMetricType.steps,
          value: 800,
          source: HealthSampleSource.appleHealth,
          providerRecordId: 'dup-id',
        ),
        sample(
          type: HealthMetricType.steps,
          value: 900,
          source: HealthSampleSource.googleHealthConnect,
          providerRecordId: 'dup-id',
        ),
      ],
    );

    expect(summary.steps, 1700);
  });

  test('duplicate composite identity is deduped once', () {
    final summary = aggregation.summarizeDay(
      date: day,
      generatedAt: generatedAt,
      samples: [
        sample(
          type: HealthMetricType.steps,
          value: 1000,
          source: HealthSampleSource.fake,
          providerRecordId: 'rec-1',
        ),
        sample(
          type: HealthMetricType.steps,
          value: 1000,
          source: HealthSampleSource.fake,
          providerRecordId: 'rec-1',
        ),
      ],
    );

    expect(summary.steps, 1000);
  });
}
