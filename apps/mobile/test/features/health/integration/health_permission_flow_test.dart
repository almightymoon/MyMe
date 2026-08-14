import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/normalized_health_sample.dart';

/// Integration-style Health flow against [FakePlatformHealthGateway].
void main() {
  test(
    'connect → partial grant → Today-shaped summary → revoke → disconnect',
    () async {
      final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 12));
      final today = LocalDate(2026, 6, 15);
      final gateway = FakePlatformHealthGateway();
      final repository = FakeHealthRepository(gateway: gateway, clock: clock);

      gateway.nextRequestGrantsOverride = {
        HealthMetricGroup.activity,
        HealthMetricGroup.heartRate,
      };
      gateway.seedSample(
        NormalizedHealthSample(
          metricType: HealthMetricType.steps,
          value: 5100,
          unit: HealthUnit.count,
          startAt: DateTime(2026, 6, 15, 8),
          endAt: DateTime(2026, 6, 15, 8),
          source: HealthSampleSource.fake,
        ),
      );
      gateway.seedSample(
        NormalizedHealthSample(
          metricType: HealthMetricType.heartRate,
          value: 74,
          unit: HealthUnit.beatsPerMinute,
          startAt: DateTime(2026, 6, 15, 9),
          endAt: DateTime(2026, 6, 15, 9),
          source: HealthSampleSource.appleHealth,
        ),
      );
      gateway.seedSample(
        NormalizedHealthSample(
          metricType: HealthMetricType.sleep,
          value: 390,
          unit: HealthUnit.minutes,
          startAt: DateTime(2026, 6, 14, 23),
          endAt: DateTime(2026, 6, 15, 6, 30),
          source: HealthSampleSource.fake,
        ),
      );

      final granted = await repository.requestPermissions({
        HealthMetricGroup.activity,
        HealthMetricGroup.heartRate,
        HealthMetricGroup.sleep,
      });
      expect(
        granted.isReadableForAggregation(HealthMetricGroup.sleep),
        isFalse,
      );
      expect(
        (await repository.getConnection()).status,
        IntegrationConnectionStatus.partiallyConnected,
      );

      var summary = await repository.getDailySummary(today);
      expect(summary.steps, 5100);
      expect(summary.latestHeartRateBpm, 74);
      expect(summary.sleepDuration, isNull);

      gateway.seedSample(
        NormalizedHealthSample(
          metricType: HealthMetricType.steps,
          value: 400,
          unit: HealthUnit.count,
          startAt: DateTime(2026, 6, 15, 14),
          endAt: DateTime(2026, 6, 15, 14),
          source: HealthSampleSource.fake,
        ),
      );
      await repository.refresh();
      summary = await repository.getDailySummary(today, forceRefresh: true);
      expect(summary.steps, 5500);

      gateway.revokeGroups({HealthMetricGroup.heartRate});
      await repository.refresh();
      summary = await repository.getDailySummary(today, forceRefresh: true);
      expect(summary.steps, 5500);
      expect(summary.latestHeartRateBpm, isNull);

      await repository.disconnect();
      expect(
        (await repository.getConnection()).status,
        IntegrationConnectionStatus.notConnected,
      );
      summary = await repository.getDailySummary(today, forceRefresh: true);
      expect(summary.hasAnyData, isFalse);

      repository.dispose();
    },
  );
}
