import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/trust/domain/services/support_report_builder.dart';

void main() {
  test(
    'support report is allowlisted and omits titles/health values',
    () async {
      final builder = SupportReportBuilder(
        diagnosticsProvider: () async => {
          'calendar': {'pendingOperationCount': 2, 'title': 'SECRET MEETING'},
          'health': {
            'connectionStatus': 'connected',
            'value': 12345,
            'steps': 9999,
          },
        },
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
      final calendar = diagnostics['calendar'] as Map<String, Object?>;
      final health = diagnostics['health'] as Map<String, Object?>;
      expect(calendar.containsKey('title'), isFalse);
      expect(health.containsKey('value'), isFalse);
      expect(health.containsKey('steps'), isFalse);
      expect(health['connectionStatus'], 'connected');

      final plain = builder.toPlainText(report);
      expect(plain.contains('SECRET MEETING'), isFalse);
      expect(plain.contains('12345'), isFalse);
    },
  );
}
