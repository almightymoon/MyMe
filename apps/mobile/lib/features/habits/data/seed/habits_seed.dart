import '../../../../core/domain/value_objects/local_date.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_check_in.dart';
import '../../domain/entities/habit_enums.dart';

/// Demo Habits for first-run local seed and FakeHabitRepository defaults.
///
/// Never import from presentation. First-run local seeding uses this once;
/// deleting all Habits does not reseed.
abstract final class HabitsSeed {
  static List<Habit> demoHabits({
    required LocalDate today,
    required DateTime now,
  }) {
    final start = today.addDays(-14);
    return [
      Habit(
        id: 'habit_morning_walk',
        name: 'Morning Walk',
        description: 'Start the day with movement',
        category: HabitCategory.fitness,
        status: HabitStatus.active,
        goalType: HabitGoalType.binary,
        targetValue: 1,
        frequencyType: HabitFrequencyType.daily,
        startDate: start,
        iconKey: 'walk',
        colorKey: 'ember',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Habit(
        id: 'habit_read',
        name: 'Read',
        description: 'Focused reading time',
        category: HabitCategory.learning,
        status: HabitStatus.active,
        goalType: HabitGoalType.duration,
        targetValue: 30,
        unitLabel: 'min',
        frequencyType: HabitFrequencyType.selectedWeekdays,
        selectedWeekdays: const [
          DateTime.monday,
          DateTime.wednesday,
          DateTime.friday,
        ],
        startDate: start,
        iconKey: 'book',
        colorKey: 'learning',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Habit(
        id: 'habit_water',
        name: 'Drink Water',
        category: HabitCategory.health,
        status: HabitStatus.active,
        goalType: HabitGoalType.count,
        targetValue: 8,
        unitLabel: 'glasses',
        frequencyType: HabitFrequencyType.daily,
        startDate: start,
        iconKey: 'water',
        colorKey: 'health',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Habit(
        id: 'habit_gym',
        name: 'Strength Training',
        category: HabitCategory.fitness,
        status: HabitStatus.active,
        goalType: HabitGoalType.binary,
        targetValue: 1,
        frequencyType: HabitFrequencyType.timesPerWeek,
        timesPerWeek: 3,
        startDate: start,
        iconKey: 'fitness',
        colorKey: 'ember',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<HabitCheckIn> demoCheckIns({
    required LocalDate today,
    required DateTime now,
  }) {
    final out = <HabitCheckIn>[];
    // Morning walk: last 4 days completed (including today incomplete intentionally).
    for (var i = 1; i <= 4; i++) {
      final d = today.addDays(-i);
      out.add(
        HabitCheckIn(
          id: 'ci_walk_$i',
          habitId: 'habit_morning_walk',
          localDate: d,
          value: 1,
          isCompleted: true,
          createdAt: now.subtract(Duration(days: i)),
          updatedAt: now.subtract(Duration(days: i)),
        ),
      );
    }
    // Water: partial today
    out.add(
      HabitCheckIn(
        id: 'ci_water_today',
        habitId: 'habit_water',
        localDate: today,
        value: 3,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return out;
  }
}
