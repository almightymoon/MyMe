import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/integrations/application/providers/integration_providers.dart';
import 'package:memy/features/calendar/application/services/calendar_sync_service.dart';
import 'package:memy/features/calendar/data/gateways/fake_device_calendar_gateway.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
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

  test('update outbox survives crash and reconciles on restart', () async {
    await connect();

    final created = await repository.createEvent(
      MemyCalendarEvent(
        id: '',
        title: 'Sync me',
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

    final synced = (await repository.getEvent(created.id))!;
    await repository.updateEvent(
      synced.copyWith(
        title: 'Updated title',
        syncStatus: CalendarEventSyncStatus.pendingPush,
      ),
    );

    // In-process provider throw is caught → unknownOutcome. Simulate process
    // death by restoring inFlight (catch never ran).
    gateway.crashAfterUpdate = true;
    await service.push();

    final afterCatch = await repository.getSyncOperationsForEvent(created.id);
    final updateOp = afterCatch.firstWhere(
      (o) => o.operationType == CalendarSyncOperationType.update,
    );
    expect(updateOp.state, CalendarSyncOperationState.unknownOutcome);

    await repository.updateSyncOperation(
      updateOp.copyWith(state: CalendarSyncOperationState.inFlight),
    );
    gateway.crashAfterUpdate = false;
    await service.reconcileInFlightOperations();

    final ops = await repository.getSyncOperationsForEvent(created.id);
    expect(
      ops.any((o) => o.state == CalendarSyncOperationState.completed),
      isTrue,
    );
  });

  test('delete outbox survives crash and reconciles when absent', () async {
    await connect();

    final created = await repository.createEvent(
      MemyCalendarEvent(
        id: '',
        title: 'Delete me',
        time: TimedCalendarEventTime(
          startUtc: DateTime.utc(2026, 6, 2, 11),
          endUtc: DateTime.utc(2026, 6, 2, 12),
        ),
        syncStatus: CalendarEventSyncStatus.pendingPush,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      ),
    );
    await service.push();

    final synced = (await repository.getEvent(created.id))!;
    await repository.updateEvent(
      synced.copyWith(syncStatus: CalendarEventSyncStatus.pendingDelete),
    );

    gateway.crashAfterDelete = true;
    await service.push();

    final afterCatch = await repository.getSyncOperationsForEvent(created.id);
    final deleteOp = afterCatch.firstWhere(
      (o) => o.operationType == CalendarSyncOperationType.delete,
    );
    expect(deleteOp.state, CalendarSyncOperationState.unknownOutcome);

    // Provider already deleted; restore inFlight as if process died mid-flight.
    await repository.updateSyncOperation(
      deleteOp.copyWith(state: CalendarSyncOperationState.inFlight),
    );
    gateway.crashAfterDelete = false;
    await service.reconcileInFlightOperations();

    expect(await repository.getEvent(created.id), isNull);
    final ops = await repository.getSyncOperationsForEvent(created.id);
    expect(
      ops.any((o) => o.state == CalendarSyncOperationState.completed),
      isTrue,
    );
  });
}
