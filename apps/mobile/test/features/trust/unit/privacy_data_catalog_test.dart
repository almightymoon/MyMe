import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/config/environment_config.dart';
import 'package:memy/features/trust/domain/entities/data_catalog.dart';
import 'package:memy/features/trust/domain/services/data_module_registry.dart';
import 'package:memy/features/trust/domain/services/privacy_data_catalog_service.dart';

void main() {
  final catalog = PrivacyDataCatalogService(DataModuleRegistry.builtIn());

  test('catalog is derived from registry', () {
    final registry = DataModuleRegistry.builtIn();
    expect(catalog.entries().length, registry.descriptors.length);
    for (final descriptor in registry.descriptors) {
      final match = catalog.entries().where((e) => e.title == descriptor.title);
      expect(match, isNotEmpty);
    }
  });

  test('health aiTransfer is false and export is summary-only', () {
    final health = catalog.entryFor(DataModule.health)!;
    expect(health.aiTransfer, isFalse);
    expect(health.backendTransfer, isFalse);
    expect(health.exportCapability, DataExportCapability.summaryOnly);
    expect(
      health.storageLocations,
      containsAll([
        DataStorageLocation.healthPlatform,
        DataStorageLocation.localDevice,
        DataStorageLocation.memoryOnly,
      ]),
    );
  });

  test('finance has no backend and no AI transfer', () {
    final finance = catalog.entryFor(DataModule.finance)!;
    expect(finance.backendTransfer, isFalse);
    expect(finance.aiTransfer, isFalse);
    expect(finance.storageLocations, [DataStorageLocation.localDevice]);
  });

  test('goals backendTransfer matches GOALS_DATA_SOURCE', () {
    final goals = catalog.entryFor(DataModule.goals)!;
    expect(
      goals.backendTransfer,
      EnvironmentConfig.goalsDataSource == GoalsDataSource.api,
    );
  });
}
