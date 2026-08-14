import 'device_calendar_raw_event.dart';

/// Typed result of a direct external event lookup by ID.
///
/// Distinguishes confirmed absence from lookup failure — never treat null /
/// empty as deletion evidence.
sealed class CalendarEventLookupResult {
  const CalendarEventLookupResult();
}

class CalendarEventFound extends CalendarEventLookupResult {
  const CalendarEventFound({
    required this.event,
    required this.fetchedAt,
    required this.providerSource,
  });

  final DeviceCalendarRawEvent event;
  final DateTime fetchedAt;

  /// Opaque provider channel label (e.g. `batch_scan`, `plugin_id`).
  final String providerSource;
}

class CalendarEventNotFound extends CalendarEventLookupResult {
  const CalendarEventNotFound({
    required this.externalCalendarId,
    required this.externalEventId,
    required this.verifiedAt,
    required this.verificationMethod,
  });

  final String externalCalendarId;
  final String externalEventId;
  final DateTime verifiedAt;

  /// How absence was verified (e.g. `complete_batch_scan`).
  final String verificationMethod;
}

class CalendarEventLookupUnknown extends CalendarEventLookupResult {
  const CalendarEventLookupUnknown({
    required this.sanitizedErrorCode,
    required this.retryable,
    required this.checkedAt,
  });

  final String sanitizedErrorCode;
  final bool retryable;
  final DateTime checkedAt;
}

class CalendarEventLookupUnsupported extends CalendarEventLookupResult {
  const CalendarEventLookupUnsupported({
    required this.checkedAt,
    required this.explanationCode,
  });

  final DateTime checkedAt;
  final String explanationCode;
}

/// Stored on [CalendarEventLink.lastLookupDisposition].
enum CalendarEventLookupDisposition { found, notFound, unknown, unsupported }
