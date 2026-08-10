import '../entities/deletion_scope.dart';
import '../entities/export_request.dart';

/// Result of exporting one module's local records.
class ModuleExportResult {
  const ModuleExportResult({
    required this.moduleKey,
    required this.recordCount,
    required this.payload,
    this.warnings = const [],
  });

  final String moduleKey;
  final int recordCount;
  final Map<String, Object?> payload;
  final List<String> warnings;
}

/// Result of a single module deletion / cache / disconnect action.
class ModuleDeletionResult {
  const ModuleDeletionResult({
    required this.moduleKey,
    required this.deletedRecordCount,
    this.userSafeMessage,
  });

  final String moduleKey;
  final int deletedRecordCount;
  final String? userSafeMessage;
}

/// Exports MeMy-owned local records for a module.
abstract interface class LocalRecordExporter {
  Future<ModuleExportResult> exportLocalRecords({ExportRequest? request});
}

/// Deletes MeMy-owned durable local records (not backend / platform).
abstract interface class LocalRecordDeleter {
  Future<ModuleDeletionResult> deleteLocalRecords();
}

/// Clears an on-device cache without deleting authoritative backend records.
abstract interface class LocalCacheClearer {
  Future<ModuleDeletionResult> clearLocalCache();
}

/// Disconnects / resets MeMy integration configuration.
abstract interface class IntegrationDisconnector {
  Future<ModuleDeletionResult> disconnectIntegration();
}

/// Deletes records stored on a MeMy backend.
///
/// Must never be resolved by local-data deletion flows.
abstract interface class BackendRecordDeleter {
  Future<ModuleDeletionResult> deleteBackendRecords();
}

/// Deletes records owned by an external platform (device calendar, Health).
///
/// Must never be included in general local MeMy wipe plans.
abstract interface class ExternalRecordDeleter {
  Future<ModuleDeletionResult> deleteExternalRecords();
}

/// Marker for scopes that are forbidden in [DeletionScope.allLocalMeMyData].
abstract final class LocalWipeExclusions {
  static const forbiddenScopes = {DeletionScope.calendarDeviceEvents};
}
