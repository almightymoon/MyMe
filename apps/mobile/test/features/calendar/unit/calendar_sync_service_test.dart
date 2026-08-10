import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/application/providers/integration_providers.dart';
import 'package:memy/core/integrations/domain/integration_availability.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/core/integrations/domain/integration_error.dart';
import 'package:memy/features/calendar/application/services/calendar_sync_service.dart';
import 'package:memy/features/calendar/data/gateways/fake_device_calendar_gateway.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_config.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_origin.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/calendar_mutation_exception.dart';
import 'package:memy/features/calendar/domain/entities/calendar_read_batch.dart';
import 'package:memy/features/calendar/domain/entities/conflict_resolution.dart';
import 'package:memy/features/calendar/domain/entities/external_presence_status.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';

void main() {
  late ProviderContainer container;
  late FakeDeviceCalendarGateway gateway;
  late FakeCalendarRepository repository;
  late CalendarSyncService service;
  late FixedAppClock clock;
  var idSeq = 0;

  Future<void> confirm({
    List<String> readable = const ['cal_1'],
    String? writable = 'cal_1',
  }) {
    return service.confirmCalendarSelection(
      readableIds: readable,
      writableId: writable,
    );
  }

  setUp(() {
    idSeq = 0;
    clock = FixedAppClock(DateTime.utc(2026, 6, 1, 8));
    container = ProviderContainer();
    gateway = FakeDeviceCalendarGateway(permissionsGranted: true);
    gateway.nowUtc = () => clock.now().toUtc();
    repository = FakeCalendarRepository(clock: clock, seedEvents: const []);
    service = CalendarSyncService(
      gateway: gateway,
      repository: repository,
      registry: container.read(integrationConnectionRegistryProvider.notifier),
      clock: clock,
      idGenerator: () => 'id_${idSeq++}',
    );
  });

  tearDown(() {
    container.dispose();
    repository.dispose();
  });

  group('beginConnection', () {
    test('stays connecting until calendar selection is confirmed', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary', isDefault: true);

      final calendars = await service.beginConnection();

      expect(calendars, hasLength(1));
      final connection = container.read(calendarConnectionProvider);
      expect(connection.status, IntegrationConnectionStatus.connecting);
      expect(connection.availability, IntegrationAvailability.available);
    });

    test('surfaces unavailable calendars as an error state', () async {
      gateway.setAvailability(IntegrationAvailability.unavailable);

      await expectLater(service.beginConnection(), throwsA(anything));

      final connection = container.read(calendarConnectionProvider);
      expect(connection.status, IntegrationConnectionStatus.error);
    });
  });

  group('confirmCalendarSelection', () {
    test(
      'persists readable + writable calendars and marks connected',
      () async {
        gateway.seedCalendar(id: 'cal_1', name: 'Primary');
        gateway.seedCalendar(id: 'cal_ro', name: 'Holidays', isReadOnly: true);
        await service.beginConnection();

        await service.confirmCalendarSelection(
          readableIds: ['cal_1', 'cal_ro'],
          writableId: 'cal_1',
        );

        final config = await repository.getConfig();
        expect(config.readableCalendarIds, ['cal_1', 'cal_ro']);
        expect(config.defaultWritableCalendarId, 'cal_1');
        expect(config.connectionConfiguredAt, isNotNull);

        final connection = container.read(calendarConnectionProvider);
        expect(connection.status, IntegrationConnectionStatus.connected);
        expect(connection.selectedCalendarIds, ['cal_1', 'cal_ro']);
      },
    );

    test('rejects a read-only writable destination', () async {
      gateway.seedCalendar(id: 'cal_ro', name: 'Holidays', isReadOnly: true);
      await service.beginConnection();

      await expectLater(
        service.confirmCalendarSelection(
          readableIds: ['cal_ro'],
          writableId: 'cal_ro',
        ),
        throwsA(isA<IntegrationError>()),
      );
    });
  });

  group('rolling window', () {
    test('advances with FixedAppClock', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      await confirm();

      final config = await repository.getConfig();
      final window1 = config.rollingWindow(clock.now());
      expect(window1.start, DateTime.utc(2026, 5, 2, 8));
      expect(window1.end, DateTime.utc(2027, 6, 1, 8));

      clock.setNow(DateTime.utc(2026, 7, 1, 8));
      final window2 = config.rollingWindow(clock.now());
      expect(window2.start, DateTime.utc(2026, 6, 1, 8));
      expect(window2.end, DateTime.utc(2027, 7, 1, 8));
    });
  });

  group('pull', () {
    test('imports new external events as synced MeMy events', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
        title: 'Dentist',
        time: TimedCalendarEventTime(
          startUtc: DateTime.utc(2026, 6, 1, 10),
          endUtc: DateTime.utc(2026, 6, 1, 11),
        ),
        lastModifiedUtc: clock.now(),
      );
      await confirm();

      final result = await service.pull();

      expect(result.pulledCount, 1);
      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(events, hasLength(1));
      expect(events.single.title, 'Dentist');
      expect(events.single.origin, CalendarEventOrigin.external);
      expect(events.single.syncStatus, CalendarEventSyncStatus.synced);

      final link = await repository.getLinkForEvent(events.single.id);
      expect(link, isNotNull);
      expect(link!.externalEventId, 'ext_1');
      expect(link.presence, ExternalPresenceStatus.present);
    });

    test('first missing observation is suspected, not deleted', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
        title: 'Dentist',
        time: TimedCalendarEventTime(
          startUtc: DateTime.utc(2026, 6, 1, 10),
          endUtc: DateTime.utc(2026, 6, 1, 11),
        ),
        lastModifiedUtc: clock.now(),
      );
      await confirm();
      await service.pull();

      gateway.simulateExternalDelete(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
      );
      final result = await service.pull();

      expect(result.deletedCount, 0);
      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(events, hasLength(1));
      final link = await repository.getLinkForEvent(events.single.id);
      expect(link!.presence, ExternalPresenceStatus.suspectedMissing);
      expect(link.missingObservationCount, 1);
    });

    test('second missing observation confirms and hides external', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
        title: 'Dentist',
        time: TimedCalendarEventTime(
          startUtc: DateTime.utc(2026, 6, 1, 10),
          endUtc: DateTime.utc(2026, 6, 1, 11),
        ),
        lastModifiedUtc: clock.now(),
      );
      await confirm();
      await service.pull();

      gateway.simulateExternalDelete(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
      );
      await service.pull();
      final result = await service.pull();

      expect(result.deletedCount, 1);
      final visible = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(visible, isEmpty);

      final hidden = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
        includeHidden: true,
      );
      expect(hidden, hasLength(1));
      expect(hidden.single.syncStatus, CalendarEventSyncStatus.hidden);
      final link = await repository.getLinkForEvent(hidden.single.id);
      expect(link!.presence, ExternalPresenceStatus.confirmedMissing);
      expect(link.hiddenLocally, isTrue);
    });

    test('partial batch does not advance missing observations', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
        title: 'Dentist',
        time: TimedCalendarEventTime(
          startUtc: DateTime.utc(2026, 6, 1, 10),
          endUtc: DateTime.utc(2026, 6, 1, 11),
        ),
        lastModifiedUtc: clock.now(),
      );
      await confirm();
      await service.pull();

      gateway.simulateExternalDelete(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
      );
      gateway.forcePartialBatches = true;
      final result = await service.pull();

      expect(result.deletedCount, 0);
      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(events, hasLength(1));
      final link = await repository.getLinkForEvent(events.single.id);
      expect(link!.presence, ExternalPresenceStatus.present);
      expect(link.missingObservationCount, 0);
    });

    test(
      'flags a conflict when a locally pending-push event also changed externally',
      () async {
        gateway.seedCalendar(id: 'cal_1', name: 'Primary');
        final ext = gateway.seedEvent(
          calendarId: 'cal_1',
          externalEventId: 'ext_1',
          title: 'Dentist',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 1, 10),
            endUtc: DateTime.utc(2026, 6, 1, 11),
          ),
          lastModifiedUtc: clock.now(),
        );
        await confirm();
        await service.pull();

        final events = await repository.getEventsInRange(
          startUtc: DateTime.utc(2026, 1, 1),
          endUtc: DateTime.utc(2027, 1, 1),
        );
        // Promote to local-owned so edits are allowed (imported are RO).
        final local = events.single.copyWith(
          origin: CalendarEventOrigin.local,
          title: 'Dentist (moved)',
          syncStatus: CalendarEventSyncStatus.pendingPush,
        );
        // Bypass RO guard by replacing origin first via direct list mutation:
        await repository.updateEvent(
          events.single.copyWith(origin: CalendarEventOrigin.local),
        );
        await repository.updateEvent(local);

        gateway.simulateExternalEdit(
          calendarId: 'cal_1',
          externalEventId: ext.externalEventId,
          title: 'Dentist (renamed on phone)',
          lastModifiedUtc: clock.now().add(const Duration(minutes: 5)),
        );

        final result = await service.pull();

        expect(result.conflictCount, 1);
        final conflicts = await repository.getConflicts();
        expect(conflicts, hasLength(1));
        expect(conflicts.single.localSnapshot.title, 'Dentist (moved)');
        expect(
          conflicts.single.externalSnapshot.title,
          'Dentist (renamed on phone)',
        );
      },
    );
  });

  group('push', () {
    test(
      'creates a new external event for a local pendingPush event',
      () async {
        gateway.seedCalendar(id: 'cal_1', name: 'Primary');
        await confirm();

        final created = await repository.createEvent(
          MemyCalendarEvent(
            id: '',
            title: 'New local event',
            time: TimedCalendarEventTime(
              startUtc: DateTime.utc(2026, 6, 2, 9),
              endUtc: DateTime.utc(2026, 6, 2, 10),
            ),
            syncStatus: CalendarEventSyncStatus.pendingPush,
            createdAt: clock.now(),
            updatedAt: clock.now(),
          ),
        );

        final result = await service.push();

        expect(result.pushedCount, 1);
        final saved = await repository.getEvent(created.id);
        expect(saved!.syncStatus, CalendarEventSyncStatus.synced);
        expect(saved.isLinkedToExternal, isTrue);
        expect(gateway.eventsIn('cal_1'), hasLength(1));
        expect(
          gateway.eventsIn('cal_1').single.url,
          contains('memy://calendar-event/'),
        );
      },
    );

    test('uses writable calendar, not first readable', () async {
      gateway.seedCalendar(id: 'cal_read', name: 'Read');
      gateway.seedCalendar(id: 'cal_write', name: 'Write');
      await service.confirmCalendarSelection(
        readableIds: ['cal_read', 'cal_write'],
        writableId: 'cal_write',
      );

      await repository.createEvent(
        MemyCalendarEvent(
          id: '',
          title: 'Goes to write cal',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 2, 9),
            endUtc: DateTime.utc(2026, 6, 2, 10),
          ),
          syncStatus: CalendarEventSyncStatus.pendingPush,
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      );
      await service.push();

      expect(gateway.eventsIn('cal_read'), isEmpty);
      expect(gateway.eventsIn('cal_write'), hasLength(1));
    });

    test('removes both local and external copies for pendingDelete', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      await confirm();
      final created = await repository.createEvent(
        MemyCalendarEvent(
          id: '',
          title: 'Temp event',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 2, 9),
            endUtc: DateTime.utc(2026, 6, 2, 10),
          ),
          syncStatus: CalendarEventSyncStatus.pendingPush,
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      );
      await service.push();
      final synced = await repository.getEvent(created.id);

      await repository.updateEvent(
        synced!.copyWith(syncStatus: CalendarEventSyncStatus.pendingDelete),
      );
      final result = await service.push();

      expect(result.deletedCount, 1);
      expect(await repository.getEvent(created.id), isNull);
      expect(gateway.eventsIn('cal_1'), isEmpty);
    });
  });

  group('repository guards', () {
    test('imported event updateEvent to pendingPush is rejected', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
        title: 'Dentist',
        time: TimedCalendarEventTime(
          startUtc: DateTime.utc(2026, 6, 1, 10),
          endUtc: DateTime.utc(2026, 6, 1, 11),
        ),
      );
      await confirm();
      await service.pull();
      final event = (await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      )).single;

      expect(
        () => repository.updateEvent(
          event.copyWith(
            title: 'Nope',
            syncStatus: CalendarEventSyncStatus.pendingPush,
          ),
        ),
        throwsA(isA<CalendarMutationException>()),
      );
    });
  });

  group('CalendarConfig.fromJson migration', () {
    test('maps selectedCalendarIds into readableCalendarIds', () {
      final config = CalendarConfig.fromJson({
        'calendarSchemaVersion': 1,
        'selectedCalendarIds': ['a', 'b'],
        'initialSyncAnchorPast': '2026-01-01T00:00:00.000Z',
      });
      expect(config.readableCalendarIds, ['a', 'b']);
      expect(config.calendarSchemaVersion, 2);
      expect(config.defaultWritableCalendarId, isNull);
    });
  });

  group('resolveConflict', () {
    test(
      'keepBoth preserves the local copy and creates a duplicate from the external snapshot',
      () async {
        gateway.seedCalendar(id: 'cal_1', name: 'Primary');
        final ext = gateway.seedEvent(
          calendarId: 'cal_1',
          externalEventId: 'ext_1',
          title: 'Dentist',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 1, 10),
            endUtc: DateTime.utc(2026, 6, 1, 11),
          ),
          lastModifiedUtc: clock.now(),
        );
        await confirm();
        await service.pull();

        final events = await repository.getEventsInRange(
          startUtc: DateTime.utc(2026, 1, 1),
          endUtc: DateTime.utc(2027, 1, 1),
        );
        await repository.updateEvent(
          events.single.copyWith(origin: CalendarEventOrigin.local),
        );
        await repository.updateEvent(
          events.single.copyWith(
            origin: CalendarEventOrigin.local,
            title: 'Dentist (moved)',
            syncStatus: CalendarEventSyncStatus.pendingPush,
          ),
        );
        gateway.simulateExternalEdit(
          calendarId: 'cal_1',
          externalEventId: ext.externalEventId,
          title: 'Dentist (renamed on phone)',
          lastModifiedUtc: clock.now().add(const Duration(minutes: 5)),
        );
        await service.pull();
        final conflict = (await repository.getConflicts()).single;

        await service.resolveConflict(
          conflictId: conflict.id,
          resolution: ConflictResolution.keepBoth,
        );

        final allEvents = await repository.getEventsInRange(
          startUtc: DateTime.utc(2026, 1, 1),
          endUtc: DateTime.utc(2027, 1, 1),
        );
        expect(allEvents, hasLength(2));
        expect(
          allEvents.map((e) => e.title),
          contains('Dentist (renamed on phone)'),
        );
        expect(
          allEvents
              .where((e) => e.syncStatus == CalendarEventSyncStatus.localOnly)
              .single
              .title,
          'Dentist (moved)',
        );
        final resolvedConflicts = await repository.getConflicts();
        expect(resolvedConflicts, isEmpty);
      },
    );
  });

  test('nextBatchCompleteness is consumed once', () async {
    gateway.seedCalendar(id: 'cal_1', name: 'Primary');
    gateway.nextBatchCompleteness = CalendarReadCompleteness.unknown;
    await confirm();
    final batch1 = await gateway.listEventBatch(
      calendarId: 'cal_1',
      startUtc: DateTime.utc(2026, 1, 1),
      endUtc: DateTime.utc(2027, 1, 1),
    );
    expect(batch1.completeness, CalendarReadCompleteness.unknown);
    final batch2 = await gateway.listEventBatch(
      calendarId: 'cal_1',
      startUtc: DateTime.utc(2026, 1, 1),
      endUtc: DateTime.utc(2027, 1, 1),
    );
    expect(batch2.completeness, CalendarReadCompleteness.complete);
  });
}
