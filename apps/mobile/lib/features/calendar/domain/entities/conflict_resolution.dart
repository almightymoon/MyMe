/// How a user chooses to settle a [CalendarSyncConflict].
enum ConflictResolution {
  /// Overwrite the external event with MeMy's local version on next push.
  keepLocal,

  /// Overwrite the local event with the external version.
  keepExternal,

  /// Keep the external version linked/synced, and preserve the local
  /// edits as a new, separate, unlinked local event.
  keepBoth,
}
