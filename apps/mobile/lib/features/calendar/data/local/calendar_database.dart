import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'calendar_database.g.dart';

/// One MeMy calendar event (local, imported, or linked to a device event).
///
/// `externalCalendarId`/`externalEventId` are nullable — local-only events
/// leave both null. SQLite treats each `NULL` as distinct for uniqueness
/// purposes, so many local events can coexist while true external
/// duplicates are still rejected by [uniqueKeys].
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
/// calendar counterpart.
class CalendarEventLinks extends Table {
  TextColumn get id => text()();
  TextColumn get memyEventId => text()();
  TextColumn get provider => text()();
  TextColumn get externalCalendarId => text()();
  TextColumn get externalEventId => text()();
  DateTimeColumn get lastSyncedAtUtc => dateTime()();
  DateTimeColumn get lastKnownExternalUpdatedAtUtc => dateTime().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();

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

/// Single-row table (`id` fixed at 0) holding calendar-integration settings.
class CalendarConfigRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get selectedCalendarIdsJson =>
      text().withDefault(const Constant('[]'))();
  DateTimeColumn get lastFullSyncAtUtc => dateTime().nullable()();
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
    CalendarConfigRows,
  ],
)
class CalendarDatabase extends _$CalendarDatabase {
  CalendarDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'memy_calendar'));

  @override
  int get schemaVersion => 1;
}
