import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/environment_config.dart';
import '../../../../core/data/fake_repository_config.dart';
import '../../../../core/integrations/application/providers/integration_providers.dart';
import '../../data/gateways/fake_device_calendar_gateway.dart';
import '../../data/gateways/system_device_calendar_gateway.dart';
import '../../data/local/calendar_database.dart';
import '../../data/repositories/fake_calendar_repository.dart';
import '../../data/repositories/local_calendar_repository.dart';
import '../../domain/entities/calendar_config.dart';
import '../../domain/entities/calendar_sync_conflict.dart';
import '../../domain/entities/memy_calendar_event.dart';
import '../../domain/gateways/device_calendar_gateway.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../services/calendar_integration_bootstrap_service.dart';
import '../services/calendar_sync_service.dart';

/// Override in tests to force `fake`/`system` without dart-defines.
final calendarDataSourceProvider = Provider<CalendarDataSource>((ref) {
  return EnvironmentConfig.calendarDataSource;
});

/// Only constructed (and only ever touched) in `system` mode — `fake` mode
/// never opens SQLite, keeping widget tests plugin-free by default.
final calendarDatabaseProvider = Provider<CalendarDatabase>((ref) {
  final db = CalendarDatabase();
  ref.onDispose(db.close);
  return db;
});

final deviceCalendarGatewayProvider = Provider<DeviceCalendarGateway>((ref) {
  switch (ref.watch(calendarDataSourceProvider)) {
    case CalendarDataSource.fake:
      return FakeDeviceCalendarGateway();
    case CalendarDataSource.system:
      return SystemDeviceCalendarGateway();
  }
});

final localCalendarRepositoryProvider = Provider<LocalCalendarRepository>((
  ref,
) {
  return LocalCalendarRepository(
    database: ref.watch(calendarDatabaseProvider),
    clock: ref.watch(appClockProvider),
    idGenerator: () => ref.read(uuidProvider).v4(),
  );
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  switch (ref.watch(calendarDataSourceProvider)) {
    case CalendarDataSource.fake:
      final repo = FakeCalendarRepository(
        clock: ref.watch(appClockProvider),
        config: ref.watch(fakeRepositoryConfigProvider),
      );
      ref.onDispose(repo.dispose);
      return repo;
    case CalendarDataSource.system:
      return ref.watch(localCalendarRepositoryProvider);
  }
});

final calendarSyncServiceProvider = Provider<CalendarSyncService>((ref) {
  return CalendarSyncService(
    gateway: ref.watch(deviceCalendarGatewayProvider),
    repository: ref.watch(calendarRepositoryProvider),
    registry: ref.watch(integrationConnectionRegistryProvider.notifier),
    clock: ref.watch(appClockProvider),
    idGenerator: () => ref.read(uuidProvider).v4(),
  );
});

final calendarIntegrationBootstrapProvider =
    Provider<CalendarIntegrationBootstrapService>((ref) {
      return CalendarIntegrationBootstrapService(
        gateway: ref.watch(deviceCalendarGatewayProvider),
        repository: ref.watch(calendarRepositoryProvider),
        syncService: ref.watch(calendarSyncServiceProvider),
        registry: ref.watch(integrationConnectionRegistryProvider.notifier),
      );
    });

/// Runs once per app process after providers are ready.
final calendarBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.watch(calendarIntegrationBootstrapProvider).bootstrap();
});

final calendarConfigProvider = FutureProvider.autoDispose<CalendarConfig>((
  ref,
) {
  return ref.watch(calendarRepositoryProvider).getConfig();
});

/// Half-open UTC range `[startUtc, endUtc)` — hashable for provider families.
class CalendarDateRange {
  const CalendarDateRange({required this.startUtc, required this.endUtc});

  final DateTime startUtc;
  final DateTime endUtc;

  @override
  bool operator ==(Object other) =>
      other is CalendarDateRange &&
      other.startUtc == startUtc &&
      other.endUtc == endUtc;

  @override
  int get hashCode => Object.hash(startUtc, endUtc);
}

final calendarEventsInRangeProvider = StreamProvider.autoDispose
    .family<List<MemyCalendarEvent>, CalendarDateRange>((ref, range) {
      return ref
          .watch(calendarRepositoryProvider)
          .watchEventsInRange(startUtc: range.startUtc, endUtc: range.endUtc);
    });

final calendarEventByIdProvider = FutureProvider.autoDispose
    .family<MemyCalendarEvent?, String>((ref, id) {
      return ref.watch(calendarRepositoryProvider).getEvent(id);
    });

final calendarConflictsProvider =
    StreamProvider.autoDispose<List<CalendarSyncConflict>>((ref) {
      return ref.watch(calendarRepositoryProvider).watchConflicts();
    });

/// Throttles the "sync on app foreground" hook so re-entering the app
/// repeatedly doesn't hammer the device calendar / external provider.
class CalendarForegroundRefreshController extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  static const Duration throttle = Duration(minutes: 5);

  /// Runs a sync if [connection] is connected and the throttle window has
  /// elapsed; otherwise no-ops. Safe to call on every app-resume.
  Future<void> maybeRefresh() async {
    final connected = ref.read(calendarConnectionProvider).isConnected;
    if (!connected) return;

    final now = ref.read(appClockProvider).now().toUtc();
    final last = state;
    if (last != null && now.difference(last) < throttle) return;

    state = now;
    await ref.read(calendarSyncServiceProvider).fullSync();
  }
}

final calendarForegroundRefreshProvider =
    NotifierProvider<CalendarForegroundRefreshController, DateTime?>(
      CalendarForegroundRefreshController.new,
    );
