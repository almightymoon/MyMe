enum GoalCategory {
  financial,
  career,
  education,
  fitness,
  health,
  personalDevelopment,
  business,
  travel,
  custom,
}

enum GoalPriority { low, medium, high, critical }

enum GoalStatus { active, paused, completed, archived }

extension GoalCategoryX on GoalCategory {
  String get label => switch (this) {
    GoalCategory.financial => 'Financial',
    GoalCategory.career => 'Career',
    GoalCategory.education => 'Education',
    GoalCategory.fitness => 'Fitness',
    GoalCategory.health => 'Health',
    GoalCategory.personalDevelopment => 'Personal development',
    GoalCategory.business => 'Business',
    GoalCategory.travel => 'Travel',
    GoalCategory.custom => 'Custom',
  };
}

extension GoalPriorityX on GoalPriority {
  String get label => switch (this) {
    GoalPriority.low => 'Low',
    GoalPriority.medium => 'Medium',
    GoalPriority.high => 'High',
    GoalPriority.critical => 'Critical',
  };
}

extension GoalStatusX on GoalStatus {
  String get label => switch (this) {
    GoalStatus.active => 'Active',
    GoalStatus.paused => 'Paused',
    GoalStatus.completed => 'Completed',
    GoalStatus.archived => 'Archived',
  };
}
