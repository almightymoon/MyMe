/// Helpers for building strings safe to log, crash-report, or surface in
/// [IntegrationError.cause] from integration (Calendar, Health, …) code.
///
/// Integrations read sensitive user content — event titles/notes/attendees,
/// health sample values — that must never reach a log line, analytics
/// event, or exception string as-is. Platform exceptions in particular
/// (e.g. a `PlatformException` from HealthKit/Health Connect) can echo the
/// offending value back inside their `message`, so raw plugin exceptions
/// should never be stored or logged verbatim either — describe them with
/// [describeException] instead.
///
/// Prefer these helpers over ad-hoc string interpolation anywhere an
/// integration might log, report, or store diagnostic context.
abstract final class IntegrationLogSanitizer {
  /// Describes a caught error by type only, dropping its `message`/`toString`
  /// payload which may embed raw user or health values.
  static String describeException(Object error) => error.runtimeType.toString();

  /// Redacts a single scalar value (a health reading, an event title, …),
  /// keeping only its runtime type for diagnostics.
  static String redactValue(Object? value) {
    if (value == null) return '<none>';
    return '<redacted:${value.runtimeType}>';
  }

  /// Redacts a collection down to just its length — useful for logging
  /// "fetched N samples" without the samples themselves.
  static String redactCount(int count, String noun) =>
      '$count ${count == 1 ? noun : '${noun}s'}';
}
