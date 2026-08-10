import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../domain/entities/calendar_config.dart';
import '../../domain/entities/calendar_create_recovery_case.dart';
import '../../domain/entities/calendar_event_lookup_result.dart';
import '../../domain/entities/calendar_event_link.dart' as domain;
import '../../domain/entities/calendar_event_origin.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/calendar_event_time.dart';
import '../../domain/entities/calendar_mutation_exception.dart';
import '../../domain/entities/calendar_sync_conflict.dart' as domain;
import '../../domain/entities/calendar_sync_operation.dart';
import '../../domain/entities/conflict_resolution.dart';
import '../../domain/entities/external_event_snapshot.dart';
import '../../domain/entities/external_presence_status.dart';
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

  Expression<bool> _notHidden(db.$CalendarEventsTable t) {
    return t.syncStatus.isNotValue(CalendarEventSyncStatus.hidden.name) &
        t.syncStatus.isNotValue(CalendarEventSyncStatus.externallyMissing.name);
  }

  @override
  Stream<List<MemyCalendarEvent>> watchEventsInRange({
    required DateTime startUtc,
    required DateTime endUtc,
    bool includeHidden = false,
  }) {
    final query = database.select(database.calendarEvents)
      ..where(
        (t) =>
            t.deletedAtUtc.isNull() &
            t.startUtc.isSmallerThanValue(endUtc) &
            t.endUtc.isBiggerThanValue(startUtc) &
            (includeHidden ? const Constant(true) : _notHidden(t)),
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
    bool includeHidden = false,
  }) async {
    final query = database.select(database.calendarEvents)
      ..where(
        (t) =>
            t.deletedAtUtc.isNull() &
            t.startUtc.isSmallerThanValue(endUtc) &
            t.endUtc.isBiggerThanValue(startUtc) &
            (includeHidden ? const Constant(true) : _notHidden(t)),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.startUtc)]);
    final rows = await query.get();
    return rows.map(_eventFromRow).toList(growable: false);
  }

  @override
  Future<List<MemyCalendarEvent>> getAllMeMyOwnedEvents() async {
    final query = database.select(database.calendarEvents)
      ..where(
        (t) =>
            t.deletedAtUtc.isNull() &
            t.origin.equals(CalendarEventOrigin.local.name),
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
    final existing = await getEvent(event.id);
    if (existing != null &&
        existing.origin == CalendarEventOrigin.external &&
        (event.syncStatus == CalendarEventSyncStatus.pendingPush ||
            event.syncStatus == CalendarEventSyncStatus.pendingDelete)) {
      throw const CalendarMutationException(
        'Imported calendar events are read-only. Copy to MeMy to edit.',
      );
    }
    await database
        .into(database.calendarEvents)
        .insertOnConflictUpdate(_eventToCompanion(event));
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    final existing = await getEvent(id);
    if (existing != null && existing.origin == CalendarEventOrigin.external) {
      throw const CalendarMutationException(
        'Imported calendar events are read-only. Copy to MeMy to edit.',
      );
    }
    await (database.delete(
      database.calendarEvents,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<MemyCalendarEvent> copyExternalAsLocal(MemyCalendarEvent event) async {
    final now = _clock.now().toUtc();
    final copy = MemyCalendarEvent(
      id: _newId('cal_evt'),
      title: event.title,
      notes: event.notes,
      location: event.location,
      time: event.time,
      origin: CalendarEventOrigin.local,
      syncStatus: CalendarEventSyncStatus.pendingPush,
      reminderMinutes: event.reminderMinutes,
      createdAt: now,
      updatedAt: now,
    );
    return createEvent(copy);
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

  @override
  Future<List<domain.CalendarEventLink>> getAllLinks() async {
    final rows = await database.select(database.calendarEventLinks).get();
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
      presence: ExternalPresenceStatus.values.byName(row.presenceStatus),
      lastSeenExternallyAt: row.lastSeenExternallyAtUtc,
      firstMissingObservationAt: row.firstMissingObservationAtUtc,
      lastMissingObservationAt: row.lastMissingObservationAtUtc,
      missingObservationCount: row.missingObservationCount,
      lastCompleteQueryStart: row.lastCompleteQueryStartUtc,
      lastCompleteQueryEnd: row.lastCompleteQueryEndUtc,
      hiddenLocally: row.hiddenLocally,
      memyMarker: row.memyMarker,
      lastVerifiedLookupAt: row.lastVerifiedLookupAtUtc,
      lastLookupDisposition: row.lastLookupDisposition == null
          ? null
          : CalendarEventLookupDisposition.values.byName(
              row.lastLookupDisposition!,
            ),
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
      presenceStatus: Value(link.presence.name),
      lastSeenExternallyAtUtc: Value(link.lastSeenExternallyAt),
      firstMissingObservationAtUtc: Value(link.firstMissingObservationAt),
      lastMissingObservationAtUtc: Value(link.lastMissingObservationAt),
      missingObservationCount: Value(link.missingObservationCount),
      lastCompleteQueryStartUtc: Value(link.lastCompleteQueryStart),
      lastCompleteQueryEndUtc: Value(link.lastCompleteQueryEnd),
      hiddenLocally: Value(link.hiddenLocally),
      memyMarker: Value(link.memyMarker),
      lastVerifiedLookupAtUtc: Value(link.lastVerifiedLookupAt),
      lastLookupDisposition: Value(link.lastLookupDisposition?.name),
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

    final selected = (jsonDecode(row.selectedCalendarIdsJson) as List)
        .map((e) => e.toString())
        .toList(growable: false);
    var readable = (jsonDecode(row.readableCalendarIdsJson) as List)
        .map((e) => e.toString())
        .toList(growable: false);
    if (readable.isEmpty && selected.isNotEmpty) {
      readable = selected;
    }

    return CalendarConfig(
      readableCalendarIds: readable,
      selectedCalendarIds: readable,
      defaultWritableCalendarId: row.defaultWritableCalendarId,
      dedicatedMeMyCalendarId: row.dedicatedMeMyCalendarId,
      syncPastWindowDays: row.syncPastWindowDays,
      syncFutureWindowDays: row.syncFutureWindowDays,
      calendarSchemaVersion: row.calendarSchemaVersion,
      lastFullSyncAt: row.lastFullSyncAtUtc?.toUtc(),
      lastSuccessfulPullAt: row.lastSuccessfulPullAtUtc?.toUtc(),
      lastSuccessfulPushAt: row.lastSuccessfulPushAtUtc?.toUtc(),
      lastPermissionCheckAt: row.lastPermissionCheckAtUtc?.toUtc(),
      lastCalendarDiscoveryAt: row.lastCalendarDiscoveryAtUtc?.toUtc(),
      connectionConfiguredAt: row.connectionConfiguredAtUtc?.toUtc(),
      initialSyncAnchorPast: row.initialSyncAnchorPastUtc?.toUtc(),
      initialSyncAnchorFuture: row.initialSyncAnchorFutureUtc?.toUtc(),
    );
  }

  @override
  Future<void> saveConfig(CalendarConfig config) async {
    final readable = config.effectiveReadableCalendarIds;
    await database
        .into(database.calendarConfigRows)
        .insertOnConflictUpdate(
          db.CalendarConfigRowsCompanion(
            id: const Value(_configRowId),
            selectedCalendarIdsJson: Value(jsonEncode(readable)),
            readableCalendarIdsJson: Value(jsonEncode(readable)),
            defaultWritableCalendarId: Value(config.defaultWritableCalendarId),
            dedicatedMeMyCalendarId: Value(config.dedicatedMeMyCalendarId),
            syncPastWindowDays: Value(config.syncPastWindowDays),
            syncFutureWindowDays: Value(config.syncFutureWindowDays),
            calendarSchemaVersion: Value(CalendarConfig.currentSchemaVersion),
            lastFullSyncAtUtc: Value(config.lastFullSyncAt?.toUtc()),
            lastSuccessfulPullAtUtc: Value(
              config.lastSuccessfulPullAt?.toUtc(),
            ),
            lastSuccessfulPushAtUtc: Value(
              config.lastSuccessfulPushAt?.toUtc(),
            ),
            lastPermissionCheckAtUtc: Value(
              config.lastPermissionCheckAt?.toUtc(),
            ),
            lastCalendarDiscoveryAtUtc: Value(
              config.lastCalendarDiscoveryAt?.toUtc(),
            ),
            connectionConfiguredAtUtc: Value(
              config.connectionConfiguredAt?.toUtc(),
            ),
            initialSyncAnchorPastUtc: Value(
              config.initialSyncAnchorPast?.toUtc(),
            ),
            initialSyncAnchorFutureUtc: Value(
              config.initialSyncAnchorFuture?.toUtc(),
            ),
          ),
        );
  }

  // ---------------------------------------------------------------- outbox

  @override
  Future<CalendarSyncOperation> saveSyncOperation(
    CalendarSyncOperation op,
  ) async {
    await database
        .into(database.calendarSyncOperations)
        .insertOnConflictUpdate(_opToCompanion(op));
    return op;
  }

  @override
  Future<CalendarSyncOperation?> getSyncOperation(String id) async {
    final row = await (database.select(
      database.calendarSyncOperations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _opFromRow(row);
  }

  @override
  Future<List<CalendarSyncOperation>> getInFlightOperations() async {
    final rows =
        await (database.select(database.calendarSyncOperations)..where(
              (t) => t.state.equals(CalendarSyncOperationState.inFlight.name),
            ))
            .get();
    return rows.map(_opFromRow).toList(growable: false);
  }

  @override
  Future<List<CalendarSyncOperation>> getPendingOperations() async {
    final rows =
        await (database.select(database.calendarSyncOperations)..where(
              (t) =>
                  t.state.equals(CalendarSyncOperationState.prepared.name) |
                  t.state.equals(
                    CalendarSyncOperationState.retryableFailure.name,
                  ),
            ))
            .get();
    return rows.map(_opFromRow).toList(growable: false);
  }

  @override
  Future<List<CalendarSyncOperation>> getSyncOperationsForEvent(
    String memyEventId,
  ) async {
    final rows = await (database.select(
      database.calendarSyncOperations,
    )..where((t) => t.memyEventId.equals(memyEventId))).get();
    return rows.map(_opFromRow).toList(growable: false);
  }

  @override
  Future<CalendarSyncOperation> updateSyncOperation(
    CalendarSyncOperation op,
  ) async {
    await database
        .into(database.calendarSyncOperations)
        .insertOnConflictUpdate(_opToCompanion(op));
    return op;
  }

  CalendarSyncOperation _opFromRow(db.CalendarSyncOperation row) {
    return CalendarSyncOperation(
      id: row.id,
      memyEventId: row.memyEventId,
      operationType: CalendarSyncOperationType.values.byName(row.operationType),
      targetCalendarId: row.targetCalendarId,
      payloadFingerprint: row.payloadFingerprint,
      state: CalendarSyncOperationState.values.byName(row.state),
      attemptCount: row.attemptCount,
      providerExternalEventId: row.providerExternalEventId,
      createdAt: row.createdAtUtc,
      startedAt: row.startedAtUtc,
      completedAt: row.completedAtUtc,
      nextRetryAt: row.nextRetryAtUtc,
      lastErrorCode: row.lastErrorCode,
      memyMarker: row.memyMarker,
    );
  }

  db.CalendarSyncOperationsCompanion _opToCompanion(CalendarSyncOperation op) {
    return db.CalendarSyncOperationsCompanion(
      id: Value(op.id),
      memyEventId: Value(op.memyEventId),
      operationType: Value(op.operationType.name),
      targetCalendarId: Value(op.targetCalendarId),
      payloadFingerprint: Value(op.payloadFingerprint),
      state: Value(op.state.name),
      attemptCount: Value(op.attemptCount),
      providerExternalEventId: Value(op.providerExternalEventId),
      memyMarker: Value(op.memyMarker),
      createdAtUtc: Value(op.createdAt),
      startedAtUtc: Value(op.startedAt),
      completedAtUtc: Value(op.completedAt),
      nextRetryAtUtc: Value(op.nextRetryAt),
      lastErrorCode: Value(op.lastErrorCode),
    );
  }

  @override
  Future<void> refresh() async {
    // Drift streams re-query reactively on writes to the same connection;
    // nothing to do when reads/writes share this instance's connection.
  }

  // ----------------------------------------------------------- recovery

  @override
  Future<CalendarCreateRecoveryCase> saveRecoveryCase(
    CalendarCreateRecoveryCase recoveryCase,
  ) async {
    await database
        .into(database.calendarCreateRecoveryCases)
        .insertOnConflictUpdate(_recoveryToCompanion(recoveryCase));
    return recoveryCase;
  }

  @override
  Future<CalendarCreateRecoveryCase?> getRecoveryCase(String id) async {
    final row = await (database.select(
      database.calendarCreateRecoveryCases,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _recoveryFromRow(row);
  }

  @override
  Future<List<CalendarCreateRecoveryCase>> getUnresolvedRecoveryCases() async {
    final rows =
        await (database.select(database.calendarCreateRecoveryCases)..where(
              (t) =>
                  t.status.equals(CalendarCreateRecoveryStatus.unresolved.name),
            ))
            .get();
    return rows.map(_recoveryFromRow).toList(growable: false);
  }

  @override
  Future<List<CalendarCreateRecoveryCase>> getRecoveryCasesForOperation(
    String syncOperationId,
  ) async {
    final rows = await (database.select(
      database.calendarCreateRecoveryCases,
    )..where((t) => t.syncOperationId.equals(syncOperationId))).get();
    return rows.map(_recoveryFromRow).toList(growable: false);
  }

  @override
  Future<CalendarCreateRecoveryCase> updateRecoveryCase(
    CalendarCreateRecoveryCase recoveryCase,
  ) async {
    await database
        .into(database.calendarCreateRecoveryCases)
        .insertOnConflictUpdate(_recoveryToCompanion(recoveryCase));
    return recoveryCase;
  }

  /// Clears MeMy's local calendar cache tables.
  ///
  /// Never touches the device calendar provider. When
  /// [includeMeMyOwnedEvents] is false, only external-origin events and
  /// their related links are removed — connection config is preserved.
  /// When true, clears both imported and MeMy-owned events (and related
  /// sync metadata) but still does **not** wipe [calendarConfigRows]; use
  /// [resetIntegrationConfig] for that.
  Future<({int events, int links, int conflicts, int ops})> clearLocalCache({
    required bool includeMeMyOwnedEvents,
  }) async {
    if (includeMeMyOwnedEvents) {
      final imported = await clearImportedCache();
      final owned = await clearMeMyLocalRecords();
      return (
        events: imported.events + owned.events,
        links: imported.links + owned.links,
        conflicts: imported.conflicts + owned.conflicts,
        ops: imported.ops + owned.ops,
      );
    }
    return clearImportedCache();
  }

  /// Deletes imported external-origin events and links for those events.
  /// Preserves MeMy-authored local events and calendar connection config.
  Future<({int events, int links, int conflicts, int ops})>
  clearImportedCache() async {
    final eventsBefore = await database.select(database.calendarEvents).get();
    final externalIds = eventsBefore
        .where((e) => e.origin == CalendarEventOrigin.external.name)
        .map((e) => e.id)
        .toSet();

    final linksBefore = await database
        .select(database.calendarEventLinks)
        .get();
    final conflictsBefore = await database
        .select(database.calendarConflicts)
        .get();
    final opsBefore = await database
        .select(database.calendarSyncOperations)
        .get();

    await database.transaction(() async {
      await (database.delete(
        database.calendarEvents,
      )..where((t) => t.origin.equals(CalendarEventOrigin.external.name))).go();
      if (externalIds.isNotEmpty) {
        await (database.delete(
          database.calendarEventLinks,
        )..where((t) => t.memyEventId.isIn(externalIds))).go();
        await (database.delete(
          database.calendarConflicts,
        )..where((t) => t.memyEventId.isIn(externalIds))).go();
        await (database.delete(
          database.calendarSyncOperations,
        )..where((t) => t.memyEventId.isIn(externalIds))).go();
        await (database.delete(
          database.calendarCreateRecoveryCases,
        )..where((t) => t.memyEventId.isIn(externalIds))).go();
      }
    });

    final eventsAfter = await database.select(database.calendarEvents).get();
    final linksAfter = await database.select(database.calendarEventLinks).get();
    final conflictsAfter = await database
        .select(database.calendarConflicts)
        .get();
    final opsAfter = await database
        .select(database.calendarSyncOperations)
        .get();

    return (
      events: eventsBefore.length - eventsAfter.length,
      links: linksBefore.length - linksAfter.length,
      conflicts: conflictsBefore.length - conflictsAfter.length,
      ops: opsBefore.length - opsAfter.length,
    );
  }

  /// Deletes MeMy-authored local events and related sync metadata.
  /// Preserves imported external events and calendar connection config.
  Future<({int events, int links, int conflicts, int ops})>
  clearMeMyLocalRecords() async {
    final eventsBefore = await database.select(database.calendarEvents).get();
    final localIds = eventsBefore
        .where((e) => e.origin == CalendarEventOrigin.local.name)
        .map((e) => e.id)
        .toSet();

    final linksBefore = await database
        .select(database.calendarEventLinks)
        .get();
    final conflictsBefore = await database
        .select(database.calendarConflicts)
        .get();
    final opsBefore = await database
        .select(database.calendarSyncOperations)
        .get();

    await database.transaction(() async {
      await (database.delete(
        database.calendarEvents,
      )..where((t) => t.origin.equals(CalendarEventOrigin.local.name))).go();
      if (localIds.isNotEmpty) {
        await (database.delete(
          database.calendarEventLinks,
        )..where((t) => t.memyEventId.isIn(localIds))).go();
        await (database.delete(
          database.calendarConflicts,
        )..where((t) => t.memyEventId.isIn(localIds))).go();
        await (database.delete(
          database.calendarSyncOperations,
        )..where((t) => t.memyEventId.isIn(localIds))).go();
        await (database.delete(
          database.calendarCreateRecoveryCases,
        )..where((t) => t.memyEventId.isIn(localIds))).go();
      }
    });

    final eventsAfter = await database.select(database.calendarEvents).get();
    final linksAfter = await database.select(database.calendarEventLinks).get();
    final conflictsAfter = await database
        .select(database.calendarConflicts)
        .get();
    final opsAfter = await database
        .select(database.calendarSyncOperations)
        .get();

    return (
      events: eventsBefore.length - eventsAfter.length,
      links: linksBefore.length - linksAfter.length,
      conflicts: conflictsBefore.length - conflictsAfter.length,
      ops: opsBefore.length - opsAfter.length,
    );
  }

  /// Resets calendar integration / connection configuration only.
  Future<int> resetIntegrationConfig() async {
    await database.delete(database.calendarConfigRows).go();
    await saveConfig(const CalendarConfig());
    return 1;
  }

  CalendarCreateRecoveryCase _recoveryFromRow(
    db.CalendarCreateRecoveryCase row,
  ) {
    return CalendarCreateRecoveryCase(
      id: row.id,
      syncOperationId: row.syncOperationId,
      memyEventId: row.memyEventId,
      recoveryType: CalendarCreateRecoveryType.values.byName(row.recoveryType),
      status: CalendarCreateRecoveryStatus.values.byName(row.status),
      candidates: CalendarCreateRecoveryCase.decodeCandidates(
        row.candidatesJson,
      ),
      createdAt: row.createdAtUtc,
      resolvedAt: row.resolvedAtUtc,
      dismissedAt: row.dismissedAtUtc,
    );
  }

  db.CalendarCreateRecoveryCasesCompanion _recoveryToCompanion(
    CalendarCreateRecoveryCase recoveryCase,
  ) {
    return db.CalendarCreateRecoveryCasesCompanion(
      id: Value(recoveryCase.id),
      syncOperationId: Value(recoveryCase.syncOperationId),
      memyEventId: Value(recoveryCase.memyEventId),
      recoveryType: Value(recoveryCase.recoveryType.name),
      status: Value(recoveryCase.status.name),
      candidatesJson: Value(recoveryCase.encodeCandidates()),
      createdAtUtc: Value(recoveryCase.createdAt),
      resolvedAtUtc: Value(recoveryCase.resolvedAt),
      dismissedAtUtc: Value(recoveryCase.dismissedAt),
    );
  }
}
