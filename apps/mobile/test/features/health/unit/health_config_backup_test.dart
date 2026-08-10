import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/data/repositories/health_connection_storage.dart';
import 'package:memy/features/health/data/repositories/system_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_connection_config.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/health_permission_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FakeHealthRepository backup', () {
    test('restoreBackup recovers last-known-good config', () async {
      final gateway = FakePlatformHealthGateway();
      final repository = FakeHealthRepository(gateway: gateway);
      gateway.nextRequestGrantsOverride = {HealthMetricGroup.activity};

      await repository.requestPermissions({HealthMetricGroup.activity});
      final before = await repository.getConnection();
      expect(before.status, IntegrationConnectionStatus.connected);

      await repository.requestPermissions({HealthMetricGroup.sleep});
      expect(await repository.hasBackupAvailable(), isTrue);

      final restored = await repository.restoreBackup();
      expect(
        restored.permissionState.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.grantedVerified,
      );

      repository.dispose();
    });

    test('corrupt primary with valid backup flags recovery', () async {
      final gateway = FakePlatformHealthGateway();
      final repository = FakeHealthRepository(gateway: gateway);
      gateway.nextRequestGrantsOverride = {HealthMetricGroup.activity};
      await repository.requestPermissions({HealthMetricGroup.activity});

      final goodBackup = jsonEncode(
        (await repository.getConnection()).toJson(),
      );
      repository.setBackupJsonForTests(goodBackup);
      repository.simulateCorruptPrimaryForTests();

      final connection = await repository.getConnection();
      expect(connection.recoveryNeeded, isTrue);
      expect(connection.backupAvailable, isTrue);

      repository.dispose();
    });
  });

  group('SystemHealthRepository backup', () {
    test('corrupt primary reads valid backup with recovery flag', () async {
      final goodConfig = HealthConnectionConfig(
        status: IntegrationConnectionStatus.connected,
        permissionState: const HealthPermissionState(
          dispositions: {
            HealthMetricGroup.activity:
                HealthPermissionDisposition.grantedVerified,
          },
        ),
        connectedAt: DateTime.utc(2026, 6, 15),
      );
      final goodJson = jsonEncode(goodConfig.toJson());

      SharedPreferences.setMockInitialValues({
        HealthConnectionStorageKeys.primary: '{not-json',
        HealthConnectionStorageKeys.backup: goodJson,
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = SystemHealthRepository(
        gateway: FakePlatformHealthGateway(),
        prefs: prefs,
      );

      final connection = await repository.getConnection();
      expect(connection.recoveryNeeded, isTrue);
      expect(connection.backupAvailable, isTrue);
      expect(
        connection.permissionState.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.grantedVerified,
      );
      expect(await repository.hasBackupAvailable(), isTrue);

      final restored = await repository.restoreBackup();
      expect(restored.recoveryNeeded, isFalse);
      expect(
        prefs.getString(HealthConnectionStorageKeys.primary),
        isNot(contains('not-json')),
      );

      repository.dispose();
    });

    test('resetConnection clears primary and backup', () async {
      SharedPreferences.setMockInitialValues({
        HealthConnectionStorageKeys.primary: jsonEncode(
          const HealthConnectionConfig().toJson(),
        ),
        HealthConnectionStorageKeys.backup: jsonEncode(
          const HealthConnectionConfig().toJson(),
        ),
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = SystemHealthRepository(
        gateway: FakePlatformHealthGateway(),
        prefs: prefs,
      );

      await repository.resetConnection();
      expect(prefs.getString(HealthConnectionStorageKeys.primary), isNull);
      expect(prefs.getString(HealthConnectionStorageKeys.backup), isNull);

      repository.dispose();
    });
  });
}
