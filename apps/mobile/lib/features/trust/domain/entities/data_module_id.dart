/// Stable identifiers for modules that store or touch user data.
enum DataModuleId {
  goals,
  finance,
  habits,
  calendar,
  health,
  profile,
  preferences,
  diagnostics,
}

/// Capability / action kinds used by the data-module registry and validators.
enum DataActionType {
  rawExport,
  summaryExport,
  localRecordDeletion,
  localCacheClear,
  backendDeletion,
  platformDeletion,
  deviceEventDeletion,
  aiTransfer,
  backendTransfer,
}
