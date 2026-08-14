import 'package:intl/intl.dart';

import '../../data/seed/calendar_seed.dart';
import '../../domain/entities/memy_calendar_event.dart';
import '../../domain/entities/schedule_item.dart';

/// Maps live [MemyCalendarEvent]s to the [ScheduleItem] presentation DTO
/// used by the Today "at a glance" card.
///
/// Kept as a one-directional mapper (domain → presentation) so Today never
/// depends on calendar sync internals (origin, syncStatus, external ids).
abstract final class ScheduleItemMapper {
  static final DateFormat _timeFormat = DateFormat('h:mm a');

  static ScheduleItem fromMemyEvent(MemyCalendarEvent event) {
    final startLocal = event.time.startUtc.toLocal();
    final endLocal = event.time.endUtc.toLocal();
    return ScheduleItem(
      id: event.id,
      timeLabel: event.isAllDay ? 'All day' : _timeFormat.format(startLocal),
      endTimeLabel: event.isAllDay ? null : _timeFormat.format(endLocal),
      title: event.title,
      place: event.location,
      notes: event.notes,
      date: DateTime(startLocal.year, startLocal.month, startLocal.day),
      colorValue:
          CalendarSeed.eventPalette[event.id.hashCode.abs() %
              CalendarSeed.eventPalette.length],
      reminderMinutes: event.reminderMinutes.isEmpty
          ? null
          : event.reminderMinutes.first,
    );
  }

  static List<ScheduleItem> fromMemyEvents(List<MemyCalendarEvent> events) {
    return events.map(fromMemyEvent).toList(growable: false);
  }
}
