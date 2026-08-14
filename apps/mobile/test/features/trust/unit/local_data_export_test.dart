import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/repositories/api_goal_repository.dart';
import 'package:memy/features/goals/data/repositories/fake_goal_repository.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_connection_config.dart';
import 'package:memy/features/trust/data/repositories/memy_local_data_export_service.dart';
import 'package:memy/features/trust/domain/entities/data_catalog.dart';
import 'package:memy/features/trust/domain/entities/export_request.dart';
import 'package:memy/features/trust/domain/services/export_file_lifecycle_service.dart';
import 'package:memy/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export version 2 fields present and omits raw health values', () async {
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
    final lifecycle = ExportFileLifecycleService(
      tempDirectoryOverride: () async => temp,
      clock: () => DateTime.utc(2026, 8, 10),
    );
    final service = MemyLocalDataExportService(
      goalRepository: goals,
      healthRepository: health,
      preferencesReader: () async => {'themeMode': 'system'},
      tempDirectoryOverride: () async => temp,
      clock: () => DateTime.utc(2026, 8, 10),
      appVersionProvider: () => '1.2.3',
      buildNumberProvider: () => '42',
      environment: 'demo',
      localeProvider: () => 'en_US',
      timezoneProvider: () => 'UTC',
      dataSourceModesProvider: () => {
        'goals': 'local',
        'finance': 'local',
        'habits': 'local',
        'calendar': 'fake',
        'health': 'fake',
      },
      fileLifecycle: lifecycle,
    );

    final map = await service.buildExportMap(
      const ExportRequest(
        modules: {DataModule.goals, DataModule.health, DataModule.preferences},
      ),
    );

    expect(map['exportVersion'], 2);
    final app = map['app'] as Map<String, Object?>;
    expect(app['name'], 'MeMy');
    expect(app['version'], '1.2.3');
    expect(app['buildNumber'], '42');
    expect(app['environment'], 'demo');
    expect(map['createdAtUtc'], isNotNull);
    expect(map['locale'], 'en_US');
    expect(map['timezone'], 'UTC');
    expect(map['dataSourceModes'], isA<Map>());
    expect(
      map['selectedModules'],
      containsAll(['goals', 'health', 'preferences']),
    );
    expect(map['recordCounts'], isA<Map>());
    expect(map['modules'], isA<Map>());
    expect(map['warnings'], isA<List>());

    final encoded = map.toString();
    expect(encoded.contains('password'), isFalse);
    expect(encoded.contains('apiKey'), isFalse);
    expect(encoded.contains('heartRate'), isFalse);
    expect(encoded.contains('steps'), isFalse);

    final healthModule = map['modules'] as Map<String, Object?>;
    final healthPayload = healthModule['health'] as Map<String, Object?>;
    expect(healthPayload.containsKey('connectionSummary'), isTrue);

    final result = await service.export(
      const ExportRequest(modules: {DataModule.goals}),
    );
    expect(File(result.filePath).existsSync(), isTrue);
    expect(result.filePath.contains('memy-data-export-'), isTrue);

    goals.dispose();
    health.dispose();
    await temp.delete(recursive: true);
  });

  test('API goals export uses cache with warning', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cache = LocalGoalRepository(
      prefs: prefs,
      seedBuilder: () => const [],
    );
    await cache.replaceAll([
      Goal(
        id: 'g1',
        name: 'Cached',
        category: GoalCategory.health,
        priority: GoalPriority.low,
        status: GoalStatus.active,
        deadline: DateTime(2027),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        progressPercent: 0,
      ),
    ]);
    final api = ApiGoalRepository(
      client: ApiClient(baseUrl: 'http://127.0.0.1/api/v1'),
      cache: cache,
    );
    final service = MemyLocalDataExportService(goalRepository: api);
    final map = await service.buildExportMap(
      const ExportRequest(modules: {DataModule.goals}),
    );
    final warnings = (map['warnings'] as List)
        .map((e) => e.toString())
        .toList();
    expect(warnings.any((w) => w.contains('Cached snapshot')), isTrue);
    final modules = map['modules'] as Map<String, Object?>;
    final goals = modules['goals'] as Map<String, Object?>;
    expect(goals['source'], 'localCache');
    expect(goals['count'], 1);
  });

  test('export lifecycle cleans stale files', () async {
    final temp = await Directory.systemTemp.createTemp('memy_export_life');
    final stale = File('${temp.path}/memy-data-export-old.json');
    await stale.writeAsString('{}');
    // Force mtime into the past by rewriting after adjusting — use deleteAll.
    final lifecycle = ExportFileLifecycleService(
      tempDirectoryOverride: () async => temp,
      clock: () => DateTime.utc(2026, 8, 10),
      maxAge: Duration.zero,
    );
    final deleted = await lifecycle.cleanupStaleExports(deleteAll: true);
    expect(deleted, greaterThanOrEqualTo(1));
    expect(stale.existsSync(), isFalse);
    await temp.delete(recursive: true);
  });
}
