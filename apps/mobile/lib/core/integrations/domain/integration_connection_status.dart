/// Lifecycle of this app's link to an [IntegrationProvider].
enum IntegrationConnectionStatus {
  /// User has never connected, or explicitly disconnected.
  notConnected,

  /// Connection flow (permission request / calendar selection) in progress.
  connecting,

  /// Connected and eligible to sync.
  connected,

  /// Readable import works but writable destination is missing/invalid.
  partiallyConnected,

  /// Durable config exists and cached data may show, but live provider check failed.
  staleCacheAvailable,

  /// Platform reports the provider is unavailable on this device.
  providerUnavailable,

  /// Permission state could not be determined.
  permissionStatusUnknown,

  /// Persisted configuration is invalid (e.g. missing writable calendar).
  configurationInvalid,

  /// A sync/refresh is actively running.
  syncing,

  /// Connection attempt failed; see `IntegrationConnection.lastError`.
  error,
}

extension IntegrationConnectionStatusX on IntegrationConnectionStatus {
  /// Live provider operations (pull/push) are allowed.
  bool get allowsLiveSync =>
      this == IntegrationConnectionStatus.connected ||
      this == IntegrationConnectionStatus.partiallyConnected ||
      this == IntegrationConnectionStatus.syncing;

  /// Cached agenda may be shown (possibly stale).
  bool get showsCachedAgenda =>
      allowsLiveSync || this == IntegrationConnectionStatus.staleCacheAvailable;

  /// Must not be reported as a healthy live connection.
  bool get isDegraded =>
      this == IntegrationConnectionStatus.staleCacheAvailable ||
      this == IntegrationConnectionStatus.providerUnavailable ||
      this == IntegrationConnectionStatus.permissionStatusUnknown ||
      this == IntegrationConnectionStatus.configurationInvalid ||
      this == IntegrationConnectionStatus.partiallyConnected ||
      this == IntegrationConnectionStatus.error;
}
