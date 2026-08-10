import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../domain/entities/calendar_config.dart';
import '../../domain/entities/calendar_event_link.dart' as domain;
import '../../domain/entities/calendar_event_origin.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/calendar_event_time.dart';
import '../../domain/entities/calendar_sync_conflict.dart' as domain;
import '../../domain/entities/conflict_resolution.dart';
import '../../domain/entities/external_event_snapshot.dart';
import '../../domain/entities/memy_calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../local/calendar_database.dart' as db;

/// Drift/SQLite-backed [CalendarRepository] — the durable event cache.
///
/// Never uses SharedPreferences: calendar content lives exclusively in the
/// `memy_calendar` SQLite database so it scales past what a JSON blob can
/// hold and supports real range queries.
class LocalCalendarRepository implements CalendarRepository {
  LocalCalendarRepository({
    required this.database,
    AppClock? clock,
    this._idGenerator,
  }) : _clock = clock ?? const SystemAppClock();

  final db.CalendarDatabase database;
  final AppClock _clock;
  final String Function()? _idGenerator;

  String _newId(String prefix) =>
      _idGenerator?.call() ??
      '${prefix}_${_clock.now().microsecondsSinceEpoch}';

  // ---------------------------------------------------------------- events

  @override
  Stream<List<MemyCalendarEvent>> watchEventsInRange({
    required DateTime startUtc,
    required DateTime endUtc,
  }) {
    final query = database.select(database.calendarEvents)
      ..where(
        (t) =>
            t.deletedAtUtc.isNull() &
            t.startUtc.isSmallerThanValue(endUtc) &
            t.endUtc.isBiggerThanValue(startUtc),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.startUtc)]);
    return query.watch().map(
      (rows) => rows.map(_eventFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<MemyCalendarEvent>> getEventsInRange({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final query = database.select(database.calendarEvents)
      ..where(
        (t) =>
            t.deletedAtUtc.isNull() &
            t.startUtc.isSmallerThanValue(endUtc) &
            t.endUtc.isBiggerThanValue(startUtc),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.startUtc)]);
    final rows = await query.get();
    return rows.map(_eventFromRow).toList(growable: false);
  }

  @override
  Future<MemyCalendarEvent?> getEvent(String id) async {
    final row = await (database.select(
      database.calendarEvents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _eventFromRow(row);
  }

  @override
  Future<List<MemyCalendarEvent>> getPendingSyncEvents() async {
    final query = database.select(database.calendarEvents)
      ..where(
        (t) =>
            t.syncStatus.equals(CalendarEventSyncStatus.pendingPush.name) |
            t.syncStatus.equals(CalendarEventSyncStatus.pendingDelete.name),
      );
    final rows = await query.get();
    return rows.map(_eventFromRow).toList(growable: false);
  }

  @override
  Future<MemyCalendarEvent> createEvent(MemyCalendarEvent event) async {
    final withId = event.id.isEmpty ? event.copyWith() : event;
    final prepared = withId.id.isEmpty
        ? _withGeneratedId(withId, _newId('cal_evt'))
        : withId;
    await database
        .into(database.calendarEvents)
        .insertOnConflictUpdate(_eventToCompanion(prepared));
    return prepared;
  }

  MemyCalendarEvent _withGeneratedId(MemyCalendarEvent event, String id) {
    return MemyCalendarEvent(
      id: id,
      title: event.title,
      notes: event.notes,
      location: event.location,
      time: event.time,
      origin: event.origin,
      syncStatus: event.syncStatus,
      provider: event.provider,
      externalCalendarId: event.externalCalendarId,
      externalEventId: event.externalEventId,
      reminderMinutes: event.reminderMinutes,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      deletedAt: event.deletedAt,
      version: event.version,
    );
  }

  @override
  Future<MemyCalendarEvent> updateEvent(MemyCalendarEvent event) async {
    await database
        .into(database.calendarEvents)
        .insertOnConflictUpdate(_eventToCompanion(event));
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await (database.delete(
      database.calendarEvents,
    )..where((t) => t.id.equals(id))).go();
  }

  MemyCalendarEvent _eventFromRow(db.CalendarEvent row) {
    return MemyCalendarEvent(
      id: row.id,
      title: row.title,
      notes: row.notes,
      location: row.location,
      time: calendarEventTimeFromStorage(
        isAllDay: row.isAllDay,
        startUtc: row.startUtc,
        endUtc: row.endUtc,
        timezoneName: row.timezoneName,
      ),
      origin: CalendarEventOrigin.values.byName(row.origin),
      syncStatus: CalendarEventSyncStatus.values.byName(row.syncStatus),
      provider: row.externalProvider == null
          ? null
          : IntegrationProvider.values.byName(row.externalProvider!),
      externalCalendarId: row.externalCalendarId,
      externalEventId: row.externalEventId,
      reminderMinutes: (jsonDecode(row.reminderMinutesJson) as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(growable: false),
      createdAt: row.createdAtUtc,
      updatedAt: row.updatedAtUtc,
      deletedAt: row.deletedAtUtc,
      version: row.version,
    );
  }

  db.CalendarEventsCompanion _eventToCompanion(MemyCalendarEvent event) {
    return db.CalendarEventsCompanion(
      id: Value(event.id),
      title: Value(event.title),
      notes: Value(event.notes),
      location: Value(event.location),
      startUtc: Value(event.time.startUtc),
      endUtc: Value(event.time.endUtc),
      isAllDay: Value(event.time.isAllDay),
      timezoneName: Value(
        event.time is TimedCalendarEventTime
            ? (event.time as TimedCalendarEventTime).timezoneName
            : null,
      ),
      origin: Value(event.origin.name),
      syncStatus: Value(event.syncStatus.name),
      externalProvider: Value(event.provider?.name),
      externalCalendarId: Value(event.externalCalendarId),
      externalEventId: Value(event.externalEventId),
      reminderMinutesJson: Value(jsonEncode(event.reminderMinutes)),
      version: Value(event.version),
      createdAtUtc: Value(event.createdAt),
      updatedAtUtc: Value(event.updatedAt),
      deletedAtUtc: Value(event.deletedAt),
    );
  }

  // ----------------------------------------------------------------- links

  @override
  Future<domain.CalendarEventLink?> getLinkForEvent(String memyEventId) async {
    final row = await (database.select(
      database.calendarEventLinks,
    )..where((t) => t.memyEventId.equals(memyEventId))).getSingleOrNull();
    return row == null ? null : _linkFromRow(row);
  }

  @override
  Future<domain.CalendarEventLink?> getLinkByExternalId({
    required String externalCalendarId,
    required String externalEventId,
  }) async {
    final row =
        await (database.select(database.calendarEventLinks)..where(
              (t) =>
                  t.externalCalendarId.equals(externalCalendarId) &
                  t.externalEventId.equals(externalEventId),
            ))
            .getSingleOrNull();
    return row == null ? null : _linkFromRow(row);
  }

  @override
  Future<domain.CalendarEventLink> saveLink(
    domain.CalendarEventLink link,
  ) async {
    await database
        .into(database.calendarEventLinks)
        .insertOnConflictUpdate(_linkToCompanion(link));
    return link;
  }

  @override
  Future<void> deleteLink(String linkId) async {
    await (database.delete(
      database.calendarEventLinks,
    )..where((t) => t.id.equals(linkId))).go();
  }

  @override
  Future<List<domain.CalendarEventLink>> getLinksForExternalCalendar(
    String externalCalendarId,
  ) async {
    final rows = await (database.select(
      database.calendarEventLinks,
    )..where((t) => t.externalCalendarId.equals(externalCalendarId))).get();
    return rows.map(_linkFromRow).toList(growable: false);
  }

  domain.CalendarEventLink _linkFromRow(db.CalendarEventLink row) {
    return domain.CalendarEventLink(
      id: row.id,
      memyEventId: row.memyEventId,
      provider: IntegrationProvider.values.byName(row.provider),
      externalCalendarId: row.externalCalendarId,
      externalEventId: row.externalEventId,
      lastSyncedAt: row.lastSyncedAtUtc,
      lastKnownExternalUpdatedAt: row.lastKnownExternalUpdatedAtUtc,
    );
  }

  db.CalendarEventLinksCompanion _linkToCompanion(
    domain.CalendarEventLink link,
  ) {
    return db.CalendarEventLinksCompanion(
      id: Value(link.id),
      memyEventId: Value(link.memyEventId),
      provider: Value(link.provider.name),
      externalCalendarId: Value(link.externalCalendarId),
      externalEventId: Value(link.externalEventId),
      lastSyncedAtUtc: Value(link.lastSyncedAt),
      lastKnownExternalUpdatedAtUtc: Value(link.lastKnownExternalUpdatedAt),
      createdAtUtc: Value(_clock.now().toUtc()),
    );
  }

  // ------------------------------------------------------------- conflicts

  @override
  Stream<List<domain.CalendarSyncConflict>> watchConflicts() {
    final query = database.select(database.calendarConflicts)
      ..where((t) => t.resolvedAtUtc.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.detectedAtUtc)]);
    return query.watch().map(
      (rows) => rows.map(_conflictFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<domain.CalendarSyncConflict>> getConflicts() async {
    final query = database.select(database.calendarConflicts)
      ..where((t) => t.resolvedAtUtc.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.detectedAtUtc)]);
    final rows = await query.get();
    return rows.map(_conflictFromRow).toList(growable: false);
  }

  @override
  Future<domain.CalendarSyncConflict?> getConflict(String id) async {
    final row = await (database.select(
      database.calendarConflicts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _conflictFromRow(row);
  }

  @override
  Future<domain.CalendarSyncConflict> addConflict(
    domain.CalendarSyncConflict conflict,
  ) async {
    await database
        .into(database.calendarConflicts)
        .insertOnConflictUpdate(_conflictToCompanion(conflict));
    return conflict;
  }

  @override
  Future<void> markConflictResolved({
    required String conflictId,
    required ConflictResolution resolution,
  }) async {
    await (database.update(
      database.calendarConflicts,
    )..where((t) => t.id.equals(conflictId))).write(
      db.CalendarConflictsCompanion(
        resolvedAtUtc: Value(_clock.now().toUtc()),
        resolution: Value(resolution.name),
      ),
    );
  }

  domain.CalendarSyncConflict _conflictFromRow(db.CalendarConflict row) {
    final localJson = jsonDecode(row.localSnapshotJson) as Map<String, dynamic>;
    final externalJson =
        jsonDecode(row.externalSnapshotJson) as Map<String, dynamic>;
    return domain.CalendarSyncConflict(
      id: row.id,
      memyEventId: row.memyEventId,
      linkId: row.linkId,
      localSnapshot: MemyCalendarEvent.fromJson(localJson),
      externalSnapshot: ExternalEventSnapshot.fromJson(externalJson),
      detectedAt: row.detectedAtUtc,
      resolvedAt: row.resolvedAtUtc,
      resolution: row.resolution == null
          ? null
          : ConflictResolution.values.byName(row.resolution!),
    );
  }

  db.CalendarConflictsCompanion _conflictToCompanion(
    domain.CalendarSyncConflict conflict,
  ) {
    return db.CalendarConflictsCompanion(
      id: Value(conflict.id),
      memyEventId: Value(conflict.memyEventId),
      linkId: Value(conflict.linkId),
      localSnapshotJson: Value(jsonEncode(conflict.localSnapshot.toJson())),
      externalSnapshotJson: Value(
        jsonEncode(conflict.externalSnapshot.toJson()),
      ),
      detectedAtUtc: Value(conflict.detectedAt),
      resolvedAtUtc: Value(conflict.resolvedAt),
      resolution: Value(conflict.resolution?.name),
    );
  }

  // ---------------------------------------------------------------- config

  static const int _configRowId = 0;

  @override
  Future<CalendarConfig> getConfig() async {
    final row = await (database.select(
      database.calendarConfigRows,
    )..where((t) => t.id.equals(_configRowId))).getSingleOrNull();
    if (row == null) return const CalendarConfig();
    return CalendarConfig(
      selectedCalendarIds: (jsonDecode(row.selectedCalendarIdsJson) as List)
          .map((e) => e as String)
          .toList(growable: false),
      lastFullSyncAt: row.lastFullSyncAtUtc?.toUtc(),
      initialSyncAnchorPast: row.initialSyncAnchorPastUtc?.toUtc(),
      initialSyncAnchorFuture: row.initialSyncAnchorFutureUtc?.toUtc(),
    );
  }

  @override
  Future<void> saveConfig(CalendarConfig config) async {
    await database
        .into(database.calendarConfigRows)
        .insertOnConflictUpdate(
          db.CalendarConfigRowsCompanion(
            id: const Value(_configRowId),
            selectedCalendarIdsJson: Value(
              jsonEncode(config.selectedCalendarIds),
            ),
            lastFullSyncAtUtc: Value(config.lastFullSyncAt?.toUtc()),
            initialSyncAnchorPastUtc: Value(
              config.initialSyncAnchorPast?.toUtc(),
            ),
            initialSyncAnchorFutureUtc: Value(
              config.initialSyncAnchorFuture?.toUtc(),
            ),
          ),
        );
  }

  @override
  Future<void> refresh() async {
    // Drift streams re-query reactively on writes to the same connection;
    // nothing to do when reads/writes share this instance's connection.
  }
}
