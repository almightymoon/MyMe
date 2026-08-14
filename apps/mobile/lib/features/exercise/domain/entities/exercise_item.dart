import 'exercise_category.dart';
import 'exercise_difficulty.dart';

class ExerciseItem {
  const ExerciseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.equipment,
    required this.primaryMuscles,
    required this.description,
    required this.safetyNote,
    this.durationMinutes,
    this.sets,
    this.repetitions,
  });

  final String id;
  final String name;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final String equipment;
  final List<String> primaryMuscles;
  final String description;

  /// Reminder that category art is decorative and form needs care.
  final String safetyNote;
  final int? durationMinutes;
  final int? sets;
  final int? repetitions;

  String get effortLabel {
    if (sets != null && repetitions != null) {
      return '$sets × $repetitions';
    }
    if (durationMinutes != null) {
      return '$durationMinutes min';
    }
    return 'Open';
  }

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    final difficultyName = json['difficulty'] as String?;
    final category = ExerciseCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => throw FormatException('Unknown category: $categoryName'),
    );
    final difficulty = ExerciseDifficulty.values.firstWhere(
      (d) => d.name == difficultyName,
      orElse: () =>
          throw FormatException('Unknown difficulty: $difficultyName'),
    );
    final muscles = json['primaryMuscles'];
    if (muscles is! List) {
      throw const FormatException('primaryMuscles must be a list');
    }
    return ExerciseItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: category,
      difficulty: difficulty,
      equipment: json['equipment'] as String? ?? 'None',
      primaryMuscles: muscles.map((e) => e.toString()).toList(),
      description: json['description'] as String? ?? '',
      safetyNote:
          json['safetyNote'] as String? ??
          'Move with control. Category artwork is decorative, not form guidance.',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      sets: (json['sets'] as num?)?.toInt(),
      repetitions: (json['repetitions'] as num?)?.toInt(),
    );
  }
}
