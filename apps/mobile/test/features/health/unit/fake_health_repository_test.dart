import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/core/integrations/domain/integration_availability.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/health_permission_state.dart';
import 'package:memy/features/health/domain/entities/normalized_health_sample.dart';

void main() {
  late FakePlatformHealthGateway gateway;
  late FakeHealthRepository repository;
  final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 12));
  final today = LocalDate(2026, 6, 15);

  setUp(() {
    gateway = FakePlatformHealthGateway();
    repository = FakeHealthRepository(gateway: gateway, clock: clock);
  });

  tearDown(() => repository.dispose());

  NormalizedHealthSample steps(int value, {String? id}) {
    return NormalizedHealthSample(
      metricType: HealthMetricType.steps,
      value: value.toDouble(),
      unit: HealthUnit.count,
      startAt: DateTime(2026, 6, 15, 10),
      endAt: DateTime(2026, 6, 15, 10),
      source: HealthSampleSource.fake,
      providerRecordId: id,
    );
  }

  NormalizedHealthSample heart(double bpm) {
    return NormalizedHealthSample(
      metricType: HealthMetricType.heartRate,
      value: bpm,
      unit: HealthUnit.beatsPerMinute,
      startAt: DateTime(2026, 6, 15, 11),
      endAt: DateTime(2026, 6, 15, 11),
      source: HealthSampleSource.appleHealth,
    );
  }

  NormalizedHealthSample sleepMinutes(int minutes) {
    return NormalizedHealthSample(
      metricType: HealthMetricType.sleep,
      value: minutes.toDouble(),
      unit: HealthUnit.minutes,
      startAt: DateTime(2026, 6, 14, 23),
      endAt: DateTime(2026, 6, 15, 7),
      source: HealthSampleSource.fake,
    );
  }

  test('availability and unsupported states come from the gateway', () async {
    expect(
      await repository.checkAvailability(),
      IntegrationAvailability.available,
    );

    gateway.setAvailability(IntegrationAvailability.unavailable);
    expect(
      await repository.checkAvailability(),
      IntegrationAvailability.unavailable,
    );

    gateway.setAvailability(IntegrationAvailability.notSupported);
    expect(
      await repository.checkAvailability(),
      IntegrationAvailability.notSupported,
    );
  });

  test(
    'Android-style verified partial grant Activity+Heart but not Sleep',
    () async {
      gateway.nextRequestGrantsOverride = {
        HealthMetricGroup.activity,
        HealthMetricGroup.heartRate,
      };
      gateway.seedSample(steps(4200));
      gateway.seedSample(heart(78));
      gateway.seedSample(sleepMinutes(420));

      final state = await repository.requestPermissions({
        HealthMetricGroup.activity,
        HealthMetricGroup.heartRate,
        HealthMetricGroup.sleep,
      });

      expect(
        state.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.grantedVerified,
      );
      expect(
        state.dispositionOf(HealthMetricGroup.heartRate),
        HealthPermissionDisposition.grantedVerified,
      );
      expect(
        state.dispositionOf(HealthMetricGroup.sleep),
        HealthPermissionDisposition.deniedVerified,
      );
      expect(state.grantedGroups, {
        HealthMetricGroup.activity,
        HealthMetricGroup.heartRate,
      });
      expect(state.deniedGroups, {HealthMetricGroup.sleep});

      final connection = await repository.getConnection();
      expect(connection.status, IntegrationConnectionStatus.partiallyConnected);

      final summary = await repository.getDailySummary(today);
      expect(summary.steps, 4200);
      expect(summary.latestHeartRateBpm, 78);
      expect(summary.sleepDuration, isNull);
    },
  );

  test('iOS-style request marks groups unverified, still readable', () async {
    gateway.treatRequestsAsUnverified = true;
    gateway.seedSample(steps(2100));

    final state = await repository.requestPermissions({
      HealthMetricGroup.activity,
      HealthMetricGroup.sleep,
    });

    expect(
      state.dispositionOf(HealthMetricGroup.activity),
      HealthPermissionDisposition.requestCompletedUnverified,
    );
    expect(
      state.dispositionOf(HealthMetricGroup.sleep),
      HealthPermissionDisposition.requestCompletedUnverified,
    );
    expect(state.grantedGroups, isEmpty);
    expect(state.hasUnverifiedDispositions, isTrue);
    expect(state.isReadableForAggregation(HealthMetricGroup.activity), isTrue);

    final summary = await repository.getDailySummary(today);
    expect(summary.steps, 2100);
  });

  test('refresh updates permission state when heart rate revoked', () async {
    gateway.grantGroups({
      HealthMetricGroup.activity,
      HealthMetricGroup.heartRate,
    });
    await repository.requestPermissions({
      HealthMetricGroup.activity,
      HealthMetricGroup.heartRate,
    });
    gateway.seedSample(steps(1000));
    gateway.seedSample(heart(80));

    expect((await repository.getDailySummary(today)).latestHeartRateBpm, 80);

    gateway.revokeGroups({HealthMetricGroup.heartRate});
    await repository.refresh();

    final connection = await repository.getConnection();
    expect(
      connection.permissionState.dispositionOf(HealthMetricGroup.heartRate),
      HealthPermissionDisposition.deniedVerified,
    );

    final after = await repository.getDailySummary(today, forceRefresh: true);
    expect(after.steps, 1000);
    expect(after.latestHeartRateBpm, isNull);
  });

  test('disconnect clears derived cache and connection state', () async {
    gateway.nextRequestGrantsOverride = {HealthMetricGroup.activity};
    gateway.seedSample(steps(2200));
    await repository.requestPermissions({HealthMetricGroup.activity});
    expect((await repository.getDailySummary(today)).steps, 2200);

    await repository.disconnect();
    final connection = await repository.getConnection();
    expect(connection.status, IntegrationConnectionStatus.notConnected);
    expect(connection.permissionState.readableGroups, isEmpty);

    // After disconnect, no grants → empty summary even with seeded samples.
    final summary = await repository.getDailySummary(today, forceRefresh: true);
    expect(summary.steps, isNull);
    expect(summary.hasAnyData, isFalse);
  });
}
