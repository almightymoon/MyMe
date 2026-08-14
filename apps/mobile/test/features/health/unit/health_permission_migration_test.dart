import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/health/domain/entities/health_metric_type.dart';
import 'package:memy/features/health/domain/entities/health_permission_state.dart';
import 'package:memy/features/health/domain/services/health_permission_migration_service.dart';

void main() {
  const migration = HealthPermissionMigrationService();

  group('HealthPermissionMigrationService', () {
    test('iOS legacy granted maps to requestCompletedUnverified', () {
      final state = migration.migrateLegacy(
        json: {
          'grantedGroups': ['activity', 'sleep'],
          'deniedGroups': ['heartRate'],
        },
        platform: 'ios',
      );

      expect(
        state.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.requestCompletedUnverified,
      );
      expect(
        state.dispositionOf(HealthMetricGroup.sleep),
        HealthPermissionDisposition.requestCompletedUnverified,
      );
      expect(
        state.dispositionOf(HealthMetricGroup.heartRate),
        HealthPermissionDisposition.deniedVerified,
      );
      expect(state.grantedGroups, isEmpty);
    });

    test('Android legacy granted is unverified until async verify', () {
      final state = migration.migrateLegacy(
        json: {
          'grantedGroups': ['activity'],
        },
        platform: 'android',
      );

      expect(
        state.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.requestCompletedUnverified,
      );
    });

    test('Android async verify upgrades to grantedVerified', () async {
      final state = await migration.migrateLegacyAsync(
        json: {
          'grantedGroups': ['activity', 'sleep'],
        },
        platform: 'android',
        verifyGroup: (group) async => group == HealthMetricGroup.activity,
      );

      expect(
        state.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.grantedVerified,
      );
      expect(
        state.dispositionOf(HealthMetricGroup.sleep),
        HealthPermissionDisposition.deniedVerified,
      );
    });

    test('fromJson with platform uses migration for v1 payload', () {
      final ios = HealthPermissionState.fromJson({
        'grantedGroups': ['activity'],
      }, platform: 'ios');
      expect(
        ios.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.requestCompletedUnverified,
      );

      final android = HealthPermissionState.fromJson({
        'grantedGroups': ['activity'],
      }, platform: 'android');
      expect(
        android.dispositionOf(HealthMetricGroup.activity),
        HealthPermissionDisposition.requestCompletedUnverified,
      );
    });
  });
}
