import 'calendar_event_time.dart';

/// One external calendar event, as read from the device.
///
/// This is the gateway boundary type — plugin classes (`device_calendar`'s
/// `Event`/`Calendar`) must never appear outside `data/gateways/`.
class DeviceCalendarRawEvent {
  const DeviceCalendarRawEvent({
    required this.externalEventId,
    required this.externalCalendarId,
    required this.title,
    required this.time,
    this.notes,
    this.location,
    this.lastModifiedUtc,
    this.attendeeCount = 0,
    this.url,
    this.recurrenceRule,
    this.isRecurringInstance = false,
    this.seriesExternalEventId,
    this.reminderMinutes = const [],
  });

  final String externalEventId;
  final String externalCalendarId;
  final String title;
  final String? notes;
  final String? location;
  final CalendarEventTime time;
  final DateTime? lastModifiedUtc;
  final int attendeeCount;
  final String? url;
  final String? recurrenceRule;
  final bool isRecurringInstance;
  final String? seriesExternalEventId;
  final List<int> reminderMinutes;
}

/// Create/update payload for device calendar writes.
class DeviceCalendarEventDraft {
  const DeviceCalendarEventDraft({
    required this.externalCalendarId,
    required this.title,
    required this.time,
    this.externalEventId,
    this.notes,
    this.location,
    this.url,
    this.reminderMinutes = const [],
  });

  final String? externalEventId;
  final String externalCalendarId;
  final String title;
  final String? notes;
  final String? location;
  final CalendarEventTime time;
  final String? url;
  final List<int> reminderMinutes;
}
