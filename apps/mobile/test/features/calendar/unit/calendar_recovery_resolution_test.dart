import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/application/providers/integration_providers.dart';
import 'package:memy/features/calendar/application/services/calendar_sync_service.dart';
import 'package:memy/features/calendar/data/gateways/fake_device_calendar_gateway.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_create_recovery_case.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/calendar_sync_operation.dart';
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

  Future<(MemyCalendarEvent, CalendarSyncOperation, CalendarCreateRecoveryCase)>
  seedMultipleMatchRecovery() async {
    await connect();
    final local = await repository.createEvent(
      MemyCalendarEvent(
        id: 'evt_multi',
        title: 'Ambiguous',
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
      id: 'op_multi',
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
    final cases = await repository.getRecoveryCasesForOperation('op_multi');
    return (
      local,
      (await repository.getSyncOperation('op_multi'))!,
      cases.single,
    );
  }

  Future<(MemyCalendarEvent, CalendarSyncOperation, CalendarCreateRecoveryCase)>
  seedZeroMatchRecovery() async {
    await connect();
    final local = await repository.createEvent(
      MemyCalendarEvent(
        id: 'evt_zero',
        title: 'Orphan create',
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
    final cases = await repository.getRecoveryCasesForOperation('op_zero');
    return (
      local,
      (await repository.getSyncOperation('op_zero'))!,
      cases.single,
    );
  }

  group('create recovery resolution', () {
    test(
      'multiple matches → link one candidate resolves and completes op',
      () async {
        final (_, _, recovery) = await seedMultipleMatchRecovery();
        final chosen = recovery.candidates.firstWhere(
          (c) => c.externalEventId == 'dup_b',
        );

        await service.linkCreateRecoveryCandidate(
          recoveryCaseId: recovery.id,
          externalEventId: chosen.externalEventId,
          externalCalendarId: chosen.externalCalendarId,
        );

        final updatedCase = await repository.getRecoveryCase(recovery.id);
        expect(updatedCase!.status, CalendarCreateRecoveryStatus.resolved);

        final op = await repository.getSyncOperation('op_multi');
        expect(op!.state, CalendarSyncOperationState.completed);
        expect(op.providerExternalEventId, 'dup_b');

        final event = await repository.getEvent('evt_multi');
        expect(event!.syncStatus, CalendarEventSyncStatus.synced);
        expect(event.externalEventId, 'dup_b');

        final unresolved = await service.listUnresolvedRecoveryCases();
        expect(unresolved, isEmpty);
      },
    );

    test('multiple matches never auto-picks first on search again', () async {
      final (_, _, recovery) = await seedMultipleMatchRecovery();

      await service.searchAgainCreateRecovery(recovery.id);

      final updated = await repository.getRecoveryCase(recovery.id);
      expect(updated!.status, CalendarCreateRecoveryStatus.unresolved);
      expect(
        updated.recoveryType,
        CalendarCreateRecoveryType.multipleMarkerMatches,
      );
      expect(updated.candidates, hasLength(2));

      final event = await repository.getEvent('evt_multi');
      expect(event!.syncStatus, isNot(CalendarEventSyncStatus.synced));
      expect(event.externalEventId, isNull);
    });

    test('zero match → search again still zero stays unresolved', () async {
      final (_, _, recovery) = await seedZeroMatchRecovery();

      await service.searchAgainCreateRecovery(recovery.id);

      final updated = await repository.getRecoveryCase(recovery.id);
      expect(updated!.status, CalendarCreateRecoveryStatus.unresolved);
      expect(
        updated.recoveryType,
        CalendarCreateRecoveryType.noMatchUnknownOutcome,
      );
      expect(updated.candidates, isEmpty);

      final op = await repository.getSyncOperation('op_zero');
      expect(op!.state, CalendarSyncOperationState.unknownOutcome);
    });

    test('zero match → keep local only resolves', () async {
      final (_, _, recovery) = await seedZeroMatchRecovery();

      await service.keepCreateRecoveryLocalOnly(recovery.id);

      final updated = await repository.getRecoveryCase(recovery.id);
      expect(updated!.status, CalendarCreateRecoveryStatus.resolved);

      final op = await repository.getSyncOperation('op_zero');
      expect(op!.state, CalendarSyncOperationState.permanentlyFailed);

      final event = await repository.getEvent('evt_zero');
      expect(event!.syncStatus, CalendarEventSyncStatus.localOnly);
      expect(event.externalEventId, isNull);
    });

    test('zero match → retry after confirmation sets op prepared', () async {
      final (_, _, recovery) = await seedZeroMatchRecovery();

      await service.retryCreateAfterConfirmation(recovery.id);

      final updated = await repository.getRecoveryCase(recovery.id);
      expect(updated!.status, CalendarCreateRecoveryStatus.resolved);

      final op = await repository.getSyncOperation('op_zero');
      expect(op!.state, CalendarSyncOperationState.prepared);
    });

    test('dismiss works', () async {
      final (_, _, recovery) = await seedZeroMatchRecovery();

      await service.dismissCreateRecovery(recovery.id);

      final updated = await repository.getRecoveryCase(recovery.id);
      expect(updated!.status, CalendarCreateRecoveryStatus.dismissed);
      expect(updated.dismissedAt, isNotNull);

      final unresolved = await service.listUnresolvedRecoveryCases();
      expect(unresolved, isEmpty);
    });
  });
}
