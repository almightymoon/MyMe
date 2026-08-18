import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/features/health/application/providers/health_providers.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_connection_config.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/health_permission_state.dart';
import 'package:memy/features/health/domain/entities/normalized_health_sample.dart';

import '../../../helpers/test_app.dart';

void main() {
  final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 12));

  Future<void> openHealth(WidgetTester tester) async {
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.health);
    await tester.pumpAndSettle();
  }

  testWidgets('disconnected Health shows connect CTA and medical disclaimer', (
    tester,
  ) async {
    final gateway = FakePlatformHealthGateway();
    final repository = FakeHealthRepository(gateway: gateway, clock: clock);

    await pumpMemyApp(
      tester,
      overrides: [
        appClockProvider.overrideWithValue(clock),
        healthRepositoryProvider.overrideWith((ref) => repository),
        platformHealthGatewayProvider.overrideWith((ref) => gateway),
        healthConnectionProvider.overrideWith(
          (ref) => repository.watchConnection(),
        ),
      ],
    );
    await signInToToday(tester);
    await openHealth(tester);

    expect(find.byKey(const Key('health_overview')), findsOneWidget);
    expect(find.byKey(const Key('health_in_app_cta')), findsOneWidget);
    expect(find.byKey(const Key('health_connect_cta')), findsNothing);
    expect(find.textContaining('Health Connect'), findsWidgets);
    expect(find.byKey(const Key('health_disclaimer')), findsOneWidget);
    expect(find.textContaining('not a diagnosis'), findsWidgets);
    expect(find.text('ECG'), findsNothing);

    repository.dispose();
  });

  testWidgets('connected Health renders live steps from the gateway', (
    tester,
  ) async {
    final gateway = FakePlatformHealthGateway(
      grantedGroups: {HealthMetricGroup.activity},
    );
    gateway.seedSample(
      NormalizedHealthSample(
        metricType: HealthMetricType.steps,
        value: 6543,
        unit: HealthUnit.count,
        startAt: DateTime(2026, 6, 15, 9),
        endAt: DateTime(2026, 6, 15, 9),
        source: HealthSampleSource.fake,
      ),
    );
    final repository = FakeHealthRepository(
      gateway: gateway,
      clock: clock,
      initialConnection: HealthConnectionConfig(
        status: IntegrationConnectionStatus.connected,
        permissionState: const HealthPermissionState(
          dispositions: {
            HealthMetricGroup.activity:
                HealthPermissionDisposition.grantedVerified,
          },
        ),
        connectedAt: clock.now(),
      ),
    );

    await pumpMemyApp(
      tester,
      overrides: [
        appClockProvider.overrideWithValue(clock),
        healthRepositoryProvider.overrideWith((ref) => repository),
        platformHealthGatewayProvider.overrideWith((ref) => gateway),
        healthConnectionProvider.overrideWith(
          (ref) => repository.watchConnection(),
        ),
      ],
    );
    await signInToToday(tester);
    await openHealth(tester);

    expect(find.byKey(const Key('health_metrics_grid')), findsOneWidget);
    expect(find.textContaining('6,543'), findsWidgets);

    repository.dispose();
  });
}
