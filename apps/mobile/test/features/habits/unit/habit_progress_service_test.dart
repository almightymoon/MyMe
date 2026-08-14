import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/local_date.dart';
import 'package:memy/features/habits/domain/entities/habit.dart';
import 'package:memy/features/habits/domain/entities/habit_check_in.dart';
import 'package:memy/features/habits/domain/entities/habit_enums.dart';
import 'package:memy/features/habits/domain/entities/habit_progress.dart';
import 'package:memy/features/habits/domain/services/habit_progress_service.dart';

void main() {
  final progress = HabitProgressService();
  final now = DateTime(2026, 8, 9, 12);

  Habit habit({
    String id = 'h1',
    HabitGoalType goalType = HabitGoalType.binary,
    int targetValue = 1,
    HabitFrequencyType frequency = HabitFrequencyType.daily,
    List<int> weekdays = const [],
    int? timesPerWeek,
    LocalDate? startDate,
  }) {
    return Habit(
      id: id,
      name: 'Test',
      category: HabitCategory.health,
      status: HabitStatus.active,
      goalType: goalType,
      targetValue: targetValue,
      unitLabel: goalType == HabitGoalType.count ? 'glasses' : 'min',
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

  HabitCheckIn checkIn({
    required String habitId,
    required LocalDate date,
    required int value,
    bool? completed,
  }) {
    return HabitCheckIn(
      id: 'ci_${habitId}_${date.toIso8601String()}',
      habitId: habitId,
      localDate: date,
      value: value,
      isCompleted: completed ?? value >= 1,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('completion types', () {
    test('binary completion at value >= 1', () {
      final h = habit(goalType: HabitGoalType.binary);
      expect(isHabitValueCompleted(h, 0), isFalse);
      expect(isHabitValueCompleted(h, 1), isTrue);
      expect(normalizedCheckInValue(h, 5), 1);
    });

    test('count completion at target', () {
      final h = habit(goalType: HabitGoalType.count, targetValue: 8);
      expect(isHabitValueCompleted(h, 7), isFalse);
      expect(isHabitValueCompleted(h, 8), isTrue);
    });

    test('duration completion at target minutes', () {
      final h = habit(goalType: HabitGoalType.duration, targetValue: 30);
      expect(isHabitValueCompleted(h, 29), isFalse);
      expect(isHabitValueCompleted(h, 30), isTrue);
    });

    test('isCompletedOn reads check-in flag', () {
      final h = habit();
      final checkIns = [
        checkIn(
          habitId: h.id,
          date: LocalDate(2026, 8, 8),
          value: 1,
          completed: true,
        ),
      ];
      expect(
        progress.isCompletedOn(h, checkIns, LocalDate(2026, 8, 8)),
        isTrue,
      );
      expect(
        progress.isCompletedOn(h, checkIns, LocalDate(2026, 8, 7)),
        isFalse,
      );
    });
  });

  group('daily occurrence streak', () {
    final h = habit(startDate: LocalDate(2026, 8, 5));
    final today = LocalDate(2026, 8, 9); // Tue–Sat scheduled Aug 5–9

    test('no check-ins yields zero streak', () {
      final streak = progress.streakSummary(
        habit: h,
        checkIns: const [],
        today: today,
      );
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
    });

    test('consecutive completions build streak', () {
      final checkIns = [
        for (var d = 5; d <= 8; d++)
          checkIn(habitId: h.id, date: LocalDate(2026, 8, d), value: 1),
      ];
      final streak = progress.streakSummary(
        habit: h,
        checkIns: checkIns,
        today: today,
      );
      expect(streak.currentStreak, 4);
      expect(streak.longestStreak, 4);
    });

    test('missed day breaks streak', () {
      final checkIns = [
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 5), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 6), value: 1),
        // miss 7
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 8), value: 1),
      ];
      final streak = progress.streakSummary(
        habit: h,
        checkIns: checkIns,
        today: today,
      );
      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 2);
    });

    test('incomplete today does not break prior streak', () {
      final checkIns = [
        for (var d = 5; d <= 8; d++)
          checkIn(habitId: h.id, date: LocalDate(2026, 8, d), value: 1),
      ];
      final streak = progress.streakSummary(
        habit: h,
        checkIns: checkIns,
        today: today,
      );
      // Today (9) incomplete but streak from 5–8 preserved
      expect(streak.currentStreak, 4);
    });
  });

  group('selected weekday streak', () {
    final h = habit(
      frequency: HabitFrequencyType.selectedWeekdays,
      weekdays: const [DateTime.monday, DateTime.wednesday, DateTime.friday],
      startDate: LocalDate(2026, 8, 3),
    );

    test('unscheduled days are ignored', () {
      // Mon 3, Wed 5, Fri 7 completed; Tue 4 skipped; today Sun 9 unscheduled
      final checkIns = [
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 3), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 5), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 7), value: 1),
      ];
      final today = LocalDate(2026, 8, 9);
      final streak = progress.streakSummary(
        habit: h,
        checkIns: checkIns,
        today: today,
      );
      expect(streak.currentStreak, 3);
    });
  });

  group('longest streak', () {
    test('tracks best run across history', () {
      final h = habit(startDate: LocalDate(2026, 8, 1));
      final checkIns = [
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 1), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 2), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 3), value: 1),
        // miss 4
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 5), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 6), value: 1),
      ];
      final today = LocalDate(2026, 8, 9);
      final streak = progress.streakSummary(
        habit: h,
        checkIns: checkIns,
        today: today,
      );
      expect(streak.longestStreak, 3);
      expect(streak.currentStreak, 0);
    });
  });

  group('times-per-week week streak', () {
    final h = habit(
      frequency: HabitFrequencyType.timesPerWeek,
      timesPerWeek: 2,
      startDate: LocalDate(2026, 7, 20),
    );

    test('consecutive successful weeks', () {
      // Week of Aug 3: Mon+Wed; week of Aug 10 not reached — today Sun Aug 9
      final checkIns = [
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 4), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 6), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 7, 28), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 7, 30), value: 1),
      ];
      final today = LocalDate(2026, 8, 9);
      final streak = progress.streakSummary(
        habit: h,
        checkIns: checkIns,
        today: today,
      );
      expect(streak.isWeekStreak, isTrue);
      expect(streak.currentStreak, 2);
    });

    test('incomplete current week does not break streak', () {
      final checkIns = [
        checkIn(habitId: h.id, date: LocalDate(2026, 7, 28), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 7, 30), value: 1),
        // current week Aug 3–9: only one completion so far
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 4), value: 1),
      ];
      final today = LocalDate(2026, 8, 9);
      final streak = progress.streakSummary(
        habit: h,
        checkIns: checkIns,
        today: today,
      );
      expect(streak.currentStreak, 1);
    });
  });

  group('weekly completion percent', () {
    test('daily habit percent for current week', () {
      final h = habit(startDate: LocalDate(2026, 8, 1));
      final checkIns = [
        for (var d = 3; d <= 7; d++)
          checkIn(habitId: h.id, date: LocalDate(2026, 8, d), value: 1),
      ];
      final week = progress.weeklySummary(
        habit: h,
        checkIns: checkIns,
        anyDayInWeek: LocalDate(2026, 8, 9),
      );
      expect(week.scheduledCount, 7);
      expect(week.completedCount, 5);
      expect(week.completionPercent, 71);
    });

    test('times-per-week uses capped scheduled count', () {
      final h = habit(
        frequency: HabitFrequencyType.timesPerWeek,
        timesPerWeek: 3,
        startDate: LocalDate(2026, 8, 1),
      );
      final checkIns = [
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 4), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 5), value: 1),
        checkIn(habitId: h.id, date: LocalDate(2026, 8, 6), value: 1),
      ];
      final week = progress.weeklySummary(
        habit: h,
        checkIns: checkIns,
        anyDayInWeek: LocalDate(2026, 8, 9),
      );
      expect(week.scheduledCount, 3);
      expect(week.completedCount, 3);
      expect(week.completionPercent, 100);
    });
  });
}
