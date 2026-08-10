import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../domain/entities/calendar_event_time.dart';
import '../../domain/entities/calendar_read_batch.dart';
import '../../domain/entities/device_calendar_descriptor.dart';
import '../../domain/gateways/device_calendar_gateway.dart';

/// Fully in-memory, controllable [DeviceCalendarGateway].
///
/// Backs `CALENDAR_DATA_SOURCE=fake` (default, CI-safe) and is the gateway
/// used by every calendar test — no real device/plugin involved. Tests can
/// mutate calendars/events directly and simulate external edits made
/// "on the phone" outside of MeMy.
class FakeDeviceCalendarGateway implements DeviceCalendarGateway {
  FakeDeviceCalendarGateway({
    this._availability = IntegrationAvailability.available,
    this._permissionsGranted = false,
  });

  IntegrationAvailability _availability;
  bool _permissionsGranted;
  bool requestPermissionsResult = true;
  bool supportsCreation = true;
  int _eventIdSeq = 0;
  int _calendarIdSeq = 0;

  /// When true, every [listEventBatch] returns [CalendarReadCompleteness.partial].
  bool forcePartialBatches = false;

  /// Optional one-shot override for the next batch completeness (consumed).
  CalendarReadCompleteness? nextBatchCompleteness;

  final Map<String, DeviceCalendarDescriptor> _calendars = {};
  final Map<String, Map<String, DeviceCalendarRawEvent>> _eventsByCalendar = {};

  /// Seeds one calendar; returns the descriptor for convenience.
  DeviceCalendarDescriptor seedCalendar({
    required String id,
    required String name,
    int? color,
    String? accountName,
    bool isReadOnly = false,
    bool isDefault = false,
  }) {
    final descriptor = DeviceCalendarDescriptor(
      id: id,
      name: name,
      color: color,
      accountName: accountName,
      isReadOnly: isReadOnly,
      isDefault: isDefault,
    );
    _calendars[id] = descriptor;
    _eventsByCalendar.putIfAbsent(id, () => {});
    return descriptor;
  }

  /// Seeds (or overwrites) one external event, simulating an event that
  /// already existed on the device before MeMy connected — or an edit made
  /// natively (outside MeMy) between syncs.
  DeviceCalendarRawEvent seedEvent({
    required String calendarId,
    String? externalEventId,
    required String title,
    required CalendarEventTime time,
    String? notes,
    String? location,
    String? url,
    DateTime? lastModifiedUtc,
  }) {
    final id = externalEventId ?? 'fake_evt_${_eventIdSeq++}';
    final event = DeviceCalendarRawEvent(
      externalEventId: id,
      externalCalendarId: calendarId,
      title: title,
      notes: notes,
      location: location,
      time: time,
      lastModifiedUtc: lastModifiedUtc,
      url: url,
    );
    _eventsByCalendar.putIfAbsent(calendarId, () => {})[id] = event;
    return event;
  }

  DateTime Function() nowUtc = () => DateTime.now().toUtc();

  /// Simulates the user editing [externalEventId] directly on the device,
  /// outside of MeMy — bumps `lastModifiedUtc` so pull-sync detects it.
  DeviceCalendarRawEvent simulateExternalEdit({
    required String calendarId,
    required String externalEventId,
    String? title,
    CalendarEventTime? time,
    String? notes,
    String? location,
    String? url,
    required DateTime lastModifiedUtc,
  }) {
    final existing = _eventsByCalendar[calendarId]?[externalEventId];
    if (existing == null) {
      throw StateError('No such fake event: $externalEventId');
    }
    final updated = DeviceCalendarRawEvent(
      externalEventId: externalEventId,
      externalCalendarId: calendarId,
      title: title ?? existing.title,
      notes: notes ?? existing.notes,
      location: location ?? existing.location,
      time: time ?? existing.time,
      lastModifiedUtc: lastModifiedUtc,
      url: url ?? existing.url,
    );
    _eventsByCalendar[calendarId]![externalEventId] = updated;
    return updated;
  }

  /// Simulates deleting an event directly on the device.
  void simulateExternalDelete({
    required String calendarId,
    required String externalEventId,
  }) {
    _eventsByCalendar[calendarId]?.remove(externalEventId);
  }

  void setAvailability(IntegrationAvailability availability) {
    _availability = availability;
  }

  void setPermissionsGranted(bool granted) {
    _permissionsGranted = granted;
  }

  List<DeviceCalendarRawEvent> eventsIn(String calendarId) =>
      List.unmodifiable(_eventsByCalendar[calendarId]?.values ?? const []);

  @override
  Future<IntegrationAvailability> checkAvailability() async => _availability;

  @override
  Future<bool> requestPermissions() async {
    if (_availability != IntegrationAvailability.available) {
      throw IntegrationError.unavailable(IntegrationProvider.calendar);
    }
    _permissionsGranted = requestPermissionsResult;
    if (!_permissionsGranted) {
      throw IntegrationError.permissionDenied(IntegrationProvider.calendar);
    }
    return _permissionsGranted;
  }

  @override
  Future<bool> hasPermissions() async => _permissionsGranted;

  void _requirePermission() {
    if (!_permissionsGranted) {
      throw IntegrationError.permissionDenied(IntegrationProvider.calendar);
    }
  }

  @override
  Future<List<DeviceCalendarDescriptor>> listCalendars() async {
    _requirePermission();
    return List.unmodifiable(_calendars.values);
  }

  @override
  Future<List<DeviceCalendarRawEvent>> listEvents({
    required String calendarId,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final batch = await listEventBatch(
      calendarId: calendarId,
      startUtc: startUtc,
      endUtc: endUtc,
    );
    return batch.events;
  }

  @override
  Future<CalendarReadBatch> listEventBatch({
    required String calendarId,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    _requirePermission();
    final events = (_eventsByCalendar[calendarId]?.values ?? const [])
        .where(
          (e) =>
              e.time.startUtc.isBefore(endUtc) &&
              e.time.endUtc.isAfter(startUtc),
        )
        .toList(growable: false);

    final completeness =
        nextBatchCompleteness ??
        (forcePartialBatches
            ? CalendarReadCompleteness.partial
            : CalendarReadCompleteness.complete);
    nextBatchCompleteness = null;

    return CalendarReadBatch(
      calendarId: calendarId,
      requestedStart: startUtc,
      requestedEnd: endUtc,
      events: events,
      completeness: completeness,
      fetchedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<DeviceCalendarRawEvent?> getEventById({
    required String calendarId,
    required String externalEventId,
  }) async {
    _requirePermission();
    return _eventsByCalendar[calendarId]?[externalEventId];
  }

  @override
  Future<bool> supportsCalendarCreation() async => supportsCreation;

  @override
  Future<DeviceCalendarDescriptor> createCalendar({
    required String name,
    String? colorKey,
  }) async {
    _requirePermission();
    if (!supportsCreation) {
      throw IntegrationError(
        provider: IntegrationProvider.calendar,
        code: IntegrationErrorCode.notSupported,
        message: 'Creating calendars is not supported on this device.',
      );
    }
    final id = 'fake_cal_${_calendarIdSeq++}';
    return seedCalendar(id: id, name: name);
  }

  @override
  Future<DeviceCalendarDescriptor?> getCalendar(String calendarId) async {
    _requirePermission();
    return _calendars[calendarId];
  }

  @override
  Future<bool> verifyCalendarWritable(String calendarId) async {
    _requirePermission();
    final calendar = _calendars[calendarId];
    if (calendar == null) return false;
    return !calendar.isReadOnly;
  }

  @override
  Future<DeviceCalendarRawEvent> createEvent(
    DeviceCalendarEventDraft draft,
  ) async {
    _requirePermission();
    final id = draft.externalEventId ?? 'fake_evt_${_eventIdSeq++}';
    final event = DeviceCalendarRawEvent(
      externalEventId: id,
      externalCalendarId: draft.externalCalendarId,
      title: draft.title,
      notes: draft.notes,
      location: draft.location,
      time: draft.time,
      lastModifiedUtc: nowUtc(),
      url: draft.url,
      reminderMinutes: draft.reminderMinutes,
    );
    _eventsByCalendar.putIfAbsent(draft.externalCalendarId, () => {})[id] =
        event;
    return event;
  }

  @override
  Future<DeviceCalendarRawEvent> updateEvent(
    DeviceCalendarEventDraft draft,
  ) async {
    _requirePermission();
    final id = draft.externalEventId;
    if (id == null) {
      throw ArgumentError('updateEvent requires an externalEventId');
    }
    final event = DeviceCalendarRawEvent(
      externalEventId: id,
      externalCalendarId: draft.externalCalendarId,
      title: draft.title,
      notes: draft.notes,
      location: draft.location,
      time: draft.time,
      lastModifiedUtc: nowUtc(),
      url: draft.url,
      reminderMinutes: draft.reminderMinutes,
    );
    _eventsByCalendar.putIfAbsent(draft.externalCalendarId, () => {})[id] =
        event;
    return event;
  }

  @override
  Future<void> deleteEvent({
    required String calendarId,
    required String externalEventId,
  }) async {
    _requirePermission();
    _eventsByCalendar[calendarId]?.remove(externalEventId);
  }

  @override
  Future<List<DeviceCalendarRawEvent>> findEventsByMemyMarker({
    required String calendarId,
    required String memyMarker,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    _requirePermission();
    final events = await listEvents(
      calendarId: calendarId,
      startUtc: startUtc,
      endUtc: endUtc,
    );
    return events.where((e) => e.url == memyMarker).toList(growable: false);
  }
}
