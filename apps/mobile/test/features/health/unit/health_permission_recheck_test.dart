import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
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

  test(
    'refresh rechecks Android-style permissions and updates dispositions',
    () async {
      gateway.nextRequestGrantsOverride = {
        HealthMetricGroup.activity,
        HealthMetricGroup.heartRate,
      };
      await repository.requestPermissions({
        HealthMetricGroup.activity,
        HealthMetricGroup.heartRate,
      });

      gateway.simulatePermissionRevocation({HealthMetricGroup.heartRate});
      await repository.refresh();

      final connection = await repository.getConnection();
      expect(
        connection.permissionState.dispositionOf(HealthMetricGroup.heartRate),
        HealthPermissionDisposition.deniedVerified,
      );
      expect(
        connection.permissionState.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.grantedVerified,
      );
    },
  );

  test('iOS cancelled permission is not deniedVerified', () async {
    gateway.treatRequestsAsUnverified = true;
    gateway.nextRequestOutcome = FakePermissionRequestOutcome.cancelled;

    final state = await repository.requestPermissions({
      HealthMetricGroup.activity,
    });

    expect(
      state.dispositionOf(HealthMetricGroup.activity),
      HealthPermissionDisposition.requestCancelled,
    );
    expect(
      state.dispositionOf(HealthMetricGroup.activity),
      isNot(HealthPermissionDisposition.deniedVerified),
    );
    expect(state.isReadableForAggregation(HealthMetricGroup.activity), isFalse);

    final connection = await repository.getConnection();
    expect(connection.status, IntegrationConnectionStatus.notConnected);
  });

  test('iOS failed permission is not deniedVerified', () async {
    gateway.treatRequestsAsUnverified = true;
    gateway.nextRequestOutcome = FakePermissionRequestOutcome.failed;

    final state = await repository.requestPermissions({
      HealthMetricGroup.sleep,
    });

    expect(
      state.dispositionOf(HealthMetricGroup.sleep),
      HealthPermissionDisposition.requestFailed,
    );
    expect(
      state.dispositionOf(HealthMetricGroup.sleep),
      isNot(HealthPermissionDisposition.deniedVerified),
    );
  });

  test('revoked group clears cached summary metrics on refresh', () async {
    gateway.grantGroups({
      HealthMetricGroup.activity,
      HealthMetricGroup.heartRate,
    });
    await repository.requestPermissions({
      HealthMetricGroup.activity,
      HealthMetricGroup.heartRate,
    });
    gateway.seedSample(
      NormalizedHealthSample(
        metricType: HealthMetricType.steps,
        value: 1000,
        unit: HealthUnit.count,
        startAt: DateTime(2026, 6, 15, 10),
        endAt: DateTime(2026, 6, 15, 10),
        source: HealthSampleSource.fake,
      ),
    );
    gateway.seedSample(
      NormalizedHealthSample(
        metricType: HealthMetricType.heartRate,
        value: 80,
        unit: HealthUnit.beatsPerMinute,
        startAt: DateTime(2026, 6, 15, 11),
        endAt: DateTime(2026, 6, 15, 11),
        source: HealthSampleSource.fake,
      ),
    );

    expect((await repository.getDailySummary(today)).latestHeartRateBpm, 80);

    gateway.simulatePermissionRevocation({HealthMetricGroup.heartRate});
    await repository.refresh();
    final after = await repository.getDailySummary(today, forceRefresh: true);
    expect(after.steps, 1000);
    expect(after.latestHeartRateBpm, isNull);
  });
}
