enum HabitCategory {
  health,
  fitness,
  learning,
  mindfulness,
  productivity,
  faith,
  nutrition,
  custom;

  String get label => switch (this) {
    HabitCategory.health => 'Health',
    HabitCategory.fitness => 'Fitness',
    HabitCategory.learning => 'Learning',
    HabitCategory.mindfulness => 'Mindfulness',
    HabitCategory.productivity => 'Productivity',
    HabitCategory.faith => 'Faith',
    HabitCategory.nutrition => 'Nutrition',
    HabitCategory.custom => 'Custom',
  };

  static HabitCategory tryParse(String? raw) {
    if (raw == null) return HabitCategory.custom;
    for (final value in HabitCategory.values) {
      if (value.name == raw) return value;
    }
    return HabitCategory.custom;
  }
}

enum HabitStatus {
  active,
  paused,
  archived;

  String get label => switch (this) {
    HabitStatus.active => 'Active',
    HabitStatus.paused => 'Paused',
    HabitStatus.archived => 'Archived',
  };

  static HabitStatus tryParse(String? raw) {
    if (raw == null) return HabitStatus.active;
    for (final value in HabitStatus.values) {
      if (value.name == raw) return value;
    }
    return HabitStatus.active;
  }
}

enum HabitGoalType {
  binary,
  count,
  duration;

  String get label => switch (this) {
    HabitGoalType.binary => 'Binary',
    HabitGoalType.count => 'Count',
    HabitGoalType.duration => 'Duration',
  };

  static HabitGoalType tryParse(String? raw) {
    if (raw == null) return HabitGoalType.binary;
    for (final value in HabitGoalType.values) {
      if (value.name == raw) return value;
    }
    return HabitGoalType.binary;
  }
}

enum HabitFrequencyType {
  daily,
  selectedWeekdays,
  timesPerWeek;

  String get label => switch (this) {
    HabitFrequencyType.daily => 'Daily',
    HabitFrequencyType.selectedWeekdays => 'Selected weekdays',
    HabitFrequencyType.timesPerWeek => 'Times per week',
  };

  static HabitFrequencyType tryParse(String? raw) {
    if (raw == null) return HabitFrequencyType.daily;
    for (final value in HabitFrequencyType.values) {
      if (value.name == raw) return value;
    }
    return HabitFrequencyType.daily;
  }
}
