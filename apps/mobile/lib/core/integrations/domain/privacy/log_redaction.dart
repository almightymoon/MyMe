/// Privacy guardrails for anything derived from integration content.
///
/// MeMy never logs (or uploads) calendar event titles/notes/attendees or
/// health sample values. These helpers are the *only* sanctioned way to
/// turn integration content into a string that may end up in a log line,
/// exception message, or crash report — every call strips the actual value
/// and keeps only shape/metadata that is safe to inspect.
abstract final class LogRedaction {
  static const String redacted = '«redacted»';

  /// Never returns the input. Use for any single free-text field
  /// (event title, notes, location, attendee name/email, health note…).
  static String redactText(String? value) {
    if (value == null || value.isEmpty) return '';
    return redacted;
  }

  /// First 8 chars of an id, safe for correlating log lines without
  /// exposing the full identifier.
  static String shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }

  /// Attendee/participant list → count only, never names or emails.
  static String redactList(List<Object?>? values) {
    final count = values?.length ?? 0;
    return '$count item(s)';
  }

  /// Safe, structured description of a calendar event for diagnostics.
  /// Carries only id + shape metadata — no title, notes, location, or
  /// attendee content.
  static String describeCalendarEvent({
    required String id,
    bool hasTitle = false,
    bool hasNotes = false,
    bool hasLocation = false,
    bool isAllDay = false,
    int attendeeCount = 0,
  }) {
    return 'event(id: ${shortId(id)}, hasTitle: $hasTitle, '
        'hasNotes: $hasNotes, hasLocation: $hasLocation, '
        'allDay: $isAllDay, attendees: $attendeeCount)';
  }

  /// Safe, structured description of a health sample for diagnostics.
  /// Carries only type/unit metadata — never the recorded value.
  static String describeHealthSample({
    required String type,
    required String unit,
    DateTime? recordedAt,
  }) {
    return 'healthSample(type: $type, unit: $unit, '
        'hasTimestamp: ${recordedAt != null})';
  }

  /// Recursively strips known-sensitive keys from a loggable map, in case
  /// callers build ad-hoc diagnostic payloads.
  static const Set<String> sensitiveKeys = {
    'title',
    'notes',
    'description',
    'location',
    'attendees',
    'attendee',
    'name',
    'email',
    'value',
    'note',
  };

  static Map<String, Object?> sanitizeMap(Map<String, Object?> input) {
    final result = <String, Object?>{};
    for (final entry in input.entries) {
      final keyLower = entry.key.toLowerCase();
      if (sensitiveKeys.contains(keyLower)) {
        result[entry.key] = redacted;
        continue;
      }
      final value = entry.value;
      if (value is Map<String, Object?>) {
        result[entry.key] = sanitizeMap(value);
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }
}
