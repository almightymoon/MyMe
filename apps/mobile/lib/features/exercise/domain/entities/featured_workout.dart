import 'exercise_category.dart';

class FeaturedWorkout {
  const FeaturedWorkout({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.category,
    required this.focusAreas,
  });

  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final ExerciseCategory category;
  final List<String> focusAreas;
}

class WeeklyActivitySummary {
  const WeeklyActivitySummary({
    required this.sessionsCompleted,
    required this.activeMinutes,
    required this.streakDays,
    required this.weekLabel,
  });

  final int sessionsCompleted;
  final int activeMinutes;
  final int streakDays;
  final String weekLabel;
}

class RecentActivityItem {
  const RecentActivityItem({
    required this.id,
    required this.title,
    required this.category,
    required this.completedLabel,
    required this.durationMinutes,
  });

  final String id;
  final String title;
  final ExerciseCategory category;
  final String completedLabel;
  final int durationMinutes;
}
