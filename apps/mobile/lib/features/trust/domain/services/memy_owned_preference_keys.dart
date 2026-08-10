import '../../../finance/data/repositories/local_finance_repository.dart';
import '../../../goals/data/repositories/local_goal_repository.dart';
import '../../../habits/data/repositories/local_habit_repository.dart';
import '../../../health/data/repositories/health_connection_storage.dart';
import '../../presentation/appearance/appearance_preferences.dart';

/// Audited SharedPreferences keys owned by MeMy feature modules.
///
/// Preference wipe and contract tests must only touch registered keys —
/// never call [SharedPreferences.clear] blindly.
abstract final class MemyOwnedPreferenceKeys {
  /// Appearance / accessibility preferences wiped by preferences scope.
  static const Set<String> appearance = {
    AppearancePreferences.themeModeKey,
    AppearancePreferences.reduceMotionKey,
  };

  static const Set<String> goals = {
    LocalGoalRepository.storageKey,
    LocalGoalRepository.initializedKey,
  };

  static const Set<String> finance = {
    LocalFinanceRepository.storageKey,
    LocalFinanceRepository.initializedKey,
  };

  static const Set<String> habits = {
    LocalHabitRepository.storageKey,
    LocalHabitRepository.initializedKey,
  };

  static const Set<String> healthConnection = {
    HealthConnectionStorageKeys.primary,
    HealthConnectionStorageKeys.backup,
    HealthConnectionStorageKeys.legacy,
  };

  /// All MeMy-owned keys known to this milestone.
  static Set<String> get all => {
    ...appearance,
    ...goals,
    ...finance,
    ...habits,
    ...healthConnection,
  };

  /// Keys safe to remove during a preferences-only wipe.
  static Set<String> get preferencesWipeTargets => appearance;
}
