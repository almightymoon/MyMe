/// Where a [MemyCalendarEvent] stands relative to its linked external event.
enum CalendarEventSyncStatus {
  /// Never linked to an external calendar and never will be pushed
  /// automatically (default for events created while disconnected).
  localOnly,

  /// Has local changes not yet written to the external calendar.
  pendingPush,

  /// Matches the linked external event as of the last sync.
  synced,

  /// Marked for deletion locally; the external event still needs removing.
  pendingDelete,

  /// Local and external versions diverged since the last sync — see
  /// [CalendarSyncConflict] for both snapshots.
  conflict,

  /// External event is confirmed missing; local row retained as a tombstone
  /// or recoverable MeMy-owned event (never auto-hard-deleted).
  externallyMissing,

  /// Imported external event hidden from MeMy after confirmed deletion.
  hidden,
}
