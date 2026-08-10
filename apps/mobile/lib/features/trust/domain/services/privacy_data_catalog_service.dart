import '../entities/data_catalog.dart';
import '../entities/data_module_capability.dart';
import '../entities/data_module_id.dart';
import 'data_module_registry.dart';

/// Privacy catalog derived from [DataModuleRegistry] capability flags.
class PrivacyDataCatalogService {
  const PrivacyDataCatalogService(this.registry);

  final DataModuleRegistry registry;

  List<DataCatalogEntry> entries() {
    return registry.descriptors.map(_toEntry).toList(growable: false);
  }

  DataCatalogEntry? entryFor(DataModule module) {
    for (final entry in entries()) {
      if (entry.module == module) return entry;
    }
    return null;
  }

  DataCatalogEntry _toEntry(DataModuleDescriptor d) {
    return DataCatalogEntry(
      module: _toDataModule(d.id),
      title: d.title,
      summary: d.summary,
      storageLocations: _storageFor(d),
      sensitivity: _sensitivityFor(d.id),
      backendTransfer: d.backendTransfer,
      aiTransfer: d.aiTransfer,
      exportCapability: _exportCapability(d),
      deletionCapability: _deletionCapability(d),
      notes: d.notes,
    );
  }

  static DataModule _toDataModule(DataModuleId id) => switch (id) {
    DataModuleId.goals => DataModule.goals,
    DataModuleId.finance => DataModule.finance,
    DataModuleId.habits => DataModule.habits,
    DataModuleId.calendar => DataModule.calendar,
    DataModuleId.health => DataModule.health,
    DataModuleId.profile => DataModule.profile,
    DataModuleId.preferences => DataModule.preferences,
    DataModuleId.diagnostics => DataModule.diagnostics,
  };

  static List<DataStorageLocation> _storageFor(DataModuleDescriptor d) {
    return switch (d.id) {
      DataModuleId.goals => [
        DataStorageLocation.localDevice,
        if (d.backendTransfer) DataStorageLocation.memyBackend,
      ],
      DataModuleId.finance ||
      DataModuleId.habits ||
      DataModuleId.preferences ||
      DataModuleId.profile ||
      DataModuleId.diagnostics => [DataStorageLocation.localDevice],
      DataModuleId.calendar => [
        DataStorageLocation.localDevice,
        DataStorageLocation.deviceCalendar,
      ],
      DataModuleId.health => [
        DataStorageLocation.healthPlatform,
        DataStorageLocation.localDevice,
        DataStorageLocation.memoryOnly,
      ],
    };
  }

  static DataSensitivity _sensitivityFor(DataModuleId id) => switch (id) {
    DataModuleId.finance => DataSensitivity.financial,
    DataModuleId.calendar => DataSensitivity.schedule,
    DataModuleId.health => DataSensitivity.wellness,
    DataModuleId.diagnostics ||
    DataModuleId.preferences => DataSensitivity.operational,
    _ => DataSensitivity.personal,
  };

  static DataExportCapability _exportCapability(DataModuleDescriptor d) {
    if (d.rawExport) return DataExportCapability.supported;
    if (d.summaryExport) return DataExportCapability.summaryOnly;
    return DataExportCapability.notSupported;
  }

  static DataDeletionCapability _deletionCapability(DataModuleDescriptor d) {
    if (d.localRecordDeletion) return DataDeletionCapability.supported;
    if (d.localCacheClear && d.id == DataModuleId.goals) {
      return DataDeletionCapability.cacheClearOnly;
    }
    if (d.id == DataModuleId.health) {
      return DataDeletionCapability.disconnectOnly;
    }
    if (d.localCacheClear) return DataDeletionCapability.cacheClearOnly;
    if (d.id == DataModuleId.profile) return DataDeletionCapability.planned;
    return DataDeletionCapability.notSupported;
  }
}
