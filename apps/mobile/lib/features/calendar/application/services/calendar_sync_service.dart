import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/integrations/application/providers/integration_providers.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_connection_status.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../../../core/integrations/domain/sync_result.dart';
import '../../domain/entities/calendar_event_link.dart';
import '../../domain/entities/calendar_event_origin.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/calendar_sync_conflict.dart';
import '../../domain/entities/conflict_resolution.dart';
import '../../domain/entities/device_calendar_descriptor.dart';
import '../../domain/entities/external_event_snapshot.dart';
import '../../domain/entities/memy_calendar_event.dart';
import '../../domain/gateways/device_calendar_gateway.dart';
import '../../domain/repositories/calendar_repository.dart';

/// Orchestrates connect → pull → push → conflict-resolution between a
/// [DeviceCalendarGateway] (the device/plugin side) and a
/// [CalendarRepository] (MeMy's durable cache).
///
/// This is the *only* place calendar sync policy lives — screens/providers
/// call into it rather than reimplementing diffing logic.
class CalendarSyncService {
  CalendarSyncService({
    required this.gateway,
    required this.repository,
    required this.registry,
    AppClock? clock,
    this._idGenerator,
  }) : _clock = clock ?? const SystemAppClock();

  final DeviceCalendarGateway gateway;
  final CalendarRepository repository;
  final IntegrationConnectionRegistry registry;
  final AppClock _clock;
  final String Function()? _idGenerator;

  static const Duration defaultPastWindow = Duration(days: 30);
  static const Duration defaultFutureWindow = Duration(days: 365);

  String _newId(String prefix) =>
      _idGenerator?.call() ??
      '${prefix}_${_clock.now().microsecondsSinceEpoch}';

  void _setConnection(
    IntegrationConnectionStatus status, {
    IntegrationAvailability? availability,
    DateTime? connectedAt,
    IntegrationError? error,
    bool clearError = false,
  }) {
    registry.updateConnection(
      IntegrationProvider.calendar,
      (c) => c.copyWith(
        status: status,
        availability: availability,
        connectedAt: connectedAt,
        lastError: error,
        clearLastError: clearError,
      ),
    );
  }

  /// Step 1 of the connect flow: probes availability, requests permission,
  /// and returns the device's calendars for the selection screen. Does not
  /// persist a calendar selection — call [confirmCalendarSelection] next.
  Future<List<DeviceCalendarDescriptor>> beginConnection() async {
    _setConnection(IntegrationConnectionStatus.connecting, clearError: true);
    try {
      final availability = await gateway.checkAvailability();
      if (availability != IntegrationAvailability.available) {
        final error = IntegrationError.unavailable(
          IntegrationProvider.calendar,
          'Calendar access is not available on this device.',
        );
        _setConnection(
          IntegrationConnectionStatus.error,
          availability: availability,
          error: error,
        );
        throw error;
      }

      final granted = await gateway.requestPermissions();
      if (!granted) {
        final error = IntegrationError.permissionDenied(
          IntegrationProvider.calendar,
        );
        _setConnection(
          IntegrationConnectionStatus.error,
          availability: availability,
          error: error,
        );
        throw error;
      }

      final calendars = await gateway.listCalendars();
      _setConnection(
        IntegrationConnectionStatus.connected,
        availability: availability,
        connectedAt: _clock.now().toUtc(),
      );
      return calendars;
    } on IntegrationError {
      rethrow;
    } catch (e) {
      final error = IntegrationError.unknown(
        IntegrationProvider.calendar,
        null,
        e,
      );
      _setConnection(IntegrationConnectionStatus.error, error: error);
      throw error;
    }
  }

  /// Step 2: persists which device calendars to sync and freezes the
  /// initial sync window (past 30 / future 365 days from now).
  Future<void> confirmCalendarSelection(List<String> calendarIds) async {
    final now = _clock.now().toUtc();
    final config = await repository.getConfig();
    final next = config.copyWith(
      selectedCalendarIds: calendarIds,
      initialSyncAnchorPast:
          config.initialSyncAnchorPast ?? now.subtract(defaultPastWindow),
      initialSyncAnchorFuture:
          config.initialSyncAnchorFuture ?? now.add(defaultFutureWindow),
    );
    await repository.saveConfig(next);
    registry.updateConnection(
      IntegrationProvider.calendar,
      (c) => c.copyWith(selectedCalendarIds: calendarIds),
    );
  }

  Future<void> disconnect() async {
    final config = await repository.getConfig();
    await repository.saveConfig(config.copyWith(selectedCalendarIds: const []));
    registry.updateConnection(
      IntegrationProvider.calendar,
      (c) => c.copyWith(
        status: IntegrationConnectionStatus.notConnected,
        selectedCalendarIds: const [],
        clearConnectedAt: true,
        clearLastError: true,
      ),
    );
  }

  bool _externalChanged(
    DeviceCalendarRawEvent ext,
    MemyCalendarEvent local,
    CalendarEventLink link,
  ) {
    final knownUpdatedAt = link.lastKnownExternalUpdatedAt;
    if (ext.lastModifiedUtc != null && knownUpdatedAt != null) {
      return ext.lastModifiedUtc!.isAfter(knownUpdatedAt);
    }
    return ext.title != local.title ||
        ext.notes != local.notes ||
        ext.location != local.location ||
        ext.time != local.time;
  }

  /// Pulls external events for [calendarIds] (default: the persisted
  /// selection) into the local cache, creating/updating/deleting local
  /// events and flagging [CalendarSyncConflict]s when a locally-edited
  /// event also changed externally.
  Future<SyncResult> pull({List<String>? calendarIds}) async {
    final startedAt = _clock.now().toUtc();
    final config = await repository.getConfig();
    final ids = calendarIds ?? config.selectedCalendarIds;
    final rangeStart =
        config.initialSyncAnchorPast ?? startedAt.subtract(defaultPastWindow);
    final rangeEnd =
        config.initialSyncAnchorFuture ?? startedAt.add(defaultFutureWindow);

    var pulled = 0;
    var deleted = 0;
    var conflicts = 0;

    for (final calendarId in ids) {
      final external = await gateway.listEvents(
        calendarId: calendarId,
        startUtc: rangeStart,
        endUtc: rangeEnd,
      );
      final externalById = {for (final e in external) e.externalEventId: e};

      for (final ext in external) {
        final link = await repository.getLinkByExternalId(
          externalCalendarId: calendarId,
          externalEventId: ext.externalEventId,
        );
        final now = _clock.now().toUtc();

        if (link == null) {
          final event = MemyCalendarEvent(
            id: _newId('cal_evt'),
            title: ext.title,
            notes: ext.notes,
            location: ext.location,
            time: ext.time,
            origin: CalendarEventOrigin.external,
            syncStatus: CalendarEventSyncStatus.synced,
            provider: IntegrationProvider.calendar,
            externalCalendarId: calendarId,
            externalEventId: ext.externalEventId,
            createdAt: now,
            updatedAt: now,
          );
          await repository.createEvent(event);
          await repository.saveLink(
            CalendarEventLink(
              id: _newId('cal_link'),
              memyEventId: event.id,
              provider: IntegrationProvider.calendar,
              externalCalendarId: calendarId,
              externalEventId: ext.externalEventId,
              lastSyncedAt: now,
              lastKnownExternalUpdatedAt: ext.lastModifiedUtc,
            ),
          );
          pulled++;
          continue;
        }

        final localEvent = await repository.getEvent(link.memyEventId);
        if (localEvent == null) {
          await repository.deleteLink(link.id);
          continue;
        }

        if (localEvent.syncStatus == CalendarEventSyncStatus.conflict) {
          continue; // Awaiting user resolution — don't pile on more changes.
        }

        if (localEvent.syncStatus == CalendarEventSyncStatus.pendingPush ||
            localEvent.syncStatus == CalendarEventSyncStatus.pendingDelete) {
          if (!_externalChanged(ext, localEvent, link)) continue;
          await repository.addConflict(
            CalendarSyncConflict(
              id: _newId('cal_conflict'),
              memyEventId: localEvent.id,
              linkId: link.id,
              localSnapshot: localEvent,
              externalSnapshot: ExternalEventSnapshot(
                title: ext.title,
                notes: ext.notes,
                location: ext.location,
                time: ext.time,
                lastModifiedUtc: ext.lastModifiedUtc,
              ),
              detectedAt: now,
            ),
          );
          await repository.updateEvent(
            localEvent.copyWith(
              syncStatus: CalendarEventSyncStatus.conflict,
              updatedAt: now,
            ),
          );
          conflicts++;
          continue;
        }

        if (!_externalChanged(ext, localEvent, link)) continue;
        await repository.updateEvent(
          localEvent.copyWith(
            title: ext.title,
            notes: ext.notes,
            location: ext.location,
            time: ext.time,
            clearNotes: ext.notes == null,
            clearLocation: ext.location == null,
            syncStatus: CalendarEventSyncStatus.synced,
            updatedAt: now,
          ),
        );
        await repository.saveLink(
          link.copyWith(
            lastSyncedAt: now,
            lastKnownExternalUpdatedAt: ext.lastModifiedUtc,
          ),
        );
        pulled++;
      }

      // Anything still linked to this calendar but no longer present
      // externally was deleted on the device — mirror that locally.
      final existingLinks = await repository.getLinksForExternalCalendar(
        calendarId,
      );
      for (final link in existingLinks) {
        if (externalById.containsKey(link.externalEventId)) continue;
        await repository.deleteEvent(link.memyEventId);
        await repository.deleteLink(link.id);
        deleted++;
      }
    }

    return SyncResult(
      provider: IntegrationProvider.calendar,
      startedAt: startedAt,
      finishedAt: _clock.now().toUtc(),
      pulledCount: pulled,
      deletedCount: deleted,
      conflictCount: conflicts,
    );
  }

  /// Pushes local `pendingPush`/`pendingDelete` events to their external
  /// calendar (creating the external event on first push).
  Future<SyncResult> push({List<String>? calendarIds}) async {
    final startedAt = _clock.now().toUtc();
    final config = await repository.getConfig();
    final ids = calendarIds ?? config.selectedCalendarIds;

    var pushed = 0;
    var deleted = 0;

    final pending = await repository.getPendingSyncEvents();
    for (final event in pending) {
      final now = _clock.now().toUtc();

      if (event.syncStatus == CalendarEventSyncStatus.pendingDelete) {
        if (event.isLinkedToExternal) {
          await gateway.deleteEvent(
            calendarId: event.externalCalendarId!,
            externalEventId: event.externalEventId!,
          );
          final link = await repository.getLinkForEvent(event.id);
          if (link != null) await repository.deleteLink(link.id);
        }
        await repository.deleteEvent(event.id);
        deleted++;
        continue;
      }

      final targetCalendarId =
          event.externalCalendarId ?? (ids.isNotEmpty ? ids.first : null);
      if (targetCalendarId == null) continue;

      final draft = DeviceCalendarEventDraft(
        externalEventId: event.externalEventId,
        externalCalendarId: targetCalendarId,
        title: event.title,
        notes: event.notes,
        location: event.location,
        time: event.time,
      );
      final raw = event.isLinkedToExternal
          ? await gateway.updateEvent(draft)
          : await gateway.createEvent(draft);

      await repository.updateEvent(
        event.copyWith(
          syncStatus: CalendarEventSyncStatus.synced,
          provider: IntegrationProvider.calendar,
          externalCalendarId: raw.externalCalendarId,
          externalEventId: raw.externalEventId,
          updatedAt: now,
        ),
      );

      final existingLink = await repository.getLinkForEvent(event.id);
      final link =
          (existingLink ??
                  CalendarEventLink(
                    id: _newId('cal_link'),
                    memyEventId: event.id,
                    provider: IntegrationProvider.calendar,
                    externalCalendarId: raw.externalCalendarId,
                    externalEventId: raw.externalEventId,
                    lastSyncedAt: now,
                  ))
              .copyWith(
                lastSyncedAt: now,
                lastKnownExternalUpdatedAt: raw.lastModifiedUtc,
              );
      await repository.saveLink(link);
      pushed++;
    }

    return SyncResult(
      provider: IntegrationProvider.calendar,
      startedAt: startedAt,
      finishedAt: _clock.now().toUtc(),
      pushedCount: pushed,
      deletedCount: deleted,
    );
  }

  /// Pull then push, merged into one result. This is what "sync now" /
  /// the throttled foreground refresh hook calls.
  Future<SyncResult> fullSync({List<String>? calendarIds}) async {
    final pullResult = await pull(calendarIds: calendarIds);
    final pushResult = await push(calendarIds: calendarIds);
    final merged = pullResult
        .merge(pushResult)
        .copyWith(finishedAt: _clock.now().toUtc());

    final config = await repository.getConfig();
    await repository.saveConfig(
      config.copyWith(lastFullSyncAt: merged.finishedAt),
    );
    registry.updateConnection(
      IntegrationProvider.calendar,
      (c) => c.copyWith(lastSyncAt: merged.finishedAt),
    );
    return merged;
  }

  /// Runs the full initial import right after [confirmCalendarSelection].
  Future<SyncResult> performInitialSync({List<String>? calendarIds}) {
    return fullSync(calendarIds: calendarIds);
  }

  /// Explicit user-triggered "Sync now" — same as [fullSync], named for
  /// call-site clarity (never throttled, unlike the foreground hook).
  Future<SyncResult> manualRefresh() => fullSync();

  Future<void> resolveConflict({
    required String conflictId,
    required ConflictResolution resolution,
  }) async {
    final conflict = await repository.getConflict(conflictId);
    if (conflict == null) return;
    final now = _clock.now().toUtc();
    final ext = conflict.externalSnapshot;

    switch (resolution) {
      case ConflictResolution.keepLocal:
        await repository.updateEvent(
          conflict.localSnapshot.copyWith(
            syncStatus: CalendarEventSyncStatus.pendingPush,
            updatedAt: now,
          ),
        );
      case ConflictResolution.keepExternal:
        await _overwriteWithExternal(conflict, ext, now);
      case ConflictResolution.keepBoth:
        await _overwriteWithExternal(conflict, ext, now);
        final duplicate = MemyCalendarEvent(
          id: _newId('cal_evt'),
          title: conflict.localSnapshot.title,
          notes: conflict.localSnapshot.notes,
          location: conflict.localSnapshot.location,
          time: conflict.localSnapshot.time,
          origin: CalendarEventOrigin.local,
          syncStatus: CalendarEventSyncStatus.localOnly,
          createdAt: now,
          updatedAt: now,
        );
        await repository.createEvent(duplicate);
    }

    await repository.markConflictResolved(
      conflictId: conflictId,
      resolution: resolution,
    );
  }

  Future<void> _overwriteWithExternal(
    CalendarSyncConflict conflict,
    ExternalEventSnapshot ext,
    DateTime now,
  ) async {
    await repository.updateEvent(
      conflict.localSnapshot.copyWith(
        title: ext.title,
        notes: ext.notes,
        location: ext.location,
        time: ext.time,
        clearNotes: ext.notes == null,
        clearLocation: ext.location == null,
        syncStatus: CalendarEventSyncStatus.synced,
        updatedAt: now,
      ),
    );
    final link = await repository.getLinkForEvent(conflict.memyEventId);
    if (link != null) {
      await repository.saveLink(
        link.copyWith(
          lastSyncedAt: now,
          lastKnownExternalUpdatedAt: ext.lastModifiedUtc,
        ),
      );
    }
  }
}
