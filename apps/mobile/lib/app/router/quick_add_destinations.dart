import 'route_names.dart';

/// Canonical Quick Add → route mapping used by the sheet and route tests.
abstract final class QuickAddDestinations {
  static const Map<String, String> byActionKey = {
    'quick_add_goal': RoutePaths.addGoal,
    'quick_add_transaction': RoutePaths.addTransaction,
    'quick_add_event': RoutePaths.addEvent,
    'quick_add_habit': RoutePaths.addHabit,
    'quick_add_meal': RoutePaths.nutritionComingSoon,
  };

  static String pathFor(String actionKey) {
    final path = byActionKey[actionKey];
    if (path == null) {
      throw ArgumentError.value(
        actionKey,
        'actionKey',
        'Unknown Quick Add action',
      );
    }
    return path;
  }
}
