/// Whether a linked external event still appears to exist on the device.
///
/// Absence is never inferred from a single partial/unknown read.
enum ExternalPresenceStatus {
  /// Seen in the latest complete pull batch (or never observed missing).
  present,

  /// Missing from at least one complete in-range batch; awaiting confirm.
  suspectedMissing,

  /// Missing from repeated complete observations (or direct ID lookup).
  confirmedMissing,

  /// Provider/permission temporarily unavailable — do not advance missing.
  providerUnavailable,
}
