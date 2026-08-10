import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/domain/integration_provider.dart';
import 'package:memy/features/calendar/data/local/calendar_database.dart'
    hide CalendarEventLink;
import 'package:memy/features/calendar/data/repositories/local_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_config.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_link.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/calendar_sync_conflict.dart';
import 'package:memy/features/calendar/domain/entities/conflict_resolution.dart';
import 'package:memy/features/calendar/domain/entities/external_event_snapshot.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';

MemyCalendarEvent _event({
  required String id,
  String title = 'Standup',
  DateTime? start,
  CalendarEventSyncStatus syncStatus = CalendarEventSyncStatus.localOnly,
  String? externalCalendarId,
  String? externalEventId,
}) {
  final startUtc = start ?? DateTime.utc(2026, 6, 1, 10);
  return MemyCalendarEvent(
    id: id,
    title: title,
    time: TimedCalendarEventTime(
      startUtc: startUtc,
      endUtc: startUtc.add(const Duration(hours: 1)),
    ),
    syncStatus: syncStatus,
    provider: externalCalendarId == null ? null : IntegrationProvider.calendar,
    externalCalendarId: externalCalendarId,
    externalEventId: externalEventId,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  late CalendarDatabase db;
  late LocalCalendarRepository repository;

  setUp(() {
    db = CalendarDatabase(NativeDatabase.memory());
    repository = LocalCalendarRepository(
      database: db,
      clock: FixedAppClock(DateTime.utc(2026, 6, 1)),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('events', () {
    test('createEvent then getEventsInRange returns it within range', () async {
      await repository.createEvent(_event(id: 'evt_1'));

      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 6, 1),
        endUtc: DateTime.utc(2026, 6, 2),
      );

      expect(events, hasLength(1));
      expect(events.single.id, 'evt_1');
    });

    test('events outside the requested range are excluded', () async {
      await repository.createEvent(
        _event(id: 'evt_far', start: DateTime.utc(2026, 12, 25, 10)),
      );

      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 6, 1),
        endUtc: DateTime.utc(2026, 6, 2),
      );

      expect(events, isEmpty);
    });

    test('updateEvent persists field changes', () async {
      await repository.createEvent(_event(id: 'evt_1', title: 'Original'));
      final existing = await repository.getEvent('evt_1');
      await repository.updateEvent(existing!.copyWith(title: 'Renamed'));

      final updated = await repository.getEvent('evt_1');
      expect(updated!.title, 'Renamed');
    });

    test('deleteEvent removes the row', () async {
      await repository.createEvent(_event(id: 'evt_1'));
      await repository.deleteEvent('evt_1');

      expect(await repository.getEvent('evt_1'), isNull);
    });

    test(
      'getPendingSyncEvents returns only pendingPush/pendingDelete rows',
      () async {
        await repository.createEvent(
          _event(id: 'synced', syncStatus: CalendarEventSyncStatus.synced),
        );
        await repository.createEvent(
          _event(id: 'push', syncStatus: CalendarEventSyncStatus.pendingPush),
        );
        await repository.createEvent(
          _event(
            id: 'delete',
            syncStatus: CalendarEventSyncStatus.pendingDelete,
          ),
        );

        final pending = await repository.getPendingSyncEvents();

        expect(pending.map((e) => e.id).toSet(), {'push', 'delete'});
      },
    );

    test(
      'rejects a duplicate (externalCalendarId, externalEventId) pair',
      () async {
        await repository.createEvent(
          _event(
            id: 'evt_1',
            externalCalendarId: 'cal_1',
            externalEventId: 'ext_1',
          ),
        );

        expect(
          () => repository.createEvent(
            _event(
              id: 'evt_2',
              externalCalendarId: 'cal_1',
              externalEventId: 'ext_1',
            ),
          ),
          throwsA(anything),
        );
      },
    );
  });

  group('links', () {
    test(
      'saveLink then getLinkForEvent/getLinkByExternalId round-trip',
      () async {
        await repository.createEvent(_event(id: 'evt_1'));
        final link = CalendarEventLink(
          id: 'link_1',
          memyEventId: 'evt_1',
          provider: IntegrationProvider.calendar,
          externalCalendarId: 'cal_1',
          externalEventId: 'ext_1',
          lastSyncedAt: DateTime.utc(2026, 6, 1),
        );
        await repository.saveLink(link);

        final byEvent = await repository.getLinkForEvent('evt_1');
        final byExternal = await repository.getLinkByExternalId(
          externalCalendarId: 'cal_1',
          externalEventId: 'ext_1',
        );

        expect(byEvent?.id, 'link_1');
        expect(byExternal?.id, 'link_1');
      },
    );

    test('getLinksForExternalCalendar filters by calendar id', () async {
      await repository.createEvent(_event(id: 'evt_1'));
      await repository.createEvent(_event(id: 'evt_2'));
      await repository.saveLink(
        CalendarEventLink(
          id: 'link_1',
          memyEventId: 'evt_1',
          provider: IntegrationProvider.calendar,
          externalCalendarId: 'cal_1',
          externalEventId: 'ext_1',
          lastSyncedAt: DateTime.utc(2026, 6, 1),
        ),
      );
      await repository.saveLink(
        CalendarEventLink(
          id: 'link_2',
          memyEventId: 'evt_2',
          provider: IntegrationProvider.calendar,
          externalCalendarId: 'cal_2',
          externalEventId: 'ext_2',
          lastSyncedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      final links = await repository.getLinksForExternalCalendar('cal_1');
      expect(links.map((l) => l.id), ['link_1']);
    });

    test('deleteLink removes the row', () async {
      await repository.createEvent(_event(id: 'evt_1'));
      await repository.saveLink(
        CalendarEventLink(
          id: 'link_1',
          memyEventId: 'evt_1',
          provider: IntegrationProvider.calendar,
          externalCalendarId: 'cal_1',
          externalEventId: 'ext_1',
          lastSyncedAt: DateTime.utc(2026, 6, 1),
        ),
      );
      await repository.deleteLink('link_1');

      expect(await repository.getLinkForEvent('evt_1'), isNull);
    });
  });

  group('conflicts', () {
    test('addConflict then getConflicts/getConflict round-trip', () async {
      await repository.createEvent(_event(id: 'evt_1'));
      final local = await repository.getEvent('evt_1');
      final conflict = CalendarSyncConflict(
        id: 'conflict_1',
        memyEventId: 'evt_1',
        localSnapshot: local!,
        externalSnapshot: ExternalEventSnapshot(
          title: 'Renamed externally',
          time: local.time,
        ),
        detectedAt: DateTime.utc(2026, 6, 1),
      );
      await repository.addConflict(conflict);

      final all = await repository.getConflicts();
      final byId = await repository.getConflict('conflict_1');

      expect(all, hasLength(1));
      expect(byId?.externalSnapshot.title, 'Renamed externally');
    });

    test('markConflictResolved excludes it from getConflicts', () async {
      await repository.createEvent(_event(id: 'evt_1'));
      final local = await repository.getEvent('evt_1');
      await repository.addConflict(
        CalendarSyncConflict(
          id: 'conflict_1',
          memyEventId: 'evt_1',
          localSnapshot: local!,
          externalSnapshot: ExternalEventSnapshot(
            title: 'Renamed externally',
            time: local.time,
          ),
          detectedAt: DateTime.utc(2026, 6, 1),
        ),
      );

      await repository.markConflictResolved(
        conflictId: 'conflict_1',
        resolution: ConflictResolution.keepLocal,
      );

      expect(await repository.getConflicts(), isEmpty);
      final resolved = await repository.getConflict('conflict_1');
      expect(resolved?.isResolved, isTrue);
      expect(resolved?.resolution, ConflictResolution.keepLocal);
    });
  });

  group('config', () {
    test('getConfig defaults to an empty config before any save', () async {
      final config = await repository.getConfig();
      expect(config.selectedCalendarIds, isEmpty);
      expect(config.lastFullSyncAt, isNull);
    });

    test('saveConfig then getConfig round-trips all fields', () async {
      await repository.saveConfig(
        CalendarConfig(
          selectedCalendarIds: const ['cal_1', 'cal_2'],
          lastFullSyncAt: DateTime.utc(2026, 6, 1, 9),
          initialSyncAnchorPast: DateTime.utc(2026, 5, 1),
          initialSyncAnchorFuture: DateTime.utc(2027, 6, 1),
        ),
      );

      final config = await repository.getConfig();
      expect(config.selectedCalendarIds, ['cal_1', 'cal_2']);
      expect(config.lastFullSyncAt, DateTime.utc(2026, 6, 1, 9));
      expect(config.initialSyncAnchorPast, DateTime.utc(2026, 5, 1));
      expect(config.initialSyncAnchorFuture, DateTime.utc(2027, 6, 1));
    });
  });

  test('data survives closing and reopening the same database file', () async {
    // Uses a temp file (not `.memory()`) so state is not tied to one
    // in-process connection — this is what a real app restart looks like.
    final path =
        '${Directory.systemTemp.path}/memy_calendar_test_${DateTime.now().microsecondsSinceEpoch}.sqlite';
    final file = File(path);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    var reopenedDb = CalendarDatabase(NativeDatabase(file));
    var reopenedRepo = LocalCalendarRepository(database: reopenedDb);
    await reopenedRepo.createEvent(_event(id: 'persisted_evt'));
    await reopenedDb.close();

    reopenedDb = CalendarDatabase(NativeDatabase(file));
    reopenedRepo = LocalCalendarRepository(database: reopenedDb);
    final reloaded = await reopenedRepo.getEvent('persisted_evt');
    expect(reloaded, isNotNull);
    expect(reloaded!.title, 'Standup');
    await reopenedDb.close();
  });
}
