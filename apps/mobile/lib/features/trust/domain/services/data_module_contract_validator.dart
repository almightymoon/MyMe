import '../entities/data_catalog.dart';
import '../entities/data_module_id.dart';
import 'data_module_registry.dart';

/// Ensures catalog/export/delete claims match registry capability flags.
///
/// Throws [StateError] when a claimed action is not supported by the
/// descriptor. Intended for assert/tests (and debug self-checks).
class DataModuleContractValidator {
  const DataModuleContractValidator(this.registry);

  final DataModuleRegistry registry;

  void assertSupports(DataModuleId id, DataActionType action) {
    final descriptor = registry.descriptorFor(id);
    if (descriptor == null) {
      throw StateError('Unknown data module: $id');
    }
    if (!descriptor.supports(action)) {
      throw StateError('Module ${id.name} does not support ${action.name}');
    }
  }

  void assertCatalogMatches(DataCatalogEntry entry) {
    final id = _toModuleId(entry.module);
    final descriptor = registry.descriptorFor(id);
    if (descriptor == null) {
      throw StateError('Catalog module ${entry.module} missing from registry');
    }

    if (entry.aiTransfer != descriptor.aiTransfer) {
      throw StateError('aiTransfer mismatch for ${id.name}');
    }
    if (entry.backendTransfer != descriptor.backendTransfer) {
      throw StateError('backendTransfer mismatch for ${id.name}');
    }

    switch (entry.exportCapability) {
      case DataExportCapability.supported:
        if (!descriptor.rawExport && !descriptor.summaryExport) {
          throw StateError('export supported claim invalid for ${id.name}');
        }
      case DataExportCapability.summaryOnly:
        if (!descriptor.summaryExport || descriptor.rawExport) {
          // summaryOnly is valid when summaryExport is true (raw may be false)
          if (!descriptor.summaryExport) {
            throw StateError('summaryOnly export invalid for ${id.name}');
          }
        }
      case DataExportCapability.notSupported:
        if (descriptor.rawExport || descriptor.summaryExport) {
          throw StateError('notSupported export claim invalid for ${id.name}');
        }
      case DataExportCapability.planned:
        break;
    }

    switch (entry.deletionCapability) {
      case DataDeletionCapability.supported:
        if (!descriptor.localRecordDeletion) {
          throw StateError('deletion supported claim invalid for ${id.name}');
        }
      case DataDeletionCapability.cacheClearOnly:
        if (!descriptor.localCacheClear || descriptor.localRecordDeletion) {
          throw StateError('cacheClearOnly claim invalid for ${id.name}');
        }
      case DataDeletionCapability.disconnectOnly:
        if (descriptor.platformDeletion || descriptor.localRecordDeletion) {
          throw StateError('disconnectOnly claim invalid for ${id.name}');
        }
      case DataDeletionCapability.notSupported:
      case DataDeletionCapability.planned:
      case DataDeletionCapability.externalStoreUntouched:
        break;
    }
  }

  void validateAllCatalogEntries(Iterable<DataCatalogEntry> entries) {
    for (final entry in entries) {
      assertCatalogMatches(entry);
    }
  }

  static DataModuleId _toModuleId(DataModule module) => switch (module) {
    DataModule.goals => DataModuleId.goals,
    DataModule.finance => DataModuleId.finance,
    DataModule.habits => DataModuleId.habits,
    DataModule.calendar => DataModuleId.calendar,
    DataModule.health => DataModuleId.health,
    DataModule.profile => DataModuleId.profile,
    DataModule.preferences => DataModuleId.preferences,
    DataModule.diagnostics => DataModuleId.diagnostics,
  };
}
