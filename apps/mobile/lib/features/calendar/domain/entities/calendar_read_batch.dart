import 'device_calendar_raw_event.dart';

/// How complete a calendar event read response is.
///
/// Destructive sync decisions (tombstones / confirmed missing) may only run
/// against [CalendarReadCompleteness.complete] batches.
enum CalendarReadCompleteness { complete, partial, unknown }

/// Typed result of a calendar event read — never treat a bare `List` as a
/// complete empty set when deciding deletions.
class CalendarReadBatch {
  const CalendarReadBatch({
    required this.calendarId,
    required this.requestedStart,
    required this.requestedEnd,
    required this.events,
    required this.completeness,
    required this.fetchedAt,
    this.warnings = const [],
    this.providerCursor,
  });

  final String calendarId;
  final DateTime requestedStart;
  final DateTime requestedEnd;
  final List<DeviceCalendarRawEvent> events;
  final CalendarReadCompleteness completeness;
  final DateTime fetchedAt;
  final List<String> warnings;
  final String? providerCursor;

  bool get mayInferAbsences =>
      completeness == CalendarReadCompleteness.complete;
}
