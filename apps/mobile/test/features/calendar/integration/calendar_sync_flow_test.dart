import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/application/providers/integration_providers.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/features/calendar/application/services/calendar_sync_service.dart';
import 'package:memy/features/calendar/data/gateways/fake_device_calendar_gateway.dart';
import 'package:memy/features/calendar/data/local/calendar_database.dart';
import 'package:memy/features/calendar/data/repositories/local_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_origin.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/conflict_resolution.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';

/// End-to-end sync flow against a *real* SQLite file (not a fake in-memory
/// repository), exercising the full connect → import → local edit →
/// external edit → conflict → resolve → persist lifecycle described in the
/// calendar-sync spec.
void main() {
  test(
    'connect -> import -> double-save local event -> external edit pull -> '
    'conflict Keep Both -> data survives closing/reopening the database',
    () async {
      final path =
          '${Directory.systemTemp.path}/memy_calendar_integration_'
          '${DateTime.now().microsecondsSinceEpoch}.sqlite';
      final file = File(path);
      addTearDown(() {
        if (file.existsSync()) file.deleteSync();
      });

      final clock = FixedAppClock(DateTime.utc(2026, 6, 1, 8));
      var idSeq = 0;
      String nextId() => 'int_id_${idSeq++}';

      var db = CalendarDatabase(NativeDatabase(file));
      var repository = LocalCalendarRepository(
        database: db,
        clock: clock,
        idGenerator: nextId,
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gateway = FakeDeviceCalendarGateway();
      gateway.nowUtc = () => clock.now().toUtc();
      var service = CalendarSyncService(
        gateway: gateway,
        repository: repository,
        registry: container.read(
          integrationConnectionRegistryProvider.notifier,
        ),
        clock: clock,
        idGenerator: nextId,
      );

      // --- connect -------------------------------------------------------
      gateway.seedCalendar(id: 'cal_1', name: 'Personal', isDefault: true);
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'ext_dentist',
        title: 'Dentist',
        time: TimedCalendarEventTime(
          startUtc: DateTime.utc(2026, 6, 5, 10),
          endUtc: DateTime.utc(2026, 6, 5, 11),
        ),
        lastModifiedUtc: clock.now(),
      );

      final calendars = await service.beginConnection();
      expect(calendars.map((c) => c.id), contains('cal_1'));
      expect(
        container.read(calendarConnectionProvider).status,
        IntegrationConnectionStatus.connecting,
      );

      // --- import (initial sync) -----------------------------------------
      await service.confirmCalendarSelection(
        readableIds: ['cal_1'],
        writableId: 'cal_1',
      );
      expect(
        container.read(calendarConnectionProvider).status,
        IntegrationConnectionStatus.connected,
      );
      final importResult = await service.performInitialSync();
      expect(importResult.pulledCount, 1);

      final afterImport = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(afterImport, hasLength(1));
      final importedEvent = afterImport.single;
      expect(importedEvent.title, 'Dentist');
      expect(importedEvent.origin, CalendarEventOrigin.external);

      // --- create a MeMy event, then edit it (double-save) ----------------
      final created = await repository.createEvent(
        MemyCalendarEvent(
          id: '',
          title: 'Write research draft',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 6, 9),
            endUtc: DateTime.utc(2026, 6, 6, 10),
          ),
          syncStatus: CalendarEventSyncStatus.pendingPush,
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      );
      final secondSave = await repository.updateEvent(
        created.copyWith(
          title: 'Write research draft (final pass)',
          syncStatus: CalendarEventSyncStatus.pendingPush,
        ),
      );
      expect(secondSave.title, 'Write research draft (final pass)');

      final pushResult = await service.push();
      expect(pushResult.pushedCount, 1);
      final pushedEvent = await repository.getEvent(secondSave.id);
      expect(pushedEvent!.syncStatus, CalendarEventSyncStatus.synced);
      expect(pushedEvent.isLinkedToExternal, isTrue);
      expect(
        gateway.eventsIn('cal_1').map((e) => e.title),
        contains('Write research draft (final pass)'),
      );

      // --- concurrent local + external edit -> conflict on pull -----------
      // Conflict requires a MeMy-owned linked event (imported remain read-only).
      await repository.updateEvent(
        pushedEvent.copyWith(
          title: 'Write research draft (local edit)',
          syncStatus: CalendarEventSyncStatus.pendingPush,
        ),
      );
      gateway.simulateExternalEdit(
        calendarId: 'cal_1',
        externalEventId: pushedEvent.externalEventId!,
        title: 'Write research draft (phone edit)',
        lastModifiedUtc: clock.now().add(const Duration(minutes: 10)),
      );

      final pullResult = await service.pull();
      expect(pullResult.conflictCount, 1);
      final conflicts = await repository.getConflicts();
      expect(conflicts, hasLength(1));
      final conflict = conflicts.single;
      expect(conflict.localSnapshot.title, 'Write research draft (local edit)');
      expect(
        conflict.externalSnapshot.title,
        'Write research draft (phone edit)',
      );

      // --- resolve with Keep Both ------------------------------------------
      await service.resolveConflict(
        conflictId: conflict.id,
        resolution: ConflictResolution.keepBoth,
      );
      expect(await repository.getConflicts(), isEmpty);

      final afterResolution = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      // Imported Dentist + phone-edited research draft + local-only duplicate.
      expect(afterResolution, hasLength(3));
      expect(
        afterResolution.map((e) => e.title),
        containsAll([
          'Dentist',
          'Write research draft (phone edit)',
          'Write research draft (local edit)',
        ]),
      );

      // --- recreate the DB connection and confirm everything persisted ----
      await db.close();

      db = CalendarDatabase(NativeDatabase(file));
      repository = LocalCalendarRepository(
        database: db,
        clock: clock,
        idGenerator: nextId,
      );

      final reloadedEvents = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(reloadedEvents, hasLength(3));
      expect(
        reloadedEvents.map((e) => e.title),
        containsAll([
          'Dentist',
          'Write research draft (phone edit)',
          'Write research draft (local edit)',
        ]),
      );
      expect(await repository.getConflicts(), isEmpty);
      final reloadedConfig = await repository.getConfig();
      expect(reloadedConfig.readableCalendarIds, ['cal_1']);
      expect(reloadedConfig.defaultWritableCalendarId, 'cal_1');

      await db.close();
    },
  );
}
