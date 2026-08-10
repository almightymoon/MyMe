import 'package:device_calendar/device_calendar.dart' as dc;

import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../domain/entities/calendar_event_time.dart';
import '../../domain/entities/device_calendar_descriptor.dart';
import '../../domain/gateways/device_calendar_gateway.dart';

/// [DeviceCalendarGateway] backed by the real `device_calendar` plugin.
///
/// Plugin types (`dc.Event`, `dc.Calendar`, `dc.Result`) are mapped to
/// domain types at every method boundary and never returned to callers.
/// Requires a real device/simulator with a calendar provider — not used in
/// `fake` (default/CI) mode.
class SystemDeviceCalendarGateway implements DeviceCalendarGateway {
  SystemDeviceCalendarGateway({dc.DeviceCalendarPlugin? plugin})
    : _plugin = plugin ?? dc.DeviceCalendarPlugin();

  final dc.DeviceCalendarPlugin _plugin;

  Never _throwFrom(dc.Result<Object?> result, {String? fallback}) {
    final message = result.errors.isEmpty
        ? (fallback ?? 'Calendar operation failed.')
        : result.errors.map((e) => e.errorMessage).join('; ');
    throw IntegrationError(
      provider: IntegrationProvider.calendar,
      code: IntegrationErrorCode.unknown,
      message: 'Calendar sync failed. Please try again.',
      cause: message,
    );
  }

  @override
  Future<IntegrationAvailability> checkAvailability() async {
    try {
      final result = await _plugin.hasPermissions();
      if (result.hasErrors) return IntegrationAvailability.unavailable;
      return IntegrationAvailability.available;
    } catch (e) {
      return IntegrationAvailability.unavailable;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    final result = await _plugin.hasPermissions();
    return result.data ?? false;
  }

  @override
  Future<bool> requestPermissions() async {
    final result = await _plugin.requestPermissions();
    final granted = result.data ?? false;
    if (!granted) {
      throw IntegrationError.permissionDenied(IntegrationProvider.calendar);
    }
    return granted;
  }

  @override
  Future<List<DeviceCalendarDescriptor>> listCalendars() async {
    final result = await _plugin.retrieveCalendars();
    if (!result.isSuccess || result.data == null) {
      _throwFrom(result, fallback: 'Could not read device calendars.');
    }
    return result.data!
        .where((c) => c.id != null)
        .map(_toDescriptor)
        .toList(growable: false);
  }

  @override
  Future<List<DeviceCalendarRawEvent>> listEvents({
    required String calendarId,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final result = await _plugin.retrieveEvents(
      calendarId,
      dc.RetrieveEventsParams(startDate: startUtc, endDate: endUtc),
    );
    if (!result.isSuccess || result.data == null) {
      _throwFrom(result, fallback: 'Could not read calendar events.');
    }
    return result.data!
        .where((e) => e.eventId != null)
        .map(_toRawEvent)
        .toList(growable: false);
  }

  @override
  Future<DeviceCalendarRawEvent> createEvent(
    DeviceCalendarEventDraft draft,
  ) async {
    final result = await _plugin.createOrUpdateEvent(_toPluginEvent(draft));
    if (result == null || !result.isSuccess || result.data == null) {
      _throwFrom(
        result ?? dc.Result<String>(),
        fallback: 'Could not create the calendar event.',
      );
    }
    return _toRawEvent(_toPluginEvent(draft)..eventId = result.data);
  }

  @override
  Future<DeviceCalendarRawEvent> updateEvent(
    DeviceCalendarEventDraft draft,
  ) async {
    if (draft.externalEventId == null) {
      throw ArgumentError('updateEvent requires an externalEventId');
    }
    final result = await _plugin.createOrUpdateEvent(_toPluginEvent(draft));
    if (result == null || !result.isSuccess) {
      _throwFrom(
        result ?? dc.Result<String>(),
        fallback: 'Could not update the calendar event.',
      );
    }
    return _toRawEvent(_toPluginEvent(draft));
  }

  @override
  Future<void> deleteEvent({
    required String calendarId,
    required String externalEventId,
  }) async {
    final result = await _plugin.deleteEvent(calendarId, externalEventId);
    if (!result.isSuccess) {
      _throwFrom(result, fallback: 'Could not delete the calendar event.');
    }
  }

  DeviceCalendarDescriptor _toDescriptor(dc.Calendar calendar) {
    return DeviceCalendarDescriptor(
      id: calendar.id!,
      name: calendar.name ?? 'Calendar',
      color: calendar.color,
      accountName: calendar.accountName,
      isReadOnly: calendar.isReadOnly ?? false,
      isDefault: calendar.isDefault ?? false,
    );
  }

  DeviceCalendarRawEvent _toRawEvent(dc.Event event) {
    final isAllDay = event.allDay ?? false;
    final CalendarEventTime time;
    if (isAllDay) {
      time = calendarEventTimeFromStorage(
        isAllDay: true,
        startUtc: DateTime.utc(
          event.start!.year,
          event.start!.month,
          event.start!.day,
        ),
        // device_calendar normalizes allDay start/end to inclusive local
        // calendar days on read; convert the inclusive end day to our
        // exclusive-end-of-day storage convention.
        endUtc: DateTime.utc(
          event.end!.year,
          event.end!.month,
          event.end!.day,
        ).add(const Duration(days: 1)),
      );
    } else {
      time = TimedCalendarEventTime(
        startUtc: event.start!.toUtc(),
        endUtc: event.end!.toUtc(),
        timezoneName: event.start?.location.name,
      );
    }
    return DeviceCalendarRawEvent(
      externalEventId: event.eventId!,
      externalCalendarId: event.calendarId ?? '',
      title: event.title ?? '',
      notes: event.description,
      location: event.location,
      time: time,
      // The plugin does not surface a reliable last-modified instant on
      // every platform; sync falls back to value-based diffing.
      lastModifiedUtc: null,
      attendeeCount: event.attendees?.length ?? 0,
    );
  }

  dc.Event _toPluginEvent(DeviceCalendarEventDraft draft) {
    final event = dc.Event(
      draft.externalCalendarId,
      eventId: draft.externalEventId,
      title: draft.title,
      description: draft.notes,
      location: draft.location,
    );
    if (draft.time.isAllDay) {
      event.allDay = true;
      event.start = dc.TZDateTime.from(draft.time.startUtc, dc.local);
      // Our storage end is exclusive-next-day; the plugin wants the
      // inclusive last day for allDay events.
      event.end = dc.TZDateTime.from(
        draft.time.endUtc.subtract(const Duration(days: 1)),
        dc.local,
      );
    } else {
      event.allDay = false;
      event.start = dc.TZDateTime.from(draft.time.startUtc, dc.local);
      event.end = dc.TZDateTime.from(draft.time.endUtc, dc.local);
    }
    return event;
  }
}
