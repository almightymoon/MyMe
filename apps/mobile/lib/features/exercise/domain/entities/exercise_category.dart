enum ExerciseCategory { strength, running, yoga, cycling, hiit, mobility }

extension ExerciseCategoryX on ExerciseCategory {
  String get label {
    switch (this) {
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.running:
        return 'Running';
      case ExerciseCategory.yoga:
        return 'Yoga';
      case ExerciseCategory.cycling:
        return 'Cycling';
      case ExerciseCategory.hiit:
        return 'HIIT';
      case ExerciseCategory.mobility:
        return 'Mobility';
    }
  }

  String get subtitle {
    switch (this) {
      case ExerciseCategory.strength:
        return 'Build power with mindful lifts';
      case ExerciseCategory.running:
        return 'Steady cardio and outdoor pace';
      case ExerciseCategory.yoga:
        return 'Balance, breath, and flow';
      case ExerciseCategory.cycling:
        return 'Endurance on two wheels';
      case ExerciseCategory.hiit:
        return 'Short bursts, high energy';
      case ExerciseCategory.mobility:
        return 'Stretch, recover, stay limber';
    }
  }

  String get id => name;
}
