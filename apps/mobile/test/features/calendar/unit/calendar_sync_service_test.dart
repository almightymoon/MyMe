import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/application/providers/integration_providers.dart';
import 'package:memy/core/integrations/domain/integration_availability.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/features/calendar/application/services/calendar_sync_service.dart';
import 'package:memy/features/calendar/data/gateways/fake_device_calendar_gateway.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_origin.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/conflict_resolution.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';

void main() {
  late ProviderContainer container;
  late FakeDeviceCalendarGateway gateway;
  late FakeCalendarRepository repository;
  late CalendarSyncService service;
  late FixedAppClock clock;
  var idSeq = 0;

  setUp(() {
    idSeq = 0;
    clock = FixedAppClock(DateTime.utc(2026, 6, 1, 8));
    container = ProviderContainer();
    gateway = FakeDeviceCalendarGateway(permissionsGranted: true);
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
    test('marks the connection connected on success', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary', isDefault: true);

      final calendars = await service.beginConnection();

      expect(calendars, hasLength(1));
      final connection = container.read(calendarConnectionProvider);
      expect(connection.status, IntegrationConnectionStatus.connected);
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
    test('persists selected calendars and freezes the sync anchors', () async {
      await service.confirmCalendarSelection(['cal_1']);
      final config = await repository.getConfig();
      expect(config.selectedCalendarIds, ['cal_1']);
      expect(
        config.initialSyncAnchorPast,
        clock.now().subtract(const Duration(days: 30)),
      );
      expect(
        config.initialSyncAnchorFuture,
        clock.now().add(const Duration(days: 365)),
      );
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
      await service.confirmCalendarSelection(['cal_1']);

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
    });

    test('mirrors external deletions locally', () async {
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
      await service.confirmCalendarSelection(['cal_1']);
      await service.pull();

      gateway.simulateExternalDelete(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
      );
      final result = await service.pull();

      expect(result.deletedCount, 1);
      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(events, isEmpty);
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
        await service.confirmCalendarSelection(['cal_1']);
        await service.pull();

        final events = await repository.getEventsInRange(
          startUtc: DateTime.utc(2026, 1, 1),
          endUtc: DateTime.utc(2027, 1, 1),
        );
        final local = events.single;
        await repository.updateEvent(
          local.copyWith(
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
        await service.confirmCalendarSelection(['cal_1']);

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
      },
    );

    test('removes both local and external copies for pendingDelete', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      await service.confirmCalendarSelection(['cal_1']);
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
        await service.confirmCalendarSelection(['cal_1']);
        await service.pull();

        final events = await repository.getEventsInRange(
          startUtc: DateTime.utc(2026, 1, 1),
          endUtc: DateTime.utc(2027, 1, 1),
        );
        final local = events.single;
        await repository.updateEvent(
          local.copyWith(
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
}
