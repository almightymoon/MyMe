/// Product modules that store or touch user data.
enum DataModule {
  goals,
  finance,
  habits,
  calendar,
  health,
  profile,
  preferences,
  diagnostics,
}

/// Where data lives relative to the MeMy app process.
enum DataStorageLocation {
  /// SharedPreferences / Drift / files owned by MeMy on this device.
  localDevice,

  /// HealthKit / Health Connect (platform store of truth).
  healthPlatform,

  /// Device calendar provider (EventKit / Android Calendar).
  deviceCalendar,

  /// Optional MeMy API when Goals are in `api` mode.
  memyBackend,

  /// In-memory only for the current session (cleared on process death).
  memoryOnly,
}

enum DataSensitivity { operational, personal, financial, schedule, wellness }

enum DataExportCapability { supported, summaryOnly, notSupported, planned }

enum DataDeletionCapability {
  supported,
  disconnectOnly,
  notSupported,
  planned,
  externalStoreUntouched,
}

/// One row in the privacy data catalog — must match real app behavior.
class DataCatalogEntry {
  const DataCatalogEntry({
    required this.module,
    required this.title,
    required this.summary,
    required this.storageLocations,
    required this.sensitivity,
    required this.backendTransfer,
    required this.aiTransfer,
    required this.exportCapability,
    required this.deletionCapability,
    this.notes = const [],
  });

  final DataModule module;
  final String title;
  final String summary;
  final List<DataStorageLocation> storageLocations;
  final DataSensitivity sensitivity;

  /// True only when this module may send content to MeMy API in current build.
  final bool backendTransfer;

  /// True only when this module may send content to an AI provider.
  final bool aiTransfer;

  final DataExportCapability exportCapability;
  final DataDeletionCapability deletionCapability;
  final List<String> notes;
}
