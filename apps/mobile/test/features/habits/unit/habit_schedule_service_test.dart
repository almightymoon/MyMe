import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/habits/domain/entities/habit.dart';
import 'package:memy/features/habits/domain/entities/habit_enums.dart';
import 'package:memy/features/habits/domain/services/habit_schedule_service.dart';

void main() {
  const schedule = HabitScheduleService();
  final now = DateTime(2026, 8, 9, 12);

  Habit habit({
    String id = 'h1',
    HabitFrequencyType frequency = HabitFrequencyType.daily,
    List<int> weekdays = const [],
    int? timesPerWeek,
    LocalDate? startDate,
    HabitStatus status = HabitStatus.active,
  }) {
    return Habit(
      id: id,
      name: 'Test',
      category: HabitCategory.health,
      status: status,
      goalType: HabitGoalType.binary,
      targetValue: 1,
      frequencyType: frequency,
      selectedWeekdays: weekdays,
      timesPerWeek: timesPerWeek,
      startDate: startDate ?? LocalDate(2026, 8, 1),
      iconKey: 'check',
      colorKey: 'ember',
      createdAt: now,
      updatedAt: now,
    );
  }

  group('daily', () {
    test('scheduled every day on/after start', () {
      final h = habit(startDate: LocalDate(2026, 8, 5));
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 4)), isFalse);
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 5)), isTrue);
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 9)), isTrue);
    });
  });

  group('selected weekdays', () {
    test('only selected weekdays are scheduled', () {
      final h = habit(
        frequency: HabitFrequencyType.selectedWeekdays,
        weekdays: const [DateTime.monday, DateTime.wednesday, DateTime.friday],
        startDate: LocalDate(2026, 8, 1),
      );
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 10)), isTrue); // Mon
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 11)), isFalse); // Tue
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 12)), isTrue); // Wed
    });
  });

  group('times per week', () {
    test('any day on/after start can host occurrence', () {
      final h = habit(
        frequency: HabitFrequencyType.timesPerWeek,
        timesPerWeek: 3,
        startDate: LocalDate(2026, 8, 1),
      );
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 9)), isTrue);
      expect(schedule.isScheduledOn(h, LocalDate(2026, 7, 31)), isFalse);
    });

    test('scheduledCountInWeek caps at timesPerWeek', () {
      final h = habit(
        frequency: HabitFrequencyType.timesPerWeek,
        timesPerWeek: 3,
        startDate: LocalDate(2026, 8, 1),
      );
      expect(schedule.scheduledCountInWeek(h, LocalDate(2026, 8, 9)), 3);
    });

    test('scheduledCountInWeek respects partial start week', () {
      final h = habit(
        frequency: HabitFrequencyType.timesPerWeek,
        timesPerWeek: 5,
        startDate: LocalDate(2026, 8, 8), // Saturday
      );
      // Week Mon Aug 3 – Sun Aug 9: only Sat+Sun available after start → 2
      expect(schedule.scheduledCountInWeek(h, LocalDate(2026, 8, 9)), 2);
    });
  });

  group('inactive habits', () {
    test('paused habits are not scheduled', () {
      final h = habit(status: HabitStatus.paused);
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 9)), isFalse);
    });

    test('archived habits are not scheduled', () {
      final h = habit(status: HabitStatus.archived);
      expect(schedule.isScheduledOn(h, LocalDate(2026, 8, 9)), isFalse);
    });
  });

  group('week boundaries', () {
    test('scheduledDatesInRange uses Monday-start weeks', () {
      final h = habit(startDate: LocalDate(2026, 8, 3));
      final weekStart = LocalDate(2026, 8, 3); // Monday
      final weekEnd = LocalDate(2026, 8, 9); // Sunday
      final dates = schedule.scheduledDatesInRange(h, weekStart, weekEnd);
      expect(dates, hasLength(7));
      expect(dates.first, weekStart);
      expect(dates.last, weekEnd);
    });

    test('selected weekdays count within week range', () {
      final h = habit(
        frequency: HabitFrequencyType.selectedWeekdays,
        weekdays: const [DateTime.monday, DateTime.wednesday, DateTime.friday],
        startDate: LocalDate(2026, 8, 1),
      );
      expect(schedule.scheduledCountInWeek(h, LocalDate(2026, 8, 9)), 3);
    });
  });

  group('scheduledDatesInRange', () {
    test('returns empty when end before start', () {
      final h = habit();
      expect(
        schedule.scheduledDatesInRange(
          h,
          LocalDate(2026, 8, 10),
          LocalDate(2026, 8, 9),
        ),
        isEmpty,
      );
    });
  });
}
