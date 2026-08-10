import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/repositories/fake_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_connection_config.dart';
import 'package:memy/features/trust/data/repositories/memy_local_data_export_service.dart';
import 'package:memy/features/trust/domain/entities/data_catalog.dart';
import 'package:memy/features/trust/domain/entities/export_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export omits secrets and raw health values', () async {
    SharedPreferences.setMockInitialValues({});
    final goals = FakeGoalRepository(
      initial: [
        Goal(
          id: 'g1',
          name: 'Save',
          category: GoalCategory.financial,
          priority: GoalPriority.medium,
          status: GoalStatus.active,
          deadline: DateTime(2027),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          progressPercent: 10,
        ),
      ],
    );
    final health = FakeHealthRepository(
      gateway: FakePlatformHealthGateway(),
      initialConnection: const HealthConnectionConfig(),
    );
    final temp = await Directory.systemTemp.createTemp('memy_export_test');
    final service = MemyLocalDataExportService(
      goalRepository: goals,
      healthRepository: health,
      preferencesReader: () async => {
        'themeMode': 'system',
        'token': 'should-not-appear-unless-reader-adds-it',
      },
      tempDirectoryOverride: () async => temp,
      clock: () => DateTime.utc(2026, 8, 10),
    );

    final map = await service.buildExportMap(
      const ExportRequest(
        modules: {DataModule.goals, DataModule.health, DataModule.preferences},
      ),
    );

    final encoded = map.toString();
    expect(encoded.contains('password'), isFalse);
    expect(encoded.contains('apiKey'), isFalse);

    final healthModule = map['modules'] as Map<String, Object?>;
    final healthPayload = healthModule['health'] as Map<String, Object?>;
    expect(healthPayload.containsKey('connectionSummary'), isTrue);
    expect(encoded.contains('steps'), isFalse);
    expect(encoded.contains('heartRate'), isFalse);

    goals.dispose();
    health.dispose();
    await temp.delete(recursive: true);
  });
}
