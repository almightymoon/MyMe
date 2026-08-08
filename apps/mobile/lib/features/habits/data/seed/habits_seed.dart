import '../../domain/entities/habit_summary.dart';

/// Demo seed data inspired by `/app/js/data.js`.
abstract final class HabitsSeed {
  static const List<HabitSummary> demoHabits = [
    HabitSummary(
      id: 'walk',
      title: 'Morning walk',
      valueLabel: '4 / 7 days',
      detailLabel: 'This week',
      isOnTrack: true,
    ),
    HabitSummary(
      id: 'water',
      title: 'Drink Water',
      valueLabel: '80%',
      detailLabel: '1.6 / 2.0 L',
      isOnTrack: true,
    ),
    HabitSummary(
      id: 'veggies',
      title: 'Eat Veggies',
      valueLabel: '2 / 3',
      detailLabel: 'servings today',
      isOnTrack: true,
    ),
    HabitSummary(
      id: 'move',
      title: 'Move Daily',
      valueLabel: '6,200',
      detailLabel: 'steps',
      isOnTrack: false,
    ),
  ];
}
