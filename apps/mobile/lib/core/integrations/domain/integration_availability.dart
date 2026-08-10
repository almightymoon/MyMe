/// Whether an integration can currently be used on this device.
///
/// Distinct from [IntegrationConnectionStatus]: availability describes the
/// *platform*, connection status describes *this app's* link to it.
enum IntegrationAvailability {
  /// Not yet probed.
  unknown,

  /// The underlying platform API is present and permissions can be requested.
  available,

  /// The platform API exists but permission has been permanently denied.
  permissionDenied,

  /// The platform/device does not support this integration at all
  /// (e.g. no calendar provider configured, simulator without HealthKit).
  notSupported,

  /// A transient failure occurred while probing (e.g. plugin channel error).
  unavailable,
}
