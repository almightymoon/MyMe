import '../domain/entities/exercise_category.dart';

/// Centralized paths for MeMy exercise category illustrations.
///
/// These assets are decorative category / promotional artwork.
/// They are not instructional form guides or medical advice.
abstract final class ExerciseAssets {
  static const String strengthLungeDumbbells =
      'assets/images/exercise/strength-lunge-dumbbells.webp';
  static const String runningCardio =
      'assets/images/exercise/running-cardio.webp';
  static const String yogaWarrior = 'assets/images/exercise/yoga-warrior.webp';
  static const String cyclingCardio =
      'assets/images/exercise/cycling-cardio.webp';
  static const String hiitBodyweightSquat =
      'assets/images/exercise/hiit-bodyweight-squat.webp';
  static const String mobilitySideStretch =
      'assets/images/exercise/mobility-side-stretch.webp';

  static const List<String> allCategoryImages = [
    strengthLungeDumbbells,
    runningCardio,
    yogaWarrior,
    cyclingCardio,
    hiitBodyweightSquat,
    mobilitySideStretch,
  ];

  static String pathFor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.strength:
        return strengthLungeDumbbells;
      case ExerciseCategory.running:
        return runningCardio;
      case ExerciseCategory.yoga:
        return yogaWarrior;
      case ExerciseCategory.cycling:
        return cyclingCardio;
      case ExerciseCategory.hiit:
        return hiitBodyweightSquat;
      case ExerciseCategory.mobility:
        return mobilitySideStretch;
    }
  }

  /// Accessible description — clarifies decorative intent.
  static String semanticLabelFor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.strength:
        return 'Decorative illustration for Strength: athlete with dumbbells. '
            'Not an exercise-form demonstration.';
      case ExerciseCategory.running:
        return 'Decorative illustration for Running: athlete jogging. '
            'Not an exercise-form demonstration.';
      case ExerciseCategory.yoga:
        return 'Decorative illustration for Yoga: athlete in a warrior pose. '
            'Not an exercise-form demonstration.';
      case ExerciseCategory.cycling:
        return 'Decorative illustration for Cycling: athlete on a bicycle. '
            'Not an exercise-form demonstration.';
      case ExerciseCategory.hiit:
        return 'Decorative illustration for HIIT: athlete in a squat stance. '
            'Not an exercise-form demonstration.';
      case ExerciseCategory.mobility:
        return 'Decorative illustration for Mobility: athlete in a side stretch. '
            'Not an exercise-form demonstration.';
    }
  }
}
