import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/integrations/domain/integration_diagnostics_report.dart';
import 'package:memy/features/trust/domain/entities/support_diagnostics_report.dart';
import 'package:memy/features/trust/domain/services/support_report_builder.dart';

void main() {
  test(
    'support report is allowlisted and omits titles/health values/tokens',
    () async {
      final integration = IntegrationDiagnosticsReport(
        generatedAtUtc: DateTime.utc(2026, 8, 10),
        app: const AppDiagnosticsSection(
          osFamily: 'ios',
          osVersion: '18.0',
          timezone: 'UTC',
          locale: 'en_US',
          isDebugBuild: true,
        ),
        calendar: const CalendarDiagnosticsSection(
          gatewayMode: 'fake',
          availability: 'available',
          connectionStatus: 'connected',
          readableCalendarCount: 1,
          hasValidWritableTarget: true,
          calendarSchemaVersion: 3,
          pendingOperationCount: 2,
          conflictCount: 0,
          suspectedMissingCount: 0,
          confirmedMissingCount: 0,
          unresolvedRecoveryCount: 0,
          unknownOutcomeCount: 0,
          requiresUserActionCount: 0,
        ),
        health: const HealthDiagnosticsSection(
          gatewayMode: 'fake',
          availability: 'available',
          connectionStatus: 'connected',
          permissionDispositions: {'steps': 'granted'},
          configSchemaVersion: 1,
          recoveryNeeded: false,
          backupAvailable: false,
        ),
      );

      final builder = SupportReportBuilder(
        diagnosticsProvider: () async =>
            SupportDiagnosticsReport.fromIntegration(report: integration),
      );

      final report = await builder.build(
        appVersion: '1.0.0',
        buildNumber: '1',
        packageName: 'app.memy',
        platform: 'ios',
        locale: 'en_US',
        goalsDataSource: 'local',
        financeDataSource: 'local',
        habitsDataSource: 'local',
        calendarDataSource: 'fake',
        healthDataSource: 'fake',
        feature: 'report_problem',
        userMessage: 'Something broke',
      );

      expect(report.containsKey('appVersion'), isTrue);
      expect(report['feature'], 'report_problem');
      final diagnostics = report['diagnostics'] as Map<String, Object?>;
      final encoded = diagnostics.toString();
      expect(encoded.contains('SECRET MEETING'), isFalse);
      expect(encoded.contains('heartRate'), isFalse);
      expect(encoded.contains('token'), isFalse);
      expect(encoded.contains('password'), isFalse);

      final calendar = diagnostics['calendar'] as Map<String, Object?>;
      final health = diagnostics['health'] as Map<String, Object?>;
      expect(calendar['pendingOperationCount'], 2);
      expect(health['connectionStatus'], 'connected');
      expect(health.containsKey('value'), isFalse);
      expect(health.containsKey('heartRate'), isFalse);
      expect(health.containsKey('title'), isFalse);

      final plain = builder.toPlainText(report);
      expect(plain.contains('heartRate'), isFalse);
      expect(plain.contains('token'), isFalse);
    },
  );
}
