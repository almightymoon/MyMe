import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'calendar_database.g.dart';

/// One MeMy calendar event (local, imported, or linked to a device event).
class CalendarEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get startUtc => dateTime()();
  DateTimeColumn get endUtc => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  TextColumn get timezoneName => text().nullable()();
  TextColumn get origin => text()();
  TextColumn get syncStatus => text()();
  TextColumn get externalProvider => text().nullable()();
  TextColumn get externalCalendarId => text().nullable()();
  TextColumn get externalEventId => text().nullable()();
  TextColumn get reminderMinutesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get recurrenceRule => text().nullable()();
  BoolColumn get isRecurringInstance =>
      boolean().withDefault(const Constant(false))();
  TextColumn get seriesExternalEventId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get deletedAtUtc => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {externalCalendarId, externalEventId},
  ];
}

/// Sync bookkeeping linking one [CalendarEvents] row to its external
/// calendar counterpart, including safe missing-event presence tracking.
class CalendarEventLinks extends Table {
  TextColumn get id => text()();
  TextColumn get memyEventId => text()();
  TextColumn get provider => text()();
  TextColumn get externalCalendarId => text()();
  TextColumn get externalEventId => text()();
  DateTimeColumn get lastSyncedAtUtc => dateTime()();
  DateTimeColumn get lastKnownExternalUpdatedAtUtc => dateTime().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();

  // v2 presence / tombstone fields
  TextColumn get presenceStatus =>
      text().withDefault(const Constant('present'))();
  DateTimeColumn get lastSeenExternallyAtUtc => dateTime().nullable()();
  DateTimeColumn get firstMissingObservationAtUtc => dateTime().nullable()();
  DateTimeColumn get lastMissingObservationAtUtc => dateTime().nullable()();
  IntColumn get missingObservationCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompleteQueryStartUtc => dateTime().nullable()();
  DateTimeColumn get lastCompleteQueryEndUtc => dateTime().nullable()();
  BoolColumn get hiddenLocally =>
      boolean().withDefault(const Constant(false))();
  TextColumn get memyMarker => text().nullable()();
  DateTimeColumn get lastVerifiedLookupAtUtc => dateTime().nullable()();
  TextColumn get lastLookupDisposition => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {memyEventId},
    {provider, externalCalendarId, externalEventId},
  ];
}

/// Unresolved (or resolved-but-audited) local/external divergence.
class CalendarConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get memyEventId => text()();
  TextColumn get linkId => text().nullable()();
  TextColumn get localSnapshotJson => text()();
  TextColumn get externalSnapshotJson => text()();
  DateTimeColumn get detectedAtUtc => dateTime()();
  DateTimeColumn get resolvedAtUtc => dateTime().nullable()();
  TextColumn get resolution => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable push outbox for idempotent create/update/delete.
class CalendarSyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get memyEventId => text()();
  TextColumn get operationType => text()();
  TextColumn get targetCalendarId => text()();
  TextColumn get payloadFingerprint => text()();
  TextColumn get state => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get providerExternalEventId => text().nullable()();
  TextColumn get memyMarker => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get startedAtUtc => dateTime().nullable()();
  DateTimeColumn get completedAtUtc => dateTime().nullable()();
  DateTimeColumn get nextRetryAtUtc => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ambiguous create reconciliation requiring user action.
class CalendarCreateRecoveryCases extends Table {
  TextColumn get id => text()();
  TextColumn get syncOperationId => text()();
  TextColumn get memyEventId => text()();
  TextColumn get recoveryType => text()();
  TextColumn get status => text()();
  TextColumn get candidatesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get resolvedAtUtc => dateTime().nullable()();
  DateTimeColumn get dismissedAtUtc => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row table (`id` fixed at 0) holding calendar-integration settings.
class CalendarConfigRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// Legacy v1 column — migrated into [readableCalendarIdsJson].
  TextColumn get selectedCalendarIdsJson =>
      text().withDefault(const Constant('[]'))();

  TextColumn get readableCalendarIdsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get defaultWritableCalendarId => text().nullable()();
  TextColumn get dedicatedMeMyCalendarId => text().nullable()();
  IntColumn get syncPastWindowDays =>
      integer().withDefault(const Constant(30))();
  IntColumn get syncFutureWindowDays =>
      integer().withDefault(const Constant(365))();
  IntColumn get calendarSchemaVersion =>
      integer().withDefault(const Constant(2))();

  DateTimeColumn get lastFullSyncAtUtc => dateTime().nullable()();
  DateTimeColumn get lastSuccessfulPullAtUtc => dateTime().nullable()();
  DateTimeColumn get lastSuccessfulPushAtUtc => dateTime().nullable()();
  DateTimeColumn get lastPermissionCheckAtUtc => dateTime().nullable()();
  DateTimeColumn get lastCalendarDiscoveryAtUtc => dateTime().nullable()();
  DateTimeColumn get connectionConfiguredAtUtc => dateTime().nullable()();

  /// Legacy frozen anchors — retained for migration, unused by sync.
  DateTimeColumn get initialSyncAnchorPastUtc => dateTime().nullable()();
  DateTimeColumn get initialSyncAnchorFutureUtc => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    CalendarEvents,
    CalendarEventLinks,
    CalendarConflicts,
    CalendarSyncOperations,
    CalendarCreateRecoveryCases,
    CalendarConfigRows,
  ],
)
class CalendarDatabase extends _$CalendarDatabase {
  CalendarDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'memy_calendar'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Event table additions
        await m.addColumn(calendarEvents, calendarEvents.recurrenceRule);
        await m.addColumn(calendarEvents, calendarEvents.isRecurringInstance);
        await m.addColumn(calendarEvents, calendarEvents.seriesExternalEventId);

        // Link presence / tombstone columns
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.presenceStatus,
        );
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.lastSeenExternallyAtUtc,
        );
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.firstMissingObservationAtUtc,
        );
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.lastMissingObservationAtUtc,
        );
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.missingObservationCount,
        );
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.lastCompleteQueryStartUtc,
        );
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.lastCompleteQueryEndUtc,
        );
        await m.addColumn(calendarEventLinks, calendarEventLinks.hiddenLocally);
        await m.addColumn(calendarEventLinks, calendarEventLinks.memyMarker);

        // Outbox
        await m.createTable(calendarSyncOperations);

        // Config v2 columns
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.readableCalendarIdsJson,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.defaultWritableCalendarId,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.dedicatedMeMyCalendarId,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.syncPastWindowDays,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.syncFutureWindowDays,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.calendarSchemaVersion,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.lastSuccessfulPullAtUtc,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.lastSuccessfulPushAtUtc,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.lastPermissionCheckAtUtc,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.lastCalendarDiscoveryAtUtc,
        );
        await m.addColumn(
          calendarConfigRows,
          calendarConfigRows.connectionConfiguredAtUtc,
        );

        // Migrate selected → readable; never invent a writable destination.
        final rows = await select(calendarConfigRows).get();
        for (final row in rows) {
          final selected = row.selectedCalendarIdsJson;
          await (update(
            calendarConfigRows,
          )..where((t) => t.id.equals(row.id))).write(
            CalendarConfigRowsCompanion(
              readableCalendarIdsJson: Value(selected),
              calendarSchemaVersion: const Value(2),
              connectionConfiguredAtUtc: Value(
                selected != '[]' && selected.isNotEmpty
                    ? DateTime.now().toUtc()
                    : null,
              ),
            ),
          );
        }
      }
      if (from < 3) {
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.lastVerifiedLookupAtUtc,
        );
        await m.addColumn(
          calendarEventLinks,
          calendarEventLinks.lastLookupDisposition,
        );
        await m.createTable(calendarCreateRecoveryCases);
        await (update(calendarConfigRows)..where((t) => t.id.equals(0))).write(
          const CalendarConfigRowsCompanion(calendarSchemaVersion: Value(3)),
        );
      }
    },
  );

  /// Helper used by tests to seed a v1-shaped config JSON blob.
  static String encodeIdList(List<String> ids) => jsonEncode(ids);
}
