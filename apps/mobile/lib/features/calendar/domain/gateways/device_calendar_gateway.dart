import '../../../../core/integrations/domain/integration_availability.dart';
import '../entities/calendar_event_lookup_result.dart';
import '../entities/calendar_read_batch.dart';
import '../entities/device_calendar_descriptor.dart';
import '../entities/device_calendar_raw_event.dart';

export '../entities/device_calendar_raw_event.dart';

/// Abstract boundary between MeMy and the device's calendar provider.
///
/// Implementations: Fake (tests/`fake` mode) and System (`device_calendar`
/// plugin). Throws [IntegrationError] on failure; never throws plugin types.
abstract interface class DeviceCalendarGateway {
  Future<IntegrationAvailability> checkAvailability();

  Future<bool> requestPermissions();

  Future<bool> hasPermissions();

  Future<List<DeviceCalendarDescriptor>> listCalendars();

  Future<List<DeviceCalendarRawEvent>> listEvents({
    required String calendarId,
    required DateTime startUtc,
    required DateTime endUtc,
  });

  Future<CalendarReadBatch> listEventBatch({
    required String calendarId,
    required DateTime startUtc,
    required DateTime endUtc,
  });

  Future<CalendarEventLookupResult> getEventById({
    required String calendarId,
    required String externalEventId,
  });

  Future<bool> supportsCalendarCreation();

  Future<DeviceCalendarDescriptor> createCalendar({
    required String name,
    String? colorKey,
  });

  Future<DeviceCalendarDescriptor?> getCalendar(String calendarId);

  Future<bool> verifyCalendarWritable(String calendarId);

  Future<DeviceCalendarRawEvent> createEvent(DeviceCalendarEventDraft draft);

  Future<DeviceCalendarRawEvent> updateEvent(DeviceCalendarEventDraft draft);

  Future<void> deleteEvent({
    required String calendarId,
    required String externalEventId,
  });

  Future<List<DeviceCalendarRawEvent>> findEventsByMemyMarker({
    required String calendarId,
    required String memyMarker,
    required DateTime startUtc,
    required DateTime endUtc,
  });
}
