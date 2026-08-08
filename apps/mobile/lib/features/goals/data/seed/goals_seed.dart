import '../../domain/entities/goal_summary.dart';

/// Demo seed data inspired by `/app/js/data.js`.
abstract final class GoalsSeed {
  static const List<GoalSummary> demoGoals = [
    GoalSummary(
      id: 'house',
      title: 'Buy a House',
      subtitle: 'PKR 150,000,000',
      progressPercent: 7,
    ),
    GoalSummary(
      id: 'emergency',
      title: 'Build Emergency Fund',
      subtitle: 'PKR 430,000 of 1,000,000',
      progressPercent: 43,
    ),
    GoalSummary(
      id: 'weight',
      title: 'Lose 5 kg',
      subtitle: 'Target: 67 kg',
      progressPercent: 65,
    ),
    GoalSummary(
      id: 'paper',
      title: 'Publish Research Paper',
      subtitle: 'Due Dec 15, 2026',
      progressPercent: 20,
    ),
  ];

  static GoalSummary get featured => demoGoals.firstWhere(
    (goal) => goal.id == 'emergency',
    orElse: () => demoGoals.first,
  );
}
