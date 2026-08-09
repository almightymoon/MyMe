/// Demo body / composition data from `/app/js/data.js` (`D.health`).
abstract final class BodySeed {
  static const String displayName = 'Emma';
  static const int bodyScore = 84;
  static const List<double> bodyScoreSpark = [62, 68, 70, 74, 78, 80, 84];

  static const double bmi = 22.4;
  static const String bmiStatus = 'Normal';
  static const int heightCm = 175;
  static const String heightStatus = 'Average';
  static const double weightKg = 72.5;
  static const double weightDeltaKg = -0.5;
  static const double bodyFatPct = 18.6;
  static const double bodyFatDeltaPct = -1.2;

  static const List<BodyMuscleStat> muscleBalance = [
    BodyMuscleStat(name: 'Shoulders', status: 'Good', pct: 72),
    BodyMuscleStat(name: 'Chest', status: 'Good', pct: 68),
    BodyMuscleStat(name: 'Arms', status: 'Good', pct: 70),
    BodyMuscleStat(name: 'Abs', status: 'Excellent', pct: 92),
    BodyMuscleStat(name: 'Legs', status: 'Good', pct: 74),
  ];

  static const BodyWorkoutFocus workoutFocus = BodyWorkoutFocus(
    title: 'Focus on core & lower body',
    subtitle: 'Strengthen your core and build lower body power.',
    tags: ['Core', 'Fat Loss', 'Endurance'],
  );

  static const List<BodyTodayMove> todayWorkout = [
    BodyTodayMove(
      id: 'tw1',
      name: 'Bicycle Crunches',
      detail: '3 × 15',
      tag: 'Abs',
      selected: true,
    ),
    BodyTodayMove(
      id: 'tw2',
      name: 'Bodyweight Squat',
      detail: '3 × 12',
      tag: 'Legs',
      selected: true,
    ),
    BodyTodayMove(
      id: 'tw3',
      name: 'Plank Hold',
      detail: '3 × 40s',
      tag: 'Core',
      selected: false,
    ),
    BodyTodayMove(
      id: 'tw4',
      name: 'Walking Lunges',
      detail: '3 × 10',
      tag: 'Legs',
      selected: false,
    ),
  ];

  static const List<BodyExercisePreview> exercises = [
    BodyExercisePreview(
      id: 'e1',
      name: 'Mountain Climbers',
      muscles: 'Abs · Core',
      detail: '3 × 20',
      tag: 'Abs',
    ),
    BodyExercisePreview(
      id: 'e2',
      name: 'Russian Twist',
      muscles: 'Abs · Obliques',
      detail: '3 × 16',
      tag: 'Abs',
    ),
    BodyExercisePreview(
      id: 'e3',
      name: 'Push-Up',
      muscles: 'Chest · Arms · Core',
      detail: '3 × 12',
      tag: 'Chest',
    ),
    BodyExercisePreview(
      id: 'e4',
      name: 'Reverse Lunge',
      muscles: 'Legs · Glutes',
      detail: '3 × 12',
      tag: 'Legs',
    ),
    BodyExercisePreview(
      id: 'e5',
      name: 'Shoulder Tap Plank',
      muscles: 'Arms · Core',
      detail: '3 × 20',
      tag: 'Arms',
    ),
    BodyExercisePreview(
      id: 'e6',
      name: 'Glute Bridge',
      muscles: 'Legs · Glutes',
      detail: '3 × 15',
      tag: 'Legs',
    ),
  ];

  static const filterTags = ['All', 'Abs', 'Chest', 'Legs', 'Arms'];
}

class BodyMuscleStat {
  const BodyMuscleStat({
    required this.name,
    required this.status,
    required this.pct,
  });

  final String name;
  final String status;
  final int pct;

  bool get isExcellent => status.toLowerCase() == 'excellent';
}

class BodyWorkoutFocus {
  const BodyWorkoutFocus({
    required this.title,
    required this.subtitle,
    required this.tags,
  });

  final String title;
  final String subtitle;
  final List<String> tags;
}

class BodyTodayMove {
  const BodyTodayMove({
    required this.id,
    required this.name,
    required this.detail,
    required this.tag,
    required this.selected,
  });

  final String id;
  final String name;
  final String detail;
  final String tag;
  final bool selected;
}

class BodyExercisePreview {
  const BodyExercisePreview({
    required this.id,
    required this.name,
    required this.muscles,
    required this.detail,
    required this.tag,
  });

  final String id;
  final String name;
  final String muscles;
  final String detail;
  final String tag;
}
