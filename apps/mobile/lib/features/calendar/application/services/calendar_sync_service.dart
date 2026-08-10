import 'dart:async';

import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/integrations/application/providers/integration_providers.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_connection_status.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../../../core/integrations/domain/sync_result.dart';
import '../../domain/entities/calendar_config.dart';
import '../../domain/entities/calendar_create_recovery_case.dart';
import '../../domain/entities/calendar_event_link.dart';
import '../../domain/entities/calendar_event_lookup_result.dart';
import '../../domain/entities/calendar_event_origin.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/calendar_event_time.dart';
import '../../domain/entities/calendar_marker_search_result.dart';
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
  ///
  /// Never reports [IntegrationConnectionStatus.connected] after a failed
  /// provider check. Cached agenda may remain visible under
  /// [IntegrationConnectionStatus.staleCacheAvailable].
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
      if (availability == IntegrationAvailability.unavailable) {
        _setConnection(
          IntegrationConnectionStatus.providerUnavailable,
          availability: availability,
          selectedCalendarIds: readable,
          connectedAt: config.connectionConfiguredAt,
          error: IntegrationError.unavailable(IntegrationProvider.calendar),
        );
        return;
      }

      final permitted = await gateway.hasPermissions();
      if (!permitted) {
        _setConnection(
          IntegrationConnectionStatus.permissionStatusUnknown,
          availability: availability,
          selectedCalendarIds: readable,
          connectedAt: config.connectionConfiguredAt,
          error: IntegrationError.permissionDenied(
            IntegrationProvider.calendar,
          ),
        );
        return;
      }

      // Validate readable IDs still exist when the provider can list them.
      final calendars = await gateway.listCalendars();
      final knownIds = calendars.map((c) => c.id).toSet();
      final validReadable = readable.where(knownIds.contains).toList();
      final writableId = config.defaultWritableCalendarId;
      final writableValid =
          writableId != null &&
          knownIds.contains(writableId) &&
          calendars.any((c) => c.id == writableId && !c.isReadOnly);

      if (validReadable.isEmpty) {
        _setConnection(
          IntegrationConnectionStatus.configurationInvalid,
          availability: availability == IntegrationAvailability.unknown
              ? IntegrationAvailability.available
              : availability,
          selectedCalendarIds: readable,
          connectedAt: config.connectionConfiguredAt,
          error: IntegrationError.unknown(IntegrationProvider.calendar),
        );
        return;
      }

      final status = writableValid
          ? IntegrationConnectionStatus.connected
          : IntegrationConnectionStatus.partiallyConnected;

      _setConnection(
        status,
        availability: availability == IntegrationAvailability.unknown
            ? IntegrationAvailability.available
            : availability,
        connectedAt: config.connectionConfiguredAt ?? _clock.now().toUtc(),
        selectedCalendarIds: validReadable,
        clearError: writableValid,
        error: writableValid
            ? null
            : IntegrationError.unknown(IntegrationProvider.calendar),
      );

      await reconcileInFlightOperations();
    } catch (_) {
      // Provider check failed — keep cached selection, never claim connected.
      _setConnection(
        IntegrationConnectionStatus.staleCacheAvailable,
        availability: availability,
        selectedCalendarIds: readable,
        connectedAt: config.connectionConfiguredAt,
        error: IntegrationError.unknown(IntegrationProvider.calendar),
      );
    }
  }

  /// Reconciles outbox ops left `inFlight` after a crash/restart.
  ///
  /// Creates reconcile by memy marker; updates/deletes reconcile by typed
  /// [getEventById]. Ambiguous outcomes become recovery cases or
  /// [CalendarSyncOperationState.requiresUserAction] — never auto-retry creates.
  Future<void> reconcileInFlightOperations() async {
    final ops = await repository.getInFlightOperations();
    final config = await repository.getConfig();
    final window = config.rollingWindow(_clock.now().toUtc());

    for (final op in ops) {
      switch (op.operationType) {
        case CalendarSyncOperationType.create:
          await _reconcileInFlightCreate(op, window);
        case CalendarSyncOperationType.update:
          await _reconcileInFlightUpdate(op);
        case CalendarSyncOperationType.delete:
          await _reconcileInFlightDelete(op);
      }
    }
  }

  /// @deprecated Use [reconcileInFlightOperations].
  Future<void> reconcileInFlightCreates() => reconcileInFlightOperations();

  Future<CalendarMarkerSearchResult> _findByMemyMarker({
    required String calendarId,
    required String memyMarker,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    try {
      final found = await gateway.findEventsByMemyMarker(
        calendarId: calendarId,
        memyMarker: memyMarker,
        startUtc: startUtc,
        endUtc: endUtc,
      );
      if (found.isEmpty) return const CalendarMarkerNoMatch();
      if (found.length == 1) return CalendarMarkerSingleMatch(found.single);
      return CalendarMarkerMultipleMatches(found);
    } catch (e) {
      return CalendarMarkerSearchUnknown(
        e is IntegrationError ? e.code.name : IntegrationErrorCode.unknown.name,
      );
    }
  }

  String _titleFingerprint(String title) => title.hashCode.toRadixString(16);

  List<CalendarCreateRecoveryCandidate> _sanitizedCandidates(
    List<DeviceCalendarRawEvent> events,
  ) {
    return events
        .map(
          (e) => CalendarCreateRecoveryCandidate(
            externalEventId: e.externalEventId,
            externalCalendarId: e.externalCalendarId,
            titleFingerprint: _titleFingerprint(e.title),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _persistRecoveryCase({
    required CalendarSyncOperation op,
    required CalendarCreateRecoveryType type,
    List<CalendarCreateRecoveryCandidate> candidates = const [],
    required CalendarSyncOperationState opState,
  }) async {
    final now = _clock.now().toUtc();
    await repository.saveRecoveryCase(
      CalendarCreateRecoveryCase(
        id: _newId('cal_recovery'),
        syncOperationId: op.id,
        memyEventId: op.memyEventId,
        recoveryType: type,
        status: CalendarCreateRecoveryStatus.unresolved,
        candidates: candidates,
        createdAt: now,
      ),
    );
    await repository.updateSyncOperation(op.copyWith(state: opState));
  }

  Future<void> _reconcileInFlightCreate(
    CalendarSyncOperation op,
    ({DateTime start, DateTime end}) window,
  ) async {
    final marker = op.memyMarker;
    if (marker == null || marker.isEmpty) {
      await repository.updateSyncOperation(
        op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
      );
      return;
    }

    final search = await _findByMemyMarker(
      calendarId: op.targetCalendarId,
      memyMarker: marker,
      startUtc: window.start,
      endUtc: window.end,
    );

    switch (search) {
      case CalendarMarkerNoMatch():
        await _persistRecoveryCase(
          op: op,
          type: CalendarCreateRecoveryType.noMatchUnknownOutcome,
          opState: CalendarSyncOperationState.unknownOutcome,
        );
      case CalendarMarkerSearchUnknown():
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
      case CalendarMarkerMultipleMatches(:final events):
        await _persistRecoveryCase(
          op: op,
          type: CalendarCreateRecoveryType.multipleMarkerMatches,
          candidates: _sanitizedCandidates(events),
          opState: CalendarSyncOperationState.requiresUserAction,
        );
      case CalendarMarkerSingleMatch(:final event):
        await _completeCreateReconciliation(op, event, marker);
    }
  }

  Future<void> _completeCreateReconciliation(
    CalendarSyncOperation op,
    DeviceCalendarRawEvent raw,
    String marker,
  ) async {
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
  }

  Future<void> _reconcileInFlightUpdate(CalendarSyncOperation op) async {
    final event = await repository.getEvent(op.memyEventId);
    if (event == null || !event.isLinkedToExternal) {
      await repository.updateSyncOperation(
        op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
      );
      return;
    }

    final lookup = await gateway.getEventById(
      calendarId: event.externalCalendarId!,
      externalEventId: event.externalEventId!,
    );

    switch (lookup) {
      case CalendarEventFound found:
        final completedAt = _clock.now().toUtc();
        await repository.updateSyncOperation(
          op.copyWith(
            state: CalendarSyncOperationState.completed,
            providerExternalEventId: found.event.externalEventId,
            completedAt: completedAt,
          ),
        );
      case CalendarEventNotFound():
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
      case CalendarEventLookupUnknown():
      case CalendarEventLookupUnsupported():
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
    }
  }

  Future<void> _reconcileInFlightDelete(CalendarSyncOperation op) async {
    final event = await repository.getEvent(op.memyEventId);
    final externalCalendarId = op.targetCalendarId.isNotEmpty
        ? op.targetCalendarId
        : event?.externalCalendarId;
    final externalEventId =
        op.providerExternalEventId ?? event?.externalEventId;

    if (externalCalendarId == null ||
        externalEventId == null ||
        externalEventId.isEmpty) {
      await repository.updateSyncOperation(
        op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
      );
      return;
    }

    final lookup = await gateway.getEventById(
      calendarId: externalCalendarId,
      externalEventId: externalEventId,
    );

    switch (lookup) {
      case CalendarEventNotFound():
        final now = _clock.now().toUtc();
        if (event != null) {
          final link = await repository.getLinkForEvent(event.id);
          if (link != null) await repository.deleteLink(link.id);
          await repository.deleteEvent(event.id);
        }
        await repository.updateSyncOperation(
          op.copyWith(
            state: CalendarSyncOperationState.completed,
            completedAt: now,
          ),
        );
      case CalendarEventFound():
        try {
          await gateway.deleteEvent(
            calendarId: externalCalendarId,
            externalEventId: externalEventId,
          );
          final now = _clock.now().toUtc();
          if (event != null) {
            final link = await repository.getLinkForEvent(event.id);
            if (link != null) await repository.deleteLink(link.id);
            await repository.deleteEvent(event.id);
          }
          await repository.updateSyncOperation(
            op.copyWith(
              state: CalendarSyncOperationState.completed,
              completedAt: now,
            ),
          );
        } catch (_) {
          await repository.updateSyncOperation(
            op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
          );
        }
      case CalendarEventLookupUnknown():
      case CalendarEventLookupUnsupported():
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
    }
  }

  CalendarEventLookupDisposition _lookupDisposition(
    CalendarEventLookupResult lookup,
  ) {
    return switch (lookup) {
      CalendarEventFound() => CalendarEventLookupDisposition.found,
      CalendarEventNotFound() => CalendarEventLookupDisposition.notFound,
      CalendarEventLookupUnknown() => CalendarEventLookupDisposition.unknown,
      CalendarEventLookupUnsupported() =>
        CalendarEventLookupDisposition.unsupported,
    };
  }

  DateTime _lookupCheckedAt(CalendarEventLookupResult lookup) {
    return switch (lookup) {
      CalendarEventFound(:final fetchedAt) => fetchedAt,
      CalendarEventNotFound(:final verifiedAt) => verifiedAt,
      CalendarEventLookupUnknown(:final checkedAt) => checkedAt,
      CalendarEventLookupUnsupported(:final checkedAt) => checkedAt,
    };
  }

  bool _isTerminalMissingPresence(ExternalPresenceStatus presence) {
    return presence == ExternalPresenceStatus.confirmedMissing ||
        presence == ExternalPresenceStatus.hiddenAfterExternalDeletion ||
        presence == ExternalPresenceStatus.externallyMissingMeMyOwned;
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
      calendarSchemaVersion: CalendarConfig.currentSchemaVersion,
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
        if (link.hiddenLocally || _isTerminalMissingPresence(link.presence)) {
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
        final lookup = await gateway.getEventById(
          calendarId: calendarId,
          externalEventId: link.externalEventId,
        );
        final checkedAt = _lookupCheckedAt(lookup);
        final disposition = _lookupDisposition(lookup);

        switch (lookup) {
          case CalendarEventFound():
            await repository.saveLink(
              link.copyWith(
                presence: ExternalPresenceStatus.present,
                lastSeenExternallyAt: now,
                clearFirstMissing: true,
                clearLastMissing: true,
                missingObservationCount: 0,
                lastVerifiedLookupAt: checkedAt,
                lastLookupDisposition: disposition,
              ),
            );
            continue;
          case CalendarEventLookupUnknown():
          case CalendarEventLookupUnsupported():
            final nextPresence =
                link.presence == ExternalPresenceStatus.suspectedMissing
                ? ExternalPresenceStatus.suspectedMissing
                : ExternalPresenceStatus.lookupUnknown;
            await repository.saveLink(
              link.copyWith(
                presence: nextPresence,
                lastMissingObservationAt: now,
                missingObservationCount: nextCount,
                lastCompleteQueryStart: batch.requestedStart,
                lastCompleteQueryEnd: batch.requestedEnd,
                lastVerifiedLookupAt: checkedAt,
                lastLookupDisposition: disposition,
              ),
            );
            continue;
          case CalendarEventNotFound():
            break;
        }

        final isExternalImport =
            localEvent.origin == CalendarEventOrigin.external;
        final confirmedPresence = isExternalImport
            ? ExternalPresenceStatus.hiddenAfterExternalDeletion
            : ExternalPresenceStatus.externallyMissingMeMyOwned;

        await repository.saveLink(
          link.copyWith(
            presence: confirmedPresence,
            lastMissingObservationAt: now,
            missingObservationCount: nextCount,
            hiddenLocally: isExternalImport,
            lastCompleteQueryStart: batch.requestedStart,
            lastCompleteQueryEnd: batch.requestedEnd,
            lastVerifiedLookupAt: checkedAt,
            lastLookupDisposition: disposition,
          ),
        );

        if (isExternalImport) {
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
        if (!event.isLinkedToExternal) {
          await repository.deleteEvent(event.id);
          deleted++;
          continue;
        }

        var deleteOp = CalendarSyncOperation(
          id: _newId('cal_op'),
          memyEventId: event.id,
          operationType: CalendarSyncOperationType.delete,
          targetCalendarId: event.externalCalendarId!,
          payloadFingerprint: _payloadFingerprint(event),
          state: CalendarSyncOperationState.prepared,
          attemptCount: 0,
          createdAt: now,
          providerExternalEventId: event.externalEventId,
        );
        await repository.saveSyncOperation(deleteOp);
        deleteOp = deleteOp.copyWith(
          state: CalendarSyncOperationState.inFlight,
          attemptCount: deleteOp.attemptCount + 1,
          startedAt: now,
        );
        await repository.updateSyncOperation(deleteOp);

        try {
          await gateway.deleteEvent(
            calendarId: event.externalCalendarId!,
            externalEventId: event.externalEventId!,
          );
          final completedAt = _clock.now().toUtc();
          final link = await repository.getLinkForEvent(event.id);
          if (link != null) await repository.deleteLink(link.id);
          await repository.deleteEvent(event.id);
          await repository.updateSyncOperation(
            deleteOp.copyWith(
              state: CalendarSyncOperationState.completed,
              completedAt: completedAt,
            ),
          );
          deleted++;
        } catch (e) {
          await repository.updateSyncOperation(
            deleteOp.copyWith(
              state: CalendarSyncOperationState.unknownOutcome,
              lastErrorCode: e is IntegrationError
                  ? e.code.name
                  : IntegrationErrorCode.unknown.name,
            ),
          );
        }
        continue;
      }

      if (event.origin == CalendarEventOrigin.external) {
        // Imported events are read-only — never push mutations.
        continue;
      }

      final priorOps = await repository.getSyncOperationsForEvent(event.id);
      final blocked = priorOps.any(
        (o) =>
            (o.operationType == CalendarSyncOperationType.create &&
                (o.state == CalendarSyncOperationState.unknownOutcome ||
                    o.state ==
                        CalendarSyncOperationState.requiresUserAction)) ||
            o.state == CalendarSyncOperationState.requiresUserAction,
      );
      if (blocked) {
        continue;
      }

      final targetCalendarId = event.externalCalendarId ?? writableId;
      if (targetCalendarId == null) continue;

      if (event.isLinkedToExternal) {
        var updateOp = CalendarSyncOperation(
          id: _newId('cal_op'),
          memyEventId: event.id,
          operationType: CalendarSyncOperationType.update,
          targetCalendarId: targetCalendarId,
          payloadFingerprint: _payloadFingerprint(event),
          state: CalendarSyncOperationState.prepared,
          attemptCount: 0,
          createdAt: now,
          providerExternalEventId: event.externalEventId,
        );
        await repository.saveSyncOperation(updateOp);
        updateOp = updateOp.copyWith(
          state: CalendarSyncOperationState.inFlight,
          attemptCount: updateOp.attemptCount + 1,
          startedAt: now,
        );
        await repository.updateSyncOperation(updateOp);

        try {
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
          final existingLink = await repository.getLinkForEvent(event.id);
          if (existingLink != null) {
            await repository.saveLink(
              existingLink.copyWith(
                lastSyncedAt: completedAt,
                lastKnownExternalUpdatedAt: raw.lastModifiedUtc,
                presence: ExternalPresenceStatus.present,
                lastSeenExternallyAt: completedAt,
              ),
            );
          }
          await repository.updateSyncOperation(
            updateOp.copyWith(
              state: CalendarSyncOperationState.completed,
              providerExternalEventId: raw.externalEventId,
              completedAt: completedAt,
            ),
          );
          pushed++;
        } catch (e) {
          await repository.updateSyncOperation(
            updateOp.copyWith(
              state: CalendarSyncOperationState.unknownOutcome,
              lastErrorCode: e is IntegrationError
                  ? e.code.name
                  : IntegrationErrorCode.unknown.name,
            ),
          );
        }
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

  // ----------------------------------------------------------- create recovery

  Future<List<CalendarCreateRecoveryCase>> listUnresolvedRecoveryCases() {
    return repository.getUnresolvedRecoveryCases();
  }

  Future<CalendarCreateRecoveryCase> _requireUnresolvedRecovery(
    String recoveryCaseId,
  ) async {
    final recoveryCase = await repository.getRecoveryCase(recoveryCaseId);
    if (recoveryCase == null) {
      throw AppException.notFound('Recovery case not found.');
    }
    if (recoveryCase.status != CalendarCreateRecoveryStatus.unresolved) {
      throw AppException.validation('Recovery case is already closed.');
    }
    return recoveryCase;
  }

  Future<CalendarSyncOperation> _requireRecoveryOperation(
    CalendarCreateRecoveryCase recoveryCase,
  ) async {
    final op = await repository.getSyncOperation(recoveryCase.syncOperationId);
    if (op == null) {
      throw AppException.notFound('Sync operation for recovery not found.');
    }
    return op;
  }

  Future<void> _markRecoveryResolved(CalendarCreateRecoveryCase recoveryCase) {
    return repository.updateRecoveryCase(
      recoveryCase.copyWith(
        status: CalendarCreateRecoveryStatus.resolved,
        resolvedAt: _clock.now().toUtc(),
      ),
    );
  }

  Future<void> _markRecoveryDismissed(CalendarCreateRecoveryCase recoveryCase) {
    return repository.updateRecoveryCase(
      recoveryCase.copyWith(
        status: CalendarCreateRecoveryStatus.dismissed,
        dismissedAt: _clock.now().toUtc(),
      ),
    );
  }

  /// Re-runs marker search for an unresolved create-recovery case.
  ///
  /// Never auto-creates a device event. A single match completes create
  /// reconciliation; zero/multi updates the case in place.
  Future<void> searchAgainCreateRecovery(String recoveryCaseId) async {
    final recoveryCase = await _requireUnresolvedRecovery(recoveryCaseId);
    final op = await _requireRecoveryOperation(recoveryCase);
    final marker = op.memyMarker;
    if (marker == null || marker.isEmpty) {
      throw AppException.validation('Recovery case has no MeMy marker.');
    }

    final config = await repository.getConfig();
    final window = config.rollingWindow(_clock.now().toUtc());
    final search = await _findByMemyMarker(
      calendarId: op.targetCalendarId,
      memyMarker: marker,
      startUtc: window.start,
      endUtc: window.end,
    );

    switch (search) {
      case CalendarMarkerSingleMatch(:final event):
        await _completeCreateReconciliation(op, event, marker);
        await _markRecoveryResolved(recoveryCase);
      case CalendarMarkerMultipleMatches(:final events):
        await repository.updateRecoveryCase(
          recoveryCase.copyWith(
            recoveryType: CalendarCreateRecoveryType.multipleMarkerMatches,
            candidates: _sanitizedCandidates(events),
          ),
        );
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.requiresUserAction),
        );
      case CalendarMarkerNoMatch():
      case CalendarMarkerSearchUnknown():
        await repository.updateRecoveryCase(
          recoveryCase.copyWith(
            recoveryType: CalendarCreateRecoveryType.noMatchUnknownOutcome,
            candidates: const [],
          ),
        );
        await repository.updateSyncOperation(
          op.copyWith(state: CalendarSyncOperationState.unknownOutcome),
        );
    }
  }

  /// Links a candidate already listed on the recovery case.
  Future<void> linkCreateRecoveryCandidate({
    required String recoveryCaseId,
    required String externalEventId,
    required String externalCalendarId,
  }) async {
    final recoveryCase = await _requireUnresolvedRecovery(recoveryCaseId);
    final matched = recoveryCase.candidates.where(
      (c) =>
          c.externalEventId == externalEventId &&
          c.externalCalendarId == externalCalendarId,
    );
    if (matched.isEmpty) {
      throw AppException.validation(
        'Chosen candidate is not part of this recovery case.',
      );
    }

    final op = await _requireRecoveryOperation(recoveryCase);
    final marker =
        op.memyMarker ?? CalendarSyncOperation.markerFor(op.memyEventId);

    final lookup = await gateway.getEventById(
      calendarId: externalCalendarId,
      externalEventId: externalEventId,
    );

    final DeviceCalendarRawEvent raw;
    switch (lookup) {
      case CalendarEventFound(:final event):
        raw = event;
      case CalendarEventNotFound():
      case CalendarEventLookupUnknown():
      case CalendarEventLookupUnsupported():
        final local = await repository.getEvent(op.memyEventId);
        raw = DeviceCalendarRawEvent(
          externalEventId: externalEventId,
          externalCalendarId: externalCalendarId,
          title: '',
          time:
              local?.time ??
              TimedCalendarEventTime(
                startUtc: _clock.now().toUtc(),
                endUtc: _clock.now().toUtc().add(const Duration(hours: 1)),
              ),
        );
    }

    await _completeCreateReconciliation(op, raw, marker);
    await _markRecoveryResolved(recoveryCase);
  }

  /// Keeps the MeMy event local-only and closes the recovery case.
  Future<void> keepCreateRecoveryLocalOnly(String recoveryCaseId) async {
    final recoveryCase = await _requireUnresolvedRecovery(recoveryCaseId);
    final op = await _requireRecoveryOperation(recoveryCase);
    final now = _clock.now().toUtc();

    final event = await repository.getEvent(recoveryCase.memyEventId);
    if (event != null) {
      await repository.updateEvent(
        event.copyWith(
          syncStatus: CalendarEventSyncStatus.localOnly,
          clearExternalLink: true,
          updatedAt: now,
        ),
      );
    }

    await repository.updateSyncOperation(
      op.copyWith(
        state: CalendarSyncOperationState.permanentlyFailed,
        completedAt: now,
        clearProviderExternalEventId: true,
      ),
    );
    await _markRecoveryResolved(recoveryCase);
  }

  /// Explicit user confirmation to retry a create after a zero-match outcome.
  Future<void> retryCreateAfterConfirmation(String recoveryCaseId) async {
    final recoveryCase = await _requireUnresolvedRecovery(recoveryCaseId);
    if (recoveryCase.recoveryType !=
        CalendarCreateRecoveryType.noMatchUnknownOutcome) {
      throw AppException.validation(
        'Retry create is only available for no-match recovery cases.',
      );
    }

    final op = await _requireRecoveryOperation(recoveryCase);
    await repository.updateSyncOperation(
      op.copyWith(
        state: CalendarSyncOperationState.prepared,
        clearLastErrorCode: true,
        clearNextRetryAt: true,
      ),
    );
    await _markRecoveryResolved(recoveryCase);
  }

  Future<void> dismissCreateRecovery(String recoveryCaseId) async {
    final recoveryCase = await _requireUnresolvedRecovery(recoveryCaseId);
    await _markRecoveryDismissed(recoveryCase);
  }

  /// Deletes the MeMy-owned local event and closes the op + recovery case.
  Future<void> removeMeMyEventForRecovery(String recoveryCaseId) async {
    final recoveryCase = await _requireUnresolvedRecovery(recoveryCaseId);
    final op = await _requireRecoveryOperation(recoveryCase);
    final now = _clock.now().toUtc();

    final event = await repository.getEvent(recoveryCase.memyEventId);
    if (event != null && event.origin == CalendarEventOrigin.local) {
      final link = await repository.getLinkForEvent(event.id);
      if (link != null) await repository.deleteLink(link.id);
      await repository.deleteEvent(event.id);
    }

    await repository.updateSyncOperation(
      op.copyWith(
        state: CalendarSyncOperationState.completed,
        completedAt: now,
      ),
    );
    await _markRecoveryDismissed(recoveryCase);
  }
}
