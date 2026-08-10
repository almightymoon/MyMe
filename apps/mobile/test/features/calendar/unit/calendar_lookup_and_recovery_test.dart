import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/application/providers/integration_providers.dart';
import 'package:memy/core/integrations/domain/integration_connection_status.dart';
import 'package:memy/features/calendar/application/services/calendar_sync_service.dart';
import 'package:memy/features/calendar/data/gateways/fake_device_calendar_gateway.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_config.dart';
import 'package:memy/features/calendar/domain/entities/calendar_create_recovery_case.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_lookup_result.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/calendar_sync_operation.dart';
import 'package:memy/features/calendar/domain/entities/external_presence_status.dart';
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

  Future<void> connect() async {
    gateway.seedCalendar(id: 'cal_1', name: 'Primary');
    await service.confirmCalendarSelection(
      readableIds: const ['cal_1'],
      writableId: 'cal_1',
    );
  }

  group('typed lookup on pull', () {
    test('lookup unknown does not confirm deletion', () async {
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
      await connect();
      await service.pull();

      gateway.simulateExternalDelete(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
      );
      await service.pull();

      gateway.setLookupOverride(
        calendarId: 'cal_1',
        externalEventId: 'ext_1',
        result: CalendarEventLookupUnknown(
          sanitizedErrorCode: 'unknown',
          retryable: true,
          checkedAt: clock.now(),
        ),
      );

      final result = await service.pull();
      expect(result.deletedCount, 0);

      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2026, 1, 1),
        endUtc: DateTime.utc(2027, 1, 1),
      );
      expect(events, hasLength(1));
      final link = await repository.getLinkForEvent(events.single.id);
      expect(link!.presence, isNot(ExternalPresenceStatus.confirmedMissing));
      expect(
        link.presence,
        isNot(ExternalPresenceStatus.hiddenAfterExternalDeletion),
      );
      expect(
        link.presence,
        anyOf(
          ExternalPresenceStatus.suspectedMissing,
          ExternalPresenceStatus.lookupUnknown,
        ),
      );
      expect(
        link.lastLookupDisposition,
        CalendarEventLookupDisposition.unknown,
      );
    });
  });

  group('marker reconciliation', () {
    test('multiple marker matches never pick first arbitrarily', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      await connect();

      final local = await repository.createEvent(
        MemyCalendarEvent(
          id: 'evt_local',
          title: 'Ambiguous create',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 2, 9),
            endUtc: DateTime.utc(2026, 6, 2, 10),
          ),
          syncStatus: CalendarEventSyncStatus.pendingPush,
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      );

      final marker = CalendarSyncOperation.markerFor(local.id);
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'dup_a',
        title: 'A',
        time: local.time,
        url: marker,
      );
      gateway.seedEvent(
        calendarId: 'cal_1',
        externalEventId: 'dup_b',
        title: 'B',
        time: local.time,
        url: marker,
      );

      final op = CalendarSyncOperation(
        id: 'op_crash',
        memyEventId: local.id,
        operationType: CalendarSyncOperationType.create,
        targetCalendarId: 'cal_1',
        payloadFingerprint: 'fp',
        state: CalendarSyncOperationState.inFlight,
        attemptCount: 1,
        createdAt: clock.now(),
        memyMarker: marker,
        startedAt: clock.now(),
      );
      await repository.saveSyncOperation(op);

      await service.reconcileInFlightOperations();

      final updatedOp = await repository.getSyncOperation('op_crash');
      expect(updatedOp!.state, CalendarSyncOperationState.requiresUserAction);

      final cases = await repository.getRecoveryCasesForOperation('op_crash');
      expect(cases, hasLength(1));
      expect(
        cases.single.recoveryType,
        CalendarCreateRecoveryType.multipleMarkerMatches,
      );
      expect(cases.single.candidates, hasLength(2));

      final saved = await repository.getEvent(local.id);
      expect(saved!.syncStatus, isNot(CalendarEventSyncStatus.synced));
    });

    test('zero markers creates recovery case', () async {
      gateway.seedCalendar(id: 'cal_1', name: 'Primary');
      await connect();

      final local = await repository.createEvent(
        MemyCalendarEvent(
          id: 'evt_orphan',
          title: 'Lost create',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 3, 9),
            endUtc: DateTime.utc(2026, 6, 3, 10),
          ),
          syncStatus: CalendarEventSyncStatus.pendingPush,
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      );

      final marker = CalendarSyncOperation.markerFor(local.id);
      final op = CalendarSyncOperation(
        id: 'op_zero',
        memyEventId: local.id,
        operationType: CalendarSyncOperationType.create,
        targetCalendarId: 'cal_1',
        payloadFingerprint: 'fp',
        state: CalendarSyncOperationState.inFlight,
        attemptCount: 1,
        createdAt: clock.now(),
        memyMarker: marker,
        startedAt: clock.now(),
      );
      await repository.saveSyncOperation(op);

      await service.reconcileInFlightOperations();

      final updatedOp = await repository.getSyncOperation('op_zero');
      expect(updatedOp!.state, CalendarSyncOperationState.unknownOutcome);

      final cases = await repository.getRecoveryCasesForOperation('op_zero');
      expect(cases, hasLength(1));
      expect(
        cases.single.recoveryType,
        CalendarCreateRecoveryType.noMatchUnknownOutcome,
      );
    });
  });

  group('hydration', () {
    test('permission denied does not mark connected', () async {
      await repository.saveConfig(
        CalendarConfig(
          readableCalendarIds: const ['cal_1'],
          connectionConfiguredAt: clock.now(),
        ),
      );

      gateway.setPermissionsGranted(false);

      await service.hydrateConnectionFromPersistence();

      final connection = container.read(calendarConnectionProvider);
      expect(
        connection.status,
        IntegrationConnectionStatus.permissionStatusUnknown,
      );
      expect(connection.status, isNot(IntegrationConnectionStatus.connected));
      expect(connection.selectedCalendarIds, ['cal_1']);
    });

    test(
      'provider check exception yields stale cache, not connected',
      () async {
        await repository.saveConfig(
          CalendarConfig(
            readableCalendarIds: const ['cal_1'],
            connectionConfiguredAt: clock.now(),
          ),
        );

        gateway
          ..setPermissionsGranted(true)
          ..throwOnAvailabilityCheck = true;

        await service.hydrateConnectionFromPersistence();

        final connection = container.read(calendarConnectionProvider);
        expect(
          connection.status,
          IntegrationConnectionStatus.staleCacheAvailable,
        );
        expect(connection.status, isNot(IntegrationConnectionStatus.connected));
        expect(connection.selectedCalendarIds, ['cal_1']);
      },
    );
  });
}
