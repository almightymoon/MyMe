import 'device_calendar_raw_event.dart';

/// Typed result of searching device events by MeMy marker URL.
sealed class CalendarMarkerSearchResult {
  const CalendarMarkerSearchResult();
}

class CalendarMarkerNoMatch extends CalendarMarkerSearchResult {
  const CalendarMarkerNoMatch();
}

class CalendarMarkerSingleMatch extends CalendarMarkerSearchResult {
  const CalendarMarkerSingleMatch(this.event);

  final DeviceCalendarRawEvent event;
}

class CalendarMarkerMultipleMatches extends CalendarMarkerSearchResult {
  const CalendarMarkerMultipleMatches(this.events);

  final List<DeviceCalendarRawEvent> events;
}

class CalendarMarkerSearchUnknown extends CalendarMarkerSearchResult {
  const CalendarMarkerSearchUnknown(this.errorCode);

  final String errorCode;
}
