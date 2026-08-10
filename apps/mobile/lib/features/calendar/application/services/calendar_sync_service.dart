import 'dart:async';

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
import '../../domain/entities/calendar_read_batch.dart';
import '../../domain/entities/calendar_sync_conflict.dart';
import '../../domain/entities/calendar_sync_operation.dart';
import '../../domain/entities/conflict_resolution.dart';
import '../../domain/entities/device_calendar_descriptor.dart';
import '../../domain/entities/external_event_snapshot.dart';
import '../../domain/entities/external_presence_status.dart';
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

  /// Serializes pull/push/fullSync/manualRefresh so concurrent callers wait.
  Completer<void>? _syncGate;

  String _newId(String prefix) =>
      _idGenerator?.call() ??
      '${prefix}_${_clock.now().microsecondsSinceEpoch}';

  Future<T> _withSingleFlight<T>(Future<T> Function() action) async {
    while (_syncGate != null) {
      await _syncGate!.future;
    }
    final gate = Completer<void>();
    _syncGate = gate;
    try {
      return await action();
    } finally {
      _syncGate = null;
      gate.complete();
    }
  }

  void _setConnection(
    IntegrationConnectionStatus status, {
    IntegrationAvailability? availability,
    DateTime? connectedAt,
    IntegrationError? error,
    List<String>? selectedCalendarIds,
    bool clearError = false,
    bool clearConnectedAt = false,
  }) {
    registry.updateConnection(
      IntegrationProvider.calendar,
      (c) => c.copyWith(
        status: status,
        availability: availability,
        connectedAt: connectedAt,
        lastError: error,
        clearLastError: clearError,
        clearConnectedAt: clearConnectedAt,
        selectedCalendarIds: selectedCalendarIds,
      ),
    );
  }

  /// Restores registry state from durable config (app restart / bootstrap).
  Future<void> hydrateConnectionFromPersistence() async {
    final config = await repository.getConfig();
    final readable = config.effectiveReadableCalendarIds;
    if (!config.isConnectionConfigured) {
      _setConnection(
        IntegrationConnectionStatus.notConnected,
        selectedCalendarIds: const [],
        clearConnectedAt: true,
        clearError: true,
      );
      return;
    }

    var availability = IntegrationAvailability.unknown;
    try {
      availability = await gateway.checkAvailability();
      final permitted = await gateway.hasPermissions();
      if (!permitted) {
        _setConnection(
          IntegrationConnectionStatus.error,
          availability: availability,
          selectedCalendarIds: readable,
          connectedAt: config.connectionConfiguredAt,
          error: IntegrationError.permissionDenied(
            IntegrationProvider.calendar,
          ),
        );
        return;
      }
    } catch (_) {
      // Soft-fail hydration — still mark connected from persistence.
    }

    _setConnection(
      IntegrationConnectionStatus.connected,
      availability: availability == IntegrationAvailability.unknown
          ? IntegrationAvailability.available
          : availability,
      connectedAt: config.connectionConfiguredAt ?? _clock.now().toUtc(),
      selectedCalendarIds: readable,
      clearError: true,
    );

    await reconcileInFlightCreates();
  }

  /// Reconciles create ops left `inFlight` after a crash/restart.
  ///
  /// Finds the device event by memy marker when possible; otherwise marks
  /// [CalendarSyncOperationState.unknownOutcome] and does **not** auto-retry.
  Future<void> reconcileInFlightCreates() async {
    final ops = await repository.getInFlightOperations();
    final config = await repository.getConfig();
    final window = config.rollingWindow(_clock.now().toUtc());

    for (final op in ops) {
      if (op.operationType != CalendarSyncOperationType.create) {
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
        continue;
      }
      final marker = op.memyMarker;
      if (marker == null || marker.isEmpty) {
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
        continue;
      }

      try {
        final found = await gateway.findEventsByMemyMarker(
          calendarId: op.targetCalendarId,
          memyMarker: marker,
          startUtc: window.start,
          endUtc: window.end,
        );
        if (found.isEmpty) {
          await repository.updateSyncOperation(
            op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
          );
          continue;
        }

        final raw = found.first;
        final now = _clock.now().toUtc();
        final event = await repository.getEvent(op.memyEventId);
        if (event != null) {
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
          await repository.saveLink(
            (existingLink ??
                    CalendarEventLink(
                      id: _newId('cal_link'),
                      memyEventId: event.id,
                      provider: IntegrationProvider.calendar,
                      externalCalendarId: raw.externalCalendarId,
                      externalEventId: raw.externalEventId,
                      lastSyncedAt: now,
                      memyMarker: marker,
                    ))
                .copyWith(
                  lastSyncedAt: now,
                  lastKnownExternalUpdatedAt: raw.lastModifiedUtc,
                  presence: ExternalPresenceStatus.present,
                  lastSeenExternallyAt: now,
                  memyMarker: marker,
                  clearFirstMissing: true,
                  clearLastMissing: true,
                  missingObservationCount: 0,
                ),
          );
        }
        await repository.updateSyncOperation(
          op.copyWith(
            state: CalendarSyncOperationState.completed,
            providerExternalEventId: raw.externalEventId,
            completedAt: now,
          ),
        );
      } catch (_) {
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
      }
    }
  }

  /// Step 1 of the connect flow: probes availability, requests permission,
  /// and returns the device's calendars for the selection screen. Does **not**
  /// mark the connection as connected — call [confirmCalendarSelection] next.
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
      final now = _clock.now().toUtc();
      await repository.saveConfig(
        (await repository.getConfig()).copyWith(
          lastPermissionCheckAt: now,
          lastCalendarDiscoveryAt: now,
        ),
      );
      // Stay in connecting until the user confirms readable/writable picks.
      _setConnection(
        IntegrationConnectionStatus.connecting,
        availability: availability,
        clearError: true,
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

  /// Step 2: persists readable + writable destinations and marks connected.
  Future<void> confirmCalendarSelection({
    required List<String> readableIds,
    required String? writableId,
    String? dedicatedId,
  }) async {
    if (readableIds.isEmpty) {
      throw IntegrationError(
        provider: IntegrationProvider.calendar,
        code: IntegrationErrorCode.unknown,
        message: 'Choose at least one calendar to read.',
      );
    }

    if (writableId != null && writableId.isNotEmpty) {
      final writable = await gateway.verifyCalendarWritable(writableId);
      if (!writable) {
        throw IntegrationError(
          provider: IntegrationProvider.calendar,
          code: IntegrationErrorCode.notSupported,
          message:
              'The selected write calendar is read-only. '
              'Choose a writable calendar or create a MeMy calendar.',
        );
      }
    }

    final now = _clock.now().toUtc();
    final config = await repository.getConfig();
    final saved = config.copyWith(
      readableCalendarIds: readableIds,
      selectedCalendarIds: readableIds,
      defaultWritableCalendarId: (writableId == null || writableId.isEmpty)
          ? null
          : writableId,
      dedicatedMeMyCalendarId: (dedicatedId == null || dedicatedId.isEmpty)
          ? null
          : dedicatedId,
      connectionConfiguredAt: config.connectionConfiguredAt ?? now,
      calendarSchemaVersion: 2,
      clearWritableCalendarId: writableId == null || writableId.isEmpty,
      clearDedicatedMeMyCalendarId: dedicatedId == null || dedicatedId.isEmpty,
    );
    await repository.saveConfig(saved);

    _setConnection(
      IntegrationConnectionStatus.connected,
      availability: IntegrationAvailability.available,
      connectedAt: saved.connectionConfiguredAt ?? now,
      selectedCalendarIds: readableIds,
      clearError: true,
    );
  }

  Future<void> disconnect() async {
    final config = await repository.getConfig();
    await repository.saveConfig(
      config.copyWith(
        readableCalendarIds: const [],
        selectedCalendarIds: const [],
        clearWritableCalendarId: true,
        clearDedicatedMeMyCalendarId: true,
      ),
    );
    _setConnection(
      IntegrationConnectionStatus.notConnected,
      selectedCalendarIds: const [],
      clearConnectedAt: true,
      clearError: true,
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

  bool _overlapsBatch(
    MemyCalendarEvent event, {
    required DateTime start,
    required DateTime end,
  }) {
    return event.overlapsRange(startUtc: start, endUtc: end);
  }

  /// Pulls external events for readable calendars into the local cache.
  Future<SyncResult> pull({List<String>? calendarIds}) {
    return _withSingleFlight(() => _pullUnlocked(calendarIds: calendarIds));
  }

  Future<SyncResult> _pullUnlocked({List<String>? calendarIds}) async {
    final startedAt = _clock.now().toUtc();
    final config = await repository.getConfig();
    final ids = calendarIds ?? config.effectiveReadableCalendarIds;
    final window = config.rollingWindow(startedAt);
    final rangeStart = window.start;
    final rangeEnd = window.end;

    var pulled = 0;
    var deleted = 0;
    var conflicts = 0;

    for (final calendarId in ids) {
      late final CalendarReadBatch batch;
      try {
        batch = await gateway.listEventBatch(
          calendarId: calendarId,
          startUtc: rangeStart,
          endUtc: rangeEnd,
        );
      } on IntegrationError catch (e) {
        if (e.code == IntegrationErrorCode.permissionDenied) {
          // Do not advance missing observations when permissions fail.
          return SyncResult(
            provider: IntegrationProvider.calendar,
            startedAt: startedAt,
            finishedAt: _clock.now().toUtc(),
            pulledCount: pulled,
            deletedCount: deleted,
            conflictCount: conflicts,
            error: e,
          );
        }
        rethrow;
      }

      final externalById = {for (final e in batch.events) e.externalEventId: e};

      for (final ext in batch.events) {
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
              presence: ExternalPresenceStatus.present,
              lastSeenExternallyAt: now,
              lastCompleteQueryStart: rangeStart,
              lastCompleteQueryEnd: rangeEnd,
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
          continue;
        }

        // Reappear after suspected/confirmed missing.
        final restoredLink = link.copyWith(
          presence: ExternalPresenceStatus.present,
          lastSeenExternallyAt: now,
          lastCompleteQueryStart: rangeStart,
          lastCompleteQueryEnd: rangeEnd,
          clearFirstMissing: true,
          clearLastMissing: true,
          missingObservationCount: 0,
          hiddenLocally: false,
        );

        if (localEvent.syncStatus == CalendarEventSyncStatus.pendingPush ||
            localEvent.syncStatus == CalendarEventSyncStatus.pendingDelete) {
          if (!_externalChanged(ext, localEvent, link)) {
            await repository.saveLink(restoredLink);
            continue;
          }
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
          await repository.saveLink(restoredLink);
          conflicts++;
          continue;
        }

        if (!_externalChanged(ext, localEvent, link) &&
            localEvent.syncStatus != CalendarEventSyncStatus.hidden &&
            localEvent.syncStatus !=
                CalendarEventSyncStatus.externallyMissing) {
          await repository.saveLink(restoredLink);
          continue;
        }

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
          restoredLink.copyWith(
            lastSyncedAt: now,
            lastKnownExternalUpdatedAt: ext.lastModifiedUtc,
          ),
        );
        pulled++;
      }

      if (!batch.mayInferAbsences) {
        continue;
      }

      final existingLinks = await repository.getLinksForExternalCalendar(
        calendarId,
      );
      for (final link in existingLinks) {
        if (externalById.containsKey(link.externalEventId)) continue;
        if (link.hiddenLocally ||
            link.presence == ExternalPresenceStatus.confirmedMissing) {
          continue;
        }

        final localEvent = await repository.getEvent(link.memyEventId);
        if (localEvent == null) continue;

        // Only evaluate absence when the event overlaps the requested batch.
        if (!_overlapsBatch(
          localEvent,
          start: batch.requestedStart,
          end: batch.requestedEnd,
        )) {
          continue;
        }

        final now = _clock.now().toUtc();
        final nextCount = link.missingObservationCount + 1;

        if (nextCount == 1) {
          await repository.saveLink(
            link.copyWith(
              presence: ExternalPresenceStatus.suspectedMissing,
              firstMissingObservationAt: link.firstMissingObservationAt ?? now,
              lastMissingObservationAt: now,
              missingObservationCount: nextCount,
              lastCompleteQueryStart: batch.requestedStart,
              lastCompleteQueryEnd: batch.requestedEnd,
            ),
          );
          continue;
        }

        // Second (or later) miss — confirm with optional direct ID lookup.
        final direct = await gateway.getEventById(
          calendarId: calendarId,
          externalEventId: link.externalEventId,
        );
        if (direct != null) {
          await repository.saveLink(
            link.copyWith(
              presence: ExternalPresenceStatus.present,
              lastSeenExternallyAt: now,
              clearFirstMissing: true,
              clearLastMissing: true,
              missingObservationCount: 0,
            ),
          );
          continue;
        }

        await repository.saveLink(
          link.copyWith(
            presence: ExternalPresenceStatus.confirmedMissing,
            lastMissingObservationAt: now,
            missingObservationCount: nextCount,
            hiddenLocally: localEvent.origin == CalendarEventOrigin.external,
            lastCompleteQueryStart: batch.requestedStart,
            lastCompleteQueryEnd: batch.requestedEnd,
          ),
        );

        if (localEvent.origin == CalendarEventOrigin.external) {
          await repository.updateEvent(
            localEvent.copyWith(
              syncStatus: CalendarEventSyncStatus.hidden,
              updatedAt: now,
            ),
          );
        } else {
          await repository.updateEvent(
            localEvent.copyWith(
              syncStatus: CalendarEventSyncStatus.externallyMissing,
              updatedAt: now,
            ),
          );
        }
        deleted++;
      }
    }

    await repository.saveConfig(
      config.copyWith(lastSuccessfulPullAt: _clock.now().toUtc()),
    );

    return SyncResult(
      provider: IntegrationProvider.calendar,
      startedAt: startedAt,
      finishedAt: _clock.now().toUtc(),
      pulledCount: pulled,
      deletedCount: deleted,
      conflictCount: conflicts,
    );
  }

  String _payloadFingerprint(MemyCalendarEvent event) {
    return [
      event.title,
      event.notes ?? '',
      event.location ?? '',
      event.time.startUtc.toIso8601String(),
      event.time.endUtc.toIso8601String(),
      event.time.isAllDay.toString(),
    ].join('|');
  }

  /// Pushes local `pendingPush`/`pendingDelete` events to the writable calendar.
  Future<SyncResult> push({List<String>? calendarIds}) {
    return _withSingleFlight(() => _pushUnlocked(calendarIds: calendarIds));
  }

  Future<SyncResult> _pushUnlocked({List<String>? calendarIds}) async {
    final startedAt = _clock.now().toUtc();
    final config = await repository.getConfig();
    // Writable destination is explicit — never infer from readable order.
    final writableId = config.defaultWritableCalendarId;
    // calendarIds retained for API compat; ignored for write target selection.
    // ignore: unused_local_variable
    final _ = calendarIds;

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
        // Hard-delete only MeMy-owned rows (repository enforces).
        await repository.deleteEvent(event.id);
        deleted++;
        continue;
      }

      if (event.origin == CalendarEventOrigin.external) {
        // Imported events are read-only — never push mutations.
        continue;
      }

      final priorOps = await repository.getSyncOperationsForEvent(event.id);
      final hasUnknownCreate = priorOps.any(
        (o) =>
            o.operationType == CalendarSyncOperationType.create &&
            o.state == CalendarSyncOperationState.unknownOutcome,
      );
      if (hasUnknownCreate) {
        continue;
      }

      final targetCalendarId = event.externalCalendarId ?? writableId;
      if (targetCalendarId == null) continue;

      if (event.isLinkedToExternal) {
        final draft = DeviceCalendarEventDraft(
          externalEventId: event.externalEventId,
          externalCalendarId: targetCalendarId,
          title: event.title,
          notes: event.notes,
          location: event.location,
          time: event.time,
          reminderMinutes: event.reminderMinutes,
        );
        final raw = await gateway.updateEvent(draft);
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
        if (existingLink != null) {
          await repository.saveLink(
            existingLink.copyWith(
              lastSyncedAt: now,
              lastKnownExternalUpdatedAt: raw.lastModifiedUtc,
              presence: ExternalPresenceStatus.present,
              lastSeenExternallyAt: now,
            ),
          );
        }
        pushed++;
        continue;
      }

      // ---- create path with durable outbox ----
      final marker = CalendarSyncOperation.markerFor(event.id);
      var op = CalendarSyncOperation(
        id: _newId('cal_op'),
        memyEventId: event.id,
        operationType: CalendarSyncOperationType.create,
        targetCalendarId: targetCalendarId,
        payloadFingerprint: _payloadFingerprint(event),
        state: CalendarSyncOperationState.prepared,
        attemptCount: 0,
        createdAt: now,
        memyMarker: marker,
      );
      await repository.saveSyncOperation(op);

      op = op.copyWith(
        state: CalendarSyncOperationState.inFlight,
        attemptCount: op.attemptCount + 1,
        startedAt: now,
      );
      await repository.updateSyncOperation(op);

      try {
        final draft = DeviceCalendarEventDraft(
          externalCalendarId: targetCalendarId,
          title: event.title,
          notes: event.notes,
          location: event.location,
          time: event.time,
          url: marker,
          reminderMinutes: event.reminderMinutes,
        );
        final raw = await gateway.createEvent(draft);
        final completedAt = _clock.now().toUtc();

        await repository.updateEvent(
          event.copyWith(
            syncStatus: CalendarEventSyncStatus.synced,
            provider: IntegrationProvider.calendar,
            externalCalendarId: raw.externalCalendarId,
            externalEventId: raw.externalEventId,
            updatedAt: completedAt,
          ),
        );
        await repository.saveLink(
          CalendarEventLink(
            id: _newId('cal_link'),
            memyEventId: event.id,
            provider: IntegrationProvider.calendar,
            externalCalendarId: raw.externalCalendarId,
            externalEventId: raw.externalEventId,
            lastSyncedAt: completedAt,
            lastKnownExternalUpdatedAt: raw.lastModifiedUtc,
            presence: ExternalPresenceStatus.present,
            lastSeenExternallyAt: completedAt,
            memyMarker: marker,
          ),
        );
        await repository.updateSyncOperation(
          op.copyWith(
            state: CalendarSyncOperationState.completed,
            providerExternalEventId: raw.externalEventId,
            completedAt: completedAt,
          ),
        );
        pushed++;
      } catch (e) {
        // After inFlight, outcome is ambiguous — do not auto-retry creates.
        await repository.updateSyncOperation(
          op.copyWith(
            state: CalendarSyncOperationState.unknownOutcome,
            lastErrorCode: e is IntegrationError
                ? e.code.name
                : IntegrationErrorCode.unknown.name,
          ),
        );
      }
    }

    await repository.saveConfig(
      config.copyWith(lastSuccessfulPushAt: _clock.now().toUtc()),
    );

    return SyncResult(
      provider: IntegrationProvider.calendar,
      startedAt: startedAt,
      finishedAt: _clock.now().toUtc(),
      pushedCount: pushed,
      deletedCount: deleted,
    );
  }

  /// Pull then push, merged into one result.
  Future<SyncResult> fullSync({List<String>? calendarIds}) {
    return _withSingleFlight(() async {
      final pullResult = await _pullUnlocked(calendarIds: calendarIds);
      final pushResult = await _pushUnlocked(calendarIds: calendarIds);
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
    });
  }

  Future<SyncResult> performInitialSync({List<String>? calendarIds}) {
    return fullSync(calendarIds: calendarIds);
  }

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
          presence: ExternalPresenceStatus.present,
          lastSeenExternallyAt: now,
        ),
      );
    }
  }
}
