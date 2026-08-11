abstract final class RouteNames {
  static const String onboarding = 'onboarding';
  static const String welcome = 'welcome';
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
  static const String habitDetail = 'habitDetail';
  static const String editHabit = 'editHabit';
  static const String finance = 'finance';
  static const String addTransaction = 'addTransaction';
  static const String transactionHistory = 'transactionHistory';
  static const String transactionDetail = 'transactionDetail';
  static const String editTransaction = 'editTransaction';
  static const String financeBudgets = 'financeBudgets';
  static const String addBudget = 'addBudget';
  static const String budgetDetail = 'budgetDetail';
  static const String editBudget = 'editBudget';
  static const String financeReports = 'financeReports';
  static const String financeCategories = 'financeCategories';
  static const String financeMoneyOwed = 'financeMoneyOwed';
  static const String addMoneyOwed = 'addMoneyOwed';
  static const String moneyOwedDetail = 'moneyOwedDetail';
  static const String editMoneyOwed = 'editMoneyOwed';
  static const String calendar = 'calendar';
  static const String addEvent = 'addEvent';
  static const String calendarConnect = 'calendarConnect';
  static const String calendarSelection = 'calendarSelection';
  static const String calendarConflicts = 'calendarConflicts';
  static const String calendarRecovery = 'calendarRecovery';
  static const String eventDetail = 'eventDetail';
  static const String editEvent = 'editEvent';
  static const String health = 'health';
  static const String healthConnect = 'healthConnect';
  static const String healthPermissions = 'healthPermissions';
  static const String healthWorkouts = 'healthWorkouts';
  static const String exercise = 'exercise';
  static const String exerciseLibrary = 'exerciseLibrary';
  static const String workoutSession = 'workoutSession';
  static const String wardrobe = 'wardrobe';
  static const String wardrobeItems = 'wardrobeItems';
  static const String addWardrobeItem = 'addWardrobeItem';
  static const String wardrobeItemDetail = 'wardrobeItemDetail';
  static const String editWardrobeItem = 'editWardrobeItem';
  static const String wardrobeOutfits = 'wardrobeOutfits';
  static const String addOutfit = 'addOutfit';
  static const String outfitDetail = 'outfitDetail';
  static const String editOutfit = 'editOutfit';
  static const String wardrobeSuggestions = 'wardrobeSuggestions';
  static const String wardrobePlanner = 'wardrobePlanner';
  static const String wardrobeHistory = 'wardrobeHistory';
  static const String wardrobeSettings = 'wardrobeSettings';
  static const String body = 'body';
  static const String settings = 'settings';
  static const String connectedApps = 'connectedApps';
  static const String integrationDiagnostics = 'integrationDiagnostics';
  static const String integrationLab = 'integrationLab';
  static const String notifications = 'notifications';
  static const String appearance = 'appearance';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String privacy = 'privacy';
  static const String privacyExport = 'privacyExport';
  static const String privacyDeletion = 'privacyDeletion';
  static const String privacyAiDataUse = 'privacyAiDataUse';
  static const String security = 'security';
  static const String support = 'support';
  static const String helpArticle = 'helpArticle';
  static const String helpContact = 'helpContact';
  static const String helpReportProblem = 'helpReportProblem';
  static const String helpFeatureRequest = 'helpFeatureRequest';
  static const String legal = 'legal';
  static const String legalDocument = 'legalDocument';
  static const String about = 'about';
  static const String whatsNew = 'whatsNew';
  static const String nutritionComingSoon = 'nutritionComingSoon';
}

abstract final class RoutePaths {
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
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
  static const String habitDetail = '/habits/:habitId';
  static const String editHabit = '/habits/:habitId/edit';
  static const String finance = '/finance';
  static const String addTransaction = '/finance/new';
  static const String transactionHistory = '/finance/history';
  static const String transactionDetail = '/finance/tx/:transactionId';
  static const String editTransaction = '/finance/tx/:transactionId/edit';
  static const String financeBudgets = '/finance/budgets';
  static const String addBudget = '/finance/budgets/new';
  static const String budgetDetail = '/finance/budgets/:budgetId';
  static const String editBudget = '/finance/budgets/:budgetId/edit';
  static const String financeReports = '/finance/reports';
  static const String financeCategories = '/finance/categories';
  static const String financeMoneyOwed = '/finance/owed';
  static const String addMoneyOwed = '/finance/owed/new';
  static const String moneyOwedDetail = '/finance/owed/:positionId';
  static const String editMoneyOwed = '/finance/owed/:positionId/edit';
  static const String calendar = '/calendar';
  static const String addEvent = '/calendar/new';
  static const String calendarConnect = '/calendar/connect';
  static const String calendarSelection = '/calendar/connect/select';
  static const String calendarConflicts = '/calendar/conflicts';
  static const String calendarRecovery = '/calendar/recovery';
  static const String eventDetail = '/calendar/event/:eventId';
  static const String editEvent = '/calendar/event/:eventId/edit';
  static const String health = '/health';
  static const String healthConnect = '/health/connect';
  static const String healthPermissions = '/health/permissions';
  static const String healthWorkouts = '/health/workouts';
  static const String exercise = '/exercise';
  static const String exerciseLibrary = '/exercise/library';
  static const String workoutSession = '/exercise/session';
  static const String wardrobe = '/wardrobe';
  static const String wardrobeItems = '/wardrobe/items';
  static const String addWardrobeItem = '/wardrobe/items/new';
  static const String wardrobeItemDetail = '/wardrobe/items/:itemId';
  static const String editWardrobeItem = '/wardrobe/items/:itemId/edit';
  static const String wardrobeOutfits = '/wardrobe/outfits';
  static const String addOutfit = '/wardrobe/outfits/new';
  static const String outfitDetail = '/wardrobe/outfits/:outfitId';
  static const String editOutfit = '/wardrobe/outfits/:outfitId/edit';
  static const String wardrobeSuggestions = '/wardrobe/suggestions';
  static const String wardrobePlanner = '/wardrobe/planner';
  static const String wardrobeHistory = '/wardrobe/history';
  static const String wardrobeSettings = '/settings/wardrobe';
  static const String body = '/body';
  static const String settings = '/settings';
  static const String connectedApps = '/settings/connections';
  static const String integrationDiagnostics =
      '/settings/connections/diagnostics';
  static const String integrationLab = '/settings/connections/lab';
  static const String notifications = '/settings/notifications';
  static const String appearance = '/settings/accessibility';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String privacy = '/privacy';
  static const String privacyExport = '/privacy/export';
  static const String privacyDeletion = '/privacy/delete';
  static const String privacyAiDataUse = '/privacy/ai';
  static const String security = '/security';
  static const String support = '/support';
  static const String help = '/support';
  static const String helpArticle = '/support/article/:articleId';
  static const String helpContact = '/support/contact';
  static const String helpReportProblem = '/support/report';
  static const String helpFeatureRequest = '/support/feature';
  static const String legal = '/legal';
  static const String legalDocument = '/legal/:documentType';
  static const String about = '/about';
  static const String whatsNew = '/about/whats-new';
  static const String nutritionComingSoon = '/nutrition/coming-soon';

  static String eventDetailPath(String eventId) => '/calendar/event/$eventId';

  static String editEventPath(String eventId) =>
      '/calendar/event/$eventId/edit';

  static String goalDetailPath(String goalId) => '/goals/$goalId';

  static String habitDetailPath(String habitId) => '/habits/$habitId';

  static String editHabitPath(String habitId) => '/habits/$habitId/edit';

  static String transactionDetailPath(String transactionId) =>
      '/finance/tx/$transactionId';

  static String editTransactionPath(String transactionId) =>
      '/finance/tx/$transactionId/edit';

  static String wardrobeItemPath(String itemId) => '/wardrobe/items/$itemId';

  static String editWardrobeItemPath(String itemId) =>
      '/wardrobe/items/$itemId/edit';

  static String outfitDetailPath(String outfitId) =>
      '/wardrobe/outfits/$outfitId';

  static String editOutfitPath(String outfitId) =>
      '/wardrobe/outfits/$outfitId/edit';

  static String budgetDetailPath(String budgetId) =>
      '/finance/budgets/$budgetId';

  static String editBudgetPath(String budgetId) =>
      '/finance/budgets/$budgetId/edit';

  static String moneyOwedDetailPath(String positionId) =>
      '/finance/owed/$positionId';

  static String editMoneyOwedPath(String positionId) =>
      '/finance/owed/$positionId/edit';

  static String exerciseLibraryPath([String? categoryId]) {
    if (categoryId == null || categoryId.isEmpty) return exerciseLibrary;
    return '$exerciseLibrary?category=$categoryId';
  }

  static String helpArticlePath(String articleId) =>
      '/support/article/$articleId';

  static String legalDocumentPath(String documentType) =>
      '/legal/$documentType';
}
