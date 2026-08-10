import '../../../../core/integrations/domain/integration_availability.dart';
import '../entities/calendar_event_time.dart';
import '../entities/device_calendar_descriptor.dart';

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
  });

  final String externalEventId;
  final String externalCalendarId;
  final String title;
  final String? notes;
  final String? location;
  final CalendarEventTime time;

  /// Best-effort last-modified instant. `null` when the platform doesn't
  /// report one (e.g. some Android providers) — sync treats that as
  /// "always potentially changed" and re-diffs by value instead.
  final DateTime? lastModifiedUtc;
  final int attendeeCount;
}

/// Create/update payload for [DeviceCalendarGateway.createEvent] /
/// [DeviceCalendarGateway.updateEvent].
class DeviceCalendarEventDraft {
  const DeviceCalendarEventDraft({
    required this.externalCalendarId,
    required this.title,
    required this.time,
    this.externalEventId,
    this.notes,
    this.location,
  });

  /// `null` when creating a brand-new external event.
  final String? externalEventId;
  final String externalCalendarId;
  final String title;
  final String? notes;
  final String? location;
  final CalendarEventTime time;
}

/// Abstract boundary between MeMy and the device's calendar provider.
///
/// Implementations: [FakeDeviceCalendarGateway] (in-memory, controllable —
/// used in `fake` mode and in tests) and [SystemDeviceCalendarGateway]
/// (wraps the `device_calendar` plugin — used in `system` mode).
///
/// Throws [IntegrationError] on failure; never throws plugin-specific
/// exception types.
abstract interface class DeviceCalendarGateway {
  Future<IntegrationAvailability> checkAvailability();

  /// Requests OS calendar read/write permission. Returns whether it was
  /// granted.
  Future<bool> requestPermissions();

  /// Whether permission has already been granted, without prompting.
  Future<bool> hasPermissions();

  Future<List<DeviceCalendarDescriptor>> listCalendars();

  /// Events in `[startUtc, endUtc)` for one device calendar.
  Future<List<DeviceCalendarRawEvent>> listEvents({
    required String calendarId,
    required DateTime startUtc,
    required DateTime endUtc,
  });

  /// Creates a new external event and returns it with its assigned id.
  Future<DeviceCalendarRawEvent> createEvent(DeviceCalendarEventDraft draft);

  /// Updates an existing external event. [draft.externalEventId] must be set.
  Future<DeviceCalendarRawEvent> updateEvent(DeviceCalendarEventDraft draft);

  Future<void> deleteEvent({
    required String calendarId,
    required String externalEventId,
  });
}
