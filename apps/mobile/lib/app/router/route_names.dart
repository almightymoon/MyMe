abstract final class RouteNames {
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  static const String forgotPassword = 'forgotPassword';
  static const String today = 'today';
  static const String plan = 'plan';
  static const String coach = 'coach';
  static const String more = 'more';
  static const String goals = 'goals';
  static const String addGoal = 'addGoal';
  static const String goalDetail = 'goalDetail';
  static const String habits = 'habits';
  static const String addHabit = 'addHabit';
  static const String finance = 'finance';
  static const String addTransaction = 'addTransaction';
  static const String transactionHistory = 'transactionHistory';
  static const String transactionDetail = 'transactionDetail';
  static const String editTransaction = 'editTransaction';
  static const String calendar = 'calendar';
  static const String addEvent = 'addEvent';
  static const String health = 'health';
  static const String exercise = 'exercise';
  static const String exerciseLibrary = 'exerciseLibrary';
  static const String workoutSession = 'workoutSession';
  static const String wardrobe = 'wardrobe';
  static const String body = 'body';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String nutritionComingSoon = 'nutritionComingSoon';
}

abstract final class RoutePaths {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String today = '/today';
  static const String plan = '/plan';
  static const String coach = '/coach';
  static const String more = '/more';
  static const String goals = '/goals';
  static const String addGoal = '/goals/new';
  static const String goalDetail = '/goals/:goalId';
  static const String habits = '/habits';
  static const String addHabit = '/habits/new';
  static const String finance = '/finance';
  static const String addTransaction = '/finance/new';
  static const String transactionHistory = '/finance/history';
  static const String transactionDetail = '/finance/tx/:transactionId';
  static const String editTransaction = '/finance/tx/:transactionId/edit';
  static const String calendar = '/calendar';
  static const String addEvent = '/calendar/new';
  static const String health = '/health';
  static const String exercise = '/exercise';
  static const String exerciseLibrary = '/exercise/library';
  static const String workoutSession = '/exercise/session';
  static const String wardrobe = '/wardrobe';
  static const String body = '/body';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String nutritionComingSoon = '/nutrition/coming-soon';

  static String goalDetailPath(String goalId) => '/goals/$goalId';

  static String transactionDetailPath(String transactionId) =>
      '/finance/tx/$transactionId';

  static String editTransactionPath(String transactionId) =>
      '/finance/tx/$transactionId/edit';

  static String exerciseLibraryPath([String? categoryId]) {
    if (categoryId == null || categoryId.isEmpty) return exerciseLibrary;
    return '$exerciseLibrary?category=$categoryId';
  }
}
