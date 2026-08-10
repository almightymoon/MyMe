import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/integrations/domain/integration_diagnostics_report.dart';

void main() {
  group('IntegrationDiagnosticsReport redaction', () {
    test('JSON never contains sensitive calendar or health content keys', () {
      final report = IntegrationDiagnosticsReport(
        generatedAtUtc: DateTime.utc(2026, 6, 15, 12),
        app: const AppDiagnosticsSection(
          osFamily: 'ios',
          osVersion: '17.0',
          timezone: 'UTC',
          locale: 'en_US',
          isDebugBuild: true,
        ),
        calendar: CalendarDiagnosticsSection(
          gatewayMode: 'fake',
          availability: 'available',
          connectionStatus: 'connected',
          readableCalendarCount: 2,
          hasValidWritableTarget: true,
          calendarSchemaVersion: 3,
          pendingOperationCount: 1,
          conflictCount: 0,
          suspectedMissingCount: 1,
          confirmedMissingCount: 0,
          unresolvedRecoveryCount: 0,
          unknownOutcomeCount: 0,
          requiresUserActionCount: 0,
          lastSuccessfulPullAt: DateTime.utc(2026, 6, 15, 11),
          lastErrorCode: 'permissionDenied',
        ),
        health: const HealthDiagnosticsSection(
          gatewayMode: 'fake',
          availability: 'available',
          connectionStatus: 'connected',
          permissionDispositions: {
            'activity': 'grantedVerified',
            'heartRate': 'requestCompletedUnverified',
          },
          configSchemaVersion: 2,
          recoveryNeeded: false,
          backupAvailable: true,
        ),
      );

      final json = report.toJson().toString();
      expect(json, isNot(contains('title')));
      expect(json, isNot(contains('notes')));
      expect(json, isNot(contains('location')));
      expect(json, isNot(contains('attendee')));
      expect(json, isNot(contains('heartRateValue')));
      expect(json, isNot(contains('stepsValue')));
      expect(json, isNot(contains('sourceDeviceId')));
      expect(json, isNot(contains('@')));
      expect(json, contains('suspectedMissingCount'));
      expect(json, contains('unresolvedRecoveryCount'));
      expect(json, contains('backupAvailable'));
      expect(json, contains('permissionDispositions'));
      expect(json, contains('gatewayMode'));
    });
  });
}
