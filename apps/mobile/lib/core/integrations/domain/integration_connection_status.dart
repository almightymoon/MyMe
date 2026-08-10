/// Lifecycle of this app's link to an [IntegrationProvider].
enum IntegrationConnectionStatus {
  /// User has never connected, or explicitly disconnected.
  notConnected,

  /// Connection flow (permission request / calendar selection) in progress.
  connecting,

  /// Connected and eligible to sync.
  connected,

  /// Connection attempt failed; see `IntegrationConnection.lastError`.
  error,
}
