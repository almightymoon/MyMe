import '../entities/calendar_config.dart';
import '../entities/calendar_event_link.dart';
import '../entities/calendar_sync_conflict.dart';
import '../entities/calendar_sync_operation.dart';
import '../entities/conflict_resolution.dart';
import '../entities/memy_calendar_event.dart';

/// Persistence boundary for calendar events, their external-sync links,
/// unresolved conflicts, push outbox rows, and calendar-integration config.
///
/// Implementations: [FakeCalendarRepository] (in-memory, tests/`fake` mode)
/// and [LocalCalendarRepository] (Drift/SQLite, `system` mode).
abstract class CalendarRepository {
  Stream<List<MemyCalendarEvent>> watchEventsInRange({
    required DateTime startUtc,
    required DateTime endUtc,
    bool includeHidden = false,
  });

  Future<List<MemyCalendarEvent>> getEventsInRange({
    required DateTime startUtc,
    required DateTime endUtc,
    bool includeHidden = false,
  });

  Future<MemyCalendarEvent?> getEvent(String id);

  /// Events awaiting a push (or delete) to their external calendar,
  /// regardless of whether they fall in the currently-displayed range.
  Future<List<MemyCalendarEvent>> getPendingSyncEvents();

  Future<MemyCalendarEvent> createEvent(MemyCalendarEvent event);

  Future<MemyCalendarEvent> updateEvent(MemyCalendarEvent event);

  /// Hard-deletes a local-only event, or soft-deletes (marks `pendingDelete`)
  /// one still linked to an external calendar so the next push can remove
  /// it there too.
  Future<void> deleteEvent(String id);

  /// Copies an imported external event into a new MeMy-owned local event
  /// (no external link). Does not mutate the source.
  Future<MemyCalendarEvent> copyExternalAsLocal(MemyCalendarEvent event);

  Future<CalendarEventLink?> getLinkForEvent(String memyEventId);

  Future<CalendarEventLink?> getLinkByExternalId({
    required String externalCalendarId,
    required String externalEventId,
  });

  Future<CalendarEventLink> saveLink(CalendarEventLink link);

  Future<void> deleteLink(String linkId);

  /// Every link for one external calendar (used to detect external
  /// deletions during pull-sync).
  Future<List<CalendarEventLink>> getLinksForExternalCalendar(
    String externalCalendarId,
  );

  /// All event links (diagnostics / presence counts). Never log link content.
  Future<List<CalendarEventLink>> getAllLinks();

  Stream<List<CalendarSyncConflict>> watchConflicts();

  Future<List<CalendarSyncConflict>> getConflicts();

  Future<CalendarSyncConflict?> getConflict(String id);

  Future<CalendarSyncConflict> addConflict(CalendarSyncConflict conflict);

  Future<void> markConflictResolved({
    required String conflictId,
    required ConflictResolution resolution,
  });

  Future<CalendarConfig> getConfig();

  Future<void> saveConfig(CalendarConfig config);

  // ---------------------------------------------------------------- outbox

  Future<CalendarSyncOperation> saveSyncOperation(CalendarSyncOperation op);

  Future<CalendarSyncOperation?> getSyncOperation(String id);

  Future<List<CalendarSyncOperation>> getInFlightOperations();

  Future<List<CalendarSyncOperation>> getPendingOperations();

  /// All outbox rows for one MeMy event (any state), newest-first optional.
  Future<List<CalendarSyncOperation>> getSyncOperationsForEvent(
    String memyEventId,
  );

  Future<CalendarSyncOperation> updateSyncOperation(CalendarSyncOperation op);

  /// Re-reads persisted state and re-emits every watch stream (used after
  /// out-of-band writes, e.g. a sync pass done outside this instance).
  Future<void> refresh();
}
