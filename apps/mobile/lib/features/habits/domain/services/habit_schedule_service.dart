import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/habit.dart';
import '../entities/habit_enums.dart';

/// Pure schedule rules for Habits.
///
/// Week starts on Monday (ISO-8601). Schedule edits affect future dates only;
/// historical check-ins are never rewritten by this service.
class HabitScheduleService {
  const HabitScheduleService();

  bool isActiveForScheduling(Habit habit) {
    return habit.status == HabitStatus.active;
  }

  /// Whether [date] is a scheduled occurrence for an active habit.
  bool isScheduledOn(Habit habit, LocalDate date) {
    if (!isActiveForScheduling(habit)) return false;
    if (date.isBefore(habit.startDate)) return false;

    switch (habit.frequencyType) {
      case HabitFrequencyType.daily:
        return true;
      case HabitFrequencyType.selectedWeekdays:
        return habit.selectedWeekdays.contains(date.weekday);
      case HabitFrequencyType.timesPerWeek:
        // Any day on/after start can host an occurrence; weekly cap is
        // enforced by progress/streak semantics (at most one per date).
        return true;
    }
  }

  List<LocalDate> scheduledDatesInRange(
    Habit habit,
    LocalDate start,
    LocalDate endInclusive,
  ) {
    if (endInclusive.isBefore(start)) return const [];
    final out = <LocalDate>[];
    var cursor = start;
    while (!cursor.isAfter(endInclusive)) {
      if (isScheduledOn(habit, cursor)) {
        out.add(cursor);
      }
      cursor = cursor.addDays(1);
    }
    return out;
  }

  int scheduledCountInWeek(Habit habit, LocalDate anyDayInWeek) {
    final start = anyDayInWeek.startOfWeek();
    final end = start.addDays(6);
    switch (habit.frequencyType) {
      case HabitFrequencyType.daily:
      case HabitFrequencyType.selectedWeekdays:
        return scheduledDatesInRange(habit, start, end).length;
      case HabitFrequencyType.timesPerWeek:
        final target = habit.timesPerWeek ?? 1;
        // Expected occurrences for the week target (capped by remaining days
        // after startDate within the week).
        final available = scheduledDatesInRange(habit, start, end).length;
        return available < target ? available : target;
    }
  }
}
