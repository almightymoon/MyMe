enum ExerciseDifficulty { beginner, intermediate, advanced }

extension ExerciseDifficultyX on ExerciseDifficulty {
  String get label {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }
}
