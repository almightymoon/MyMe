import '../entities/calendar_event_time.dart';

/// Thrown by [CalendarEventValidator] for invalid event input.
class CalendarEventValidationException implements Exception {
  CalendarEventValidationException(this.message);
  final String message;

  @override
  String toString() => 'CalendarEventValidationException: $message';
}

/// Runtime validation for [MemyCalendarEvent] fields shared by add/edit
/// forms and the sync pipeline (so imported/pulled data is held to the
/// same bar as user-entered data).
abstract final class CalendarEventValidator {
  static const int maxTitleLength = 200;
  static const int maxNotesLength = 4000;
  static const int maxLocationLength = 200;

  static String validateTitle(String rawTitle) {
    final title = rawTitle.trim();
    if (title.isEmpty) {
      throw CalendarEventValidationException('Event title cannot be empty.');
    }
    if (title.length > maxTitleLength) {
      throw CalendarEventValidationException(
        'Event title cannot exceed $maxTitleLength characters.',
      );
    }
    return title;
  }

  static String? validateNotes(String? rawNotes) {
    if (rawNotes == null) return null;
    final notes = rawNotes.trim();
    if (notes.isEmpty) return null;
    if (notes.length > maxNotesLength) {
      throw CalendarEventValidationException(
        'Event notes cannot exceed $maxNotesLength characters.',
      );
    }
    return notes;
  }

  static String? validateLocation(String? rawLocation) {
    if (rawLocation == null) return null;
    final location = rawLocation.trim();
    if (location.isEmpty) return null;
    if (location.length > maxLocationLength) {
      throw CalendarEventValidationException(
        'Event location cannot exceed $maxLocationLength characters.',
      );
    }
    return location;
  }

  /// [TimedCalendarEventTime]/[AllDayCalendarEventTime] already enforce
  /// end >= start at construction; this re-validates for values built from
  /// untrusted/external sources without going through those constructors.
  static void validateTimeRange(CalendarEventTime time) {
    if (!time.endUtc.isAfter(time.startUtc)) {
      throw CalendarEventValidationException(
        'Event end time must be after the start time.',
      );
    }
  }

  static List<int> validateReminderMinutes(List<int> minutes) {
    for (final m in minutes) {
      if (m < 0) {
        throw CalendarEventValidationException(
          'Reminder minutes must be zero or positive.',
        );
      }
    }
    return List<int>.unmodifiable({...minutes}.toList()..sort());
  }
}
