import 'dart:async';

import '../../../../core/data/fake_repository_config.dart';
import '../../../../core/domain/clock/app_clock.dart';
import '../../domain/entities/calendar_config.dart';
import '../../domain/entities/calendar_event_link.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/calendar_sync_conflict.dart';
import '../../domain/entities/conflict_resolution.dart';
import '../../domain/entities/memy_calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../seed/calendar_seed.dart';

/// Fully in-memory [CalendarRepository] — no SQLite involved.
///
/// Backs `CALENDAR_DATA_SOURCE=fake` (default, CI-safe) and every calendar
/// widget test that doesn't need to exercise real persistence.
class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({
    AppClock? clock,
    this._config,
    List<MemyCalendarEvent>? seedEvents,
  }) : _clock = clock ?? const SystemAppClock(),
       _events = List.of(seedEvents ?? CalendarSeed.demoMemyEvents());

  final AppClock _clock;
  final FakeRepositoryConfig? _config;

  List<MemyCalendarEvent> _events;
  final Map<String, CalendarEventLink> _linksByEventId = {};
  final List<CalendarSyncConflict> _conflicts = [];
  CalendarConfig _configRow = const CalendarConfig();
  int _idSeq = 0;

  final _eventsController =
      StreamController<List<MemyCalendarEvent>>.broadcast();
  final _conflictsController =
      StreamController<List<CalendarSyncConflict>>.broadcast();

  void dispose() {
    _eventsController.close();
    _conflictsController.close();
  }

  Future<void> _maybeFail() async {
    final cfg = _config;
    if (cfg == null) return;
    await Future<void>.delayed(cfg.delay);
    if (cfg.forceFailure) {
      throw FakeRepositoryException(cfg.failureMessage);
    }
  }

  void _emitEvents() {
    if (!_eventsController.isClosed) {
      _eventsController.add(List.unmodifiable(_events));
    }
  }

  void _emitConflicts() {
    if (!_conflictsController.isClosed) {
      _conflictsController.add(
        List.unmodifiable(_conflicts.where((c) => !c.isResolved)),
      );
    }
  }

  String _newId(String prefix) => '${prefix}_${_idSeq++}';

  @override
  Stream<List<MemyCalendarEvent>> watchEventsInRange({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async* {
    yield _filterRange(startUtc, endUtc);
    yield* _eventsController.stream.map((_) => _filterRange(startUtc, endUtc));
  }

  List<MemyCalendarEvent> _filterRange(DateTime startUtc, DateTime endUtc) {
    final filtered = _events.where((e) => e.deletedAt == null).where((e) {
      return e.time.startUtc.isBefore(endUtc) &&
          e.time.endUtc.isAfter(startUtc);
    }).toList()..sort((a, b) => a.time.startUtc.compareTo(b.time.startUtc));
    return filtered;
  }

  @override
  Future<List<MemyCalendarEvent>> getEventsInRange({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    await _maybeFail();
    if (_config?.forceEmpty ?? false) return const [];
    return _filterRange(startUtc, endUtc);
  }

  @override
  Future<MemyCalendarEvent?> getEvent(String id) async {
    for (final e in _events) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<List<MemyCalendarEvent>> getPendingSyncEvents() async {
    return _events
        .where(
          (e) =>
              e.syncStatus == CalendarEventSyncStatus.pendingPush ||
              e.syncStatus == CalendarEventSyncStatus.pendingDelete,
        )
        .toList(growable: false);
  }

  @override
  Future<MemyCalendarEvent> createEvent(MemyCalendarEvent event) async {
    await _maybeFail();
    final prepared = event.id.isEmpty
        ? _copyWithId(event, _newId('cal_evt'))
        : event;
    _events = [..._events, prepared];
    _emitEvents();
    return prepared;
  }

  MemyCalendarEvent _copyWithId(MemyCalendarEvent event, String id) {
    return MemyCalendarEvent(
      id: id,
      title: event.title,
      notes: event.notes,
      location: event.location,
      time: event.time,
      origin: event.origin,
      syncStatus: event.syncStatus,
      provider: event.provider,
      externalCalendarId: event.externalCalendarId,
      externalEventId: event.externalEventId,
      reminderMinutes: event.reminderMinutes,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
      version: event.version,
    );
  }

  @override
  Future<MemyCalendarEvent> updateEvent(MemyCalendarEvent event) async {
    await _maybeFail();
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx < 0) throw StateError('Calendar event not found: ${event.id}');
    final next = [..._events];
    next[idx] = event;
    _events = next;
    _emitEvents();
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _maybeFail();
    _events = _events.where((e) => e.id != id).toList();
    _linksByEventId.remove(id);
    _emitEvents();
  }

  @override
  Future<CalendarEventLink?> getLinkForEvent(String memyEventId) async {
    return _linksByEventId[memyEventId];
  }

  @override
  Future<CalendarEventLink?> getLinkByExternalId({
    required String externalCalendarId,
    required String externalEventId,
  }) async {
    for (final link in _linksByEventId.values) {
      if (link.externalCalendarId == externalCalendarId &&
          link.externalEventId == externalEventId) {
        return link;
      }
    }
    return null;
  }

  @override
  Future<CalendarEventLink> saveLink(CalendarEventLink link) async {
    _linksByEventId[link.memyEventId] = link;
    return link;
  }

  @override
  Future<void> deleteLink(String linkId) async {
    _linksByEventId.removeWhere((_, link) => link.id == linkId);
  }

  @override
  Future<List<CalendarEventLink>> getLinksForExternalCalendar(
    String externalCalendarId,
  ) async {
    return _linksByEventId.values
        .where((l) => l.externalCalendarId == externalCalendarId)
        .toList(growable: false);
  }

  @override
  Stream<List<CalendarSyncConflict>> watchConflicts() async* {
    yield List.unmodifiable(_conflicts.where((c) => !c.isResolved));
    yield* _conflictsController.stream;
  }

  @override
  Future<List<CalendarSyncConflict>> getConflicts() async {
    return _conflicts.where((c) => !c.isResolved).toList(growable: false);
  }

  @override
  Future<CalendarSyncConflict?> getConflict(String id) async {
    for (final c in _conflicts) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<CalendarSyncConflict> addConflict(
    CalendarSyncConflict conflict,
  ) async {
    final prepared = conflict.id.isEmpty ? conflict.copyWith() : conflict;
    _conflicts.add(prepared);
    _emitConflicts();
    return prepared;
  }

  @override
  Future<void> markConflictResolved({
    required String conflictId,
    required ConflictResolution resolution,
  }) async {
    final idx = _conflicts.indexWhere((c) => c.id == conflictId);
    if (idx < 0) return;
    _conflicts[idx] = _conflicts[idx].copyWith(
      resolvedAt: _clock.now().toUtc(),
      resolution: resolution,
    );
    _emitConflicts();
  }

  @override
  Future<CalendarConfig> getConfig() async => _configRow;

  @override
  Future<void> saveConfig(CalendarConfig config) async {
    _configRow = config;
  }

  @override
  Future<void> refresh() async {
    _emitEvents();
    _emitConflicts();
  }
}
