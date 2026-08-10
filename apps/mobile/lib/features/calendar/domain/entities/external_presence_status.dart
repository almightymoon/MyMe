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

  /// Direct ID lookup failed — cannot confirm absence; do not tombstone.
  lookupUnknown,

  /// Imported external event confirmed deleted on device (hidden locally).
  hiddenAfterExternalDeletion,

  /// MeMy-owned linked event confirmed missing on device.
  externallyMissingMeMyOwned,

  /// Provider/permission temporarily unavailable — do not advance missing.
  providerUnavailable,
}
