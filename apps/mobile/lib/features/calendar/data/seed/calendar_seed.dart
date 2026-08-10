import '../../domain/entities/calendar_event_origin.dart';
import '../../domain/entities/calendar_event_sync_status.dart';
import '../../domain/entities/calendar_event_time.dart';
import '../../domain/entities/memy_calendar_event.dart';

/// Demo seed data inspired by `/app/js/data.js`.
///
/// Dated relative to "today" (not a fixed calendar date) so the Today
/// glance and Calendar agenda always show demo content on first launch,
/// regardless of when the app happens to run.
abstract final class CalendarSeed {
  static const List<int> eventPalette = [
    0xFF34C759,
    0xFFE8501F,
    0xFF3B82F6,
    0xFFFF6A1A,
    0xFF8B5CF6,
  ];

  /// Demo [MemyCalendarEvent]s anchored to [referenceDay] (defaults to the
  /// current local day) for the fake calendar data source.
  static List<MemyCalendarEvent> demoMemyEvents({DateTime? referenceDay}) {
    final day = referenceDay ?? DateTime.now();
    final base = DateTime.utc(day.year, day.month, day.day);
    final now = DateTime.now().toUtc();

    MemyCalendarEvent timed({
      required String id,
      required String title,
      required int startHour,
      required int startMinute,
      required int endHour,
      required int endMinute,
      String? location,
    }) {
      return MemyCalendarEvent(
        id: id,
        title: title,
        location: location,
        time: TimedCalendarEventTime(
          startUtc: base.add(Duration(hours: startHour, minutes: startMinute)),
          endUtc: base.add(Duration(hours: endHour, minutes: endMinute)),
        ),
        origin: CalendarEventOrigin.local,
        syncStatus: CalendarEventSyncStatus.localOnly,
        createdAt: now,
        updatedAt: now,
      );
    }

    return [
      timed(
        id: 'team',
        title: 'Team Meeting',
        startHour: 10,
        startMinute: 0,
        endHour: 11,
        endMinute: 0,
        location: 'Google Meet',
      ),
      timed(
        id: 'research',
        title: 'Research Work',
        startHour: 14,
        startMinute: 0,
        endHour: 15,
        endMinute: 30,
        location: 'Focus Time',
      ),
      timed(
        id: 'gym',
        title: 'Gym Workout',
        startHour: 18,
        startMinute: 0,
        endHour: 19,
        endMinute: 0,
        location: 'Fitness Center',
      ),
    ];
  }
}
