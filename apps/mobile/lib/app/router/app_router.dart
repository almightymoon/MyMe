import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../features/auth/presentation/account_sign_in_screen.dart';
import '../../features/auth/presentation/device_sessions_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/body/presentation/body_composition_screen.dart';
import '../../features/calendar/domain/entities/device_calendar_descriptor.dart';
import '../../features/calendar/presentation/screens/add_calendar_event_screen.dart';
import '../../features/calendar/presentation/screens/calendar_connection_screen.dart';
import '../../features/calendar/presentation/screens/calendar_conflict_screen.dart';
import '../../features/calendar/presentation/screens/calendar_event_detail_screen.dart';
import '../../features/calendar/presentation/screens/calendar_overview_screen.dart';
import '../../features/calendar/presentation/screens/calendar_recovery_screen.dart';
import '../../features/calendar/presentation/screens/calendar_selection_screen.dart';
import '../../features/calendar/presentation/screens/edit_calendar_event_screen.dart';
import '../../features/coach/presentation/coach_screen.dart';
import '../../features/exercise/presentation/screens/exercise_library_screen.dart';
import '../../features/exercise/presentation/screens/exercise_overview_screen.dart';
import '../../features/exercise/presentation/screens/workout_session_placeholder_screen.dart';
import '../../features/finance/presentation/screens/add_budget_screen.dart';
import '../../features/finance/presentation/screens/add_money_owed_screen.dart';
import '../../features/finance/presentation/screens/add_transaction_screen.dart';
import '../../features/finance/presentation/screens/budget_detail_screen.dart';
import '../../features/finance/presentation/screens/budgets_overview_screen.dart';
import '../../features/finance/presentation/screens/edit_budget_screen.dart';
import '../../features/finance/presentation/screens/edit_money_owed_screen.dart';
import '../../features/finance/presentation/screens/edit_transaction_screen.dart';
import '../../features/finance/presentation/screens/finance_categories_screen.dart';
import '../../features/finance/presentation/screens/finance_overview_screen.dart';
import '../../features/finance/presentation/screens/finance_reports_screen.dart';
import '../../features/finance/presentation/screens/money_owed_detail_screen.dart';
import '../../features/finance/presentation/screens/money_owed_overview_screen.dart';
import '../../features/finance/presentation/screens/transaction_detail_screen.dart';
import '../../features/finance/presentation/screens/transaction_history_screen.dart';
import '../../features/goals/presentation/screens/add_goal_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/goals/presentation/screens/goals_list_screen.dart';
import '../../features/habits/presentation/screens/add_habit_screen.dart';
import '../../features/habits/presentation/screens/edit_habit_screen.dart';
import '../../features/habits/presentation/screens/habit_detail_screen.dart';
import '../../features/habits/presentation/screens/habits_overview_screen.dart';
import '../../features/health/presentation/health_connection_screen.dart';
import '../../features/health/presentation/health_overview_screen.dart';
import '../../features/health/presentation/health_permission_selection_screen.dart';
import '../../features/health/presentation/health_workouts_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/onboarding/application/onboarding_providers.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/connected_apps_screen.dart';
import '../../features/settings/presentation/integration_diagnostics_screen.dart';
import '../../features/settings/presentation/integration_lab_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/memy_app_shell.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/trust/domain/entities/trust_document.dart';
import '../../features/trust/presentation/about/about_memy_screen.dart';
import '../../features/trust/presentation/appearance/appearance_accessibility_screen.dart';
import '../../features/trust/presentation/appearance/notifications_reminders_screen.dart';
import '../../features/trust/presentation/legal/legal_center_screen.dart';
import '../../features/trust/presentation/privacy/ai_data_use_screen.dart';
import '../../features/trust/presentation/privacy/deletion_screen.dart';
import '../../features/trust/presentation/privacy/export_screen.dart';
import '../../features/trust/presentation/privacy/privacy_data_center_screen.dart';
import '../../features/sync/presentation/conflict_center_screen.dart';
import '../../features/sync/presentation/sync_center_screen.dart';
import '../../features/trust/presentation/security/security_screen.dart';
import '../../features/trust/presentation/support/help_support_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_flow_screens.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_item_form_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_items_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_overview_screen.dart';
import '../../features/wardrobe/presentation/screens/wardrobe_settings_screen.dart';
import '../../core/config/release_capabilities.dart';
import '../../core/widgets/coming_soon_view.dart';
import '../../core/widgets/not_found_screen.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _todayNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final _planNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'plan');
final _coachNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'coach');
final _moreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'more');

/// Demo-auth entry points. Unreachable when [ReleaseCapabilities.demoAuth] is
/// false — the screens stay in the codebase for internal builds only.
const _demoAuthPaths = {
  RoutePaths.signIn,
  RoutePaths.signUp,
  RoutePaths.forgotPassword,
};

/// Reachable mid-onboarding: the optional Calendar/Health steps push into the
/// real connection flows, and the privacy copy links out to the trust centre.
const _onboardingEscapes = {
  RoutePaths.calendarConnect,
  RoutePaths.calendarSelection,
  RoutePaths.healthConnect,
  RoutePaths.healthPermissions,
  RoutePaths.privacy,
  RoutePaths.legal,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final capabilities = ref.watch(releaseCapabilitiesProvider);
  final demoAuth = capabilities.demoAuth;
  final accountAuth = capabilities.accountAuth;
  final signedIn = ref.watch(authSessionProvider) != null;

  // Read (not watch): the router must not rebuild mid-flow. Redirects call
  // this on every navigation, so completion changes are still picked up.
  bool onboardingComplete() => ref.read(onboardingCompletionProvider);

  String postOnboardingHome() =>
      onboardingComplete() ? RoutePaths.today : RoutePaths.onboarding;

  String unsignedLocation() =>
      accountAuth ? RoutePaths.welcome : postOnboardingHome();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    errorBuilder: (context, state) => NotFoundScreen(uri: state.uri),
    initialLocation: demoAuth
        ? RoutePaths.signIn
        : (accountAuth && !signedIn
              ? RoutePaths.welcome
              : postOnboardingHome()),
    redirect: (context, state) {
      final path = state.uri.path;

      if (accountAuth && !signedIn) {
        if (path == RoutePaths.welcome ||
            path == RoutePaths.privacy ||
            path == RoutePaths.legal ||
            path.startsWith('/legal/') ||
            path.startsWith('/privacy/')) {
          return null;
        }
        return RoutePaths.welcome;
      }
      if (accountAuth && signedIn && path == RoutePaths.welcome) {
        return postOnboardingHome();
      }

      if (!demoAuth && _demoAuthPaths.contains(path)) {
        return unsignedLocation();
      }
      if (!capabilities.coachPreview && path == RoutePaths.coach) {
        return RoutePaths.today;
      }
      if (!capabilities.wardrobe &&
          (path == RoutePaths.wardrobe ||
              path.startsWith('/wardrobe/') ||
              path == RoutePaths.wardrobeSettings)) {
        return RoutePaths.today;
      }
      if (!capabilities.body && path == RoutePaths.body) {
        return RoutePaths.today;
      }
      if (!capabilities.nutritionQuickAdd &&
          path == RoutePaths.nutritionComingSoon) {
        return RoutePaths.today;
      }
      if (!capabilities.notifications && path == RoutePaths.notifications) {
        return RoutePaths.settings;
      }
      if (!capabilities.exerciseSessions && path == RoutePaths.workoutSession) {
        return RoutePaths.exercise;
      }
      if (demoAuth || onboardingComplete()) return null;
      if (path == RoutePaths.onboarding) return null;
      if (_onboardingEscapes.any(
        (escape) => path == escape || path.startsWith('$escape/'),
      )) {
        return null;
      }
      return RoutePaths.onboarding;
    },
    routes: [
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        builder: (context, state) => const AccountSignInScreen(),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        name: RouteNames.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RoutePaths.signUp,
        name: RouteNames.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MemyAppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _todayNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.today,
                name: RouteNames.today,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _planNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.plan,
                name: RouteNames.plan,
                builder: (context, state) => const PlanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _coachNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.coach,
                name: RouteNames.coach,
                builder: (context, state) => const CoachScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _moreNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.more,
                name: RouteNames.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addGoal,
        name: RouteNames.addGoal,
        builder: (context, state) => const AddGoalScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.goals,
        name: RouteNames.goals,
        builder: (context, state) => const GoalsListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.goalDetail,
        name: RouteNames.goalDetail,
        builder: (context, state) {
          final goalId = state.pathParameters['goalId'] ?? '';
          return GoalDetailScreen(goalId: goalId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.habits,
        name: RouteNames.habits,
        builder: (context, state) => const HabitsOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addHabit,
        name: RouteNames.addHabit,
        builder: (context, state) => const AddHabitScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.habitDetail,
        name: RouteNames.habitDetail,
        builder: (context, state) {
          final habitId = state.pathParameters['habitId'] ?? '';
          return HabitDetailScreen(habitId: habitId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editHabit,
        name: RouteNames.editHabit,
        builder: (context, state) {
          final habitId = state.pathParameters['habitId'] ?? '';
          return EditHabitScreen(habitId: habitId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.finance,
        name: RouteNames.finance,
        builder: (context, state) => const FinanceOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addTransaction,
        name: RouteNames.addTransaction,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.transactionHistory,
        name: RouteNames.transactionHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.transactionDetail,
        name: RouteNames.transactionDetail,
        builder: (context, state) => TransactionDetailScreen(
          transactionId: state.pathParameters['transactionId']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editTransaction,
        name: RouteNames.editTransaction,
        builder: (context, state) => EditTransactionScreen(
          transactionId: state.pathParameters['transactionId']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.financeBudgets,
        name: RouteNames.financeBudgets,
        builder: (context, state) => const BudgetsOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addBudget,
        name: RouteNames.addBudget,
        builder: (context, state) => const AddBudgetScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.budgetDetail,
        name: RouteNames.budgetDetail,
        builder: (context, state) =>
            BudgetDetailScreen(budgetId: state.pathParameters['budgetId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editBudget,
        name: RouteNames.editBudget,
        builder: (context, state) =>
            EditBudgetScreen(budgetId: state.pathParameters['budgetId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.financeReports,
        name: RouteNames.financeReports,
        builder: (context, state) => const FinanceReportsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.financeCategories,
        name: RouteNames.financeCategories,
        builder: (context, state) => const FinanceCategoriesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.financeMoneyOwed,
        name: RouteNames.financeMoneyOwed,
        builder: (context, state) => const MoneyOwedOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addMoneyOwed,
        name: RouteNames.addMoneyOwed,
        builder: (context, state) => const AddMoneyOwedScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.moneyOwedDetail,
        name: RouteNames.moneyOwedDetail,
        builder: (context, state) => MoneyOwedDetailScreen(
          positionId: state.pathParameters['positionId']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editMoneyOwed,
        name: RouteNames.editMoneyOwed,
        builder: (context, state) => EditMoneyOwedScreen(
          positionId: state.pathParameters['positionId']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.calendar,
        name: RouteNames.calendar,
        builder: (context, state) => const CalendarOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addEvent,
        name: RouteNames.addEvent,
        builder: (context, state) => const AddCalendarEventScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.calendarConnect,
        name: RouteNames.calendarConnect,
        builder: (context, state) => const CalendarConnectionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.calendarSelection,
        name: RouteNames.calendarSelection,
        builder: (context, state) {
          final calendars =
              state.extra as List<DeviceCalendarDescriptor>? ?? const [];
          return CalendarSelectionScreen(calendars: calendars);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.calendarConflicts,
        name: RouteNames.calendarConflicts,
        builder: (context, state) => const CalendarConflictScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.calendarRecovery,
        name: RouteNames.calendarRecovery,
        builder: (context, state) => const CalendarRecoveryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.eventDetail,
        name: RouteNames.eventDetail,
        builder: (context, state) => CalendarEventDetailScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editEvent,
        name: RouteNames.editEvent,
        builder: (context, state) =>
            EditCalendarEventScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.health,
        name: RouteNames.health,
        builder: (context, state) => const HealthOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.healthConnect,
        name: RouteNames.healthConnect,
        builder: (context, state) => const HealthConnectionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.healthPermissions,
        name: RouteNames.healthPermissions,
        builder: (context, state) => const HealthPermissionSelectionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.healthWorkouts,
        name: RouteNames.healthWorkouts,
        builder: (context, state) => const HealthWorkoutsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.exercise,
        name: RouteNames.exercise,
        builder: (context, state) => const ExerciseOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.exerciseLibrary,
        name: RouteNames.exerciseLibrary,
        builder: (context, state) => ExerciseLibraryScreen(
          categoryId: state.uri.queryParameters['category'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.workoutSession,
        name: RouteNames.workoutSession,
        builder: (context, state) => const WorkoutSessionPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobe,
        name: RouteNames.wardrobe,
        builder: (context, state) => const WardrobeOverviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobeItems,
        name: RouteNames.wardrobeItems,
        builder: (context, state) => const WardrobeItemsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addWardrobeItem,
        name: RouteNames.addWardrobeItem,
        builder: (context, state) => const AddWardrobeItemScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobeItemDetail,
        name: RouteNames.wardrobeItemDetail,
        builder: (context, state) =>
            WardrobeItemDetailScreen(itemId: state.pathParameters['itemId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editWardrobeItem,
        name: RouteNames.editWardrobeItem,
        builder: (context, state) =>
            EditWardrobeItemScreen(itemId: state.pathParameters['itemId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobeOutfits,
        name: RouteNames.wardrobeOutfits,
        builder: (context, state) => const OutfitsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addOutfit,
        name: RouteNames.addOutfit,
        builder: (context, state) => const OutfitFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.outfitDetail,
        name: RouteNames.outfitDetail,
        builder: (context, state) =>
            OutfitDetailScreen(outfitId: state.pathParameters['outfitId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editOutfit,
        name: RouteNames.editOutfit,
        builder: (context, state) =>
            OutfitFormScreen(outfitId: state.pathParameters['outfitId']),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobeSuggestions,
        name: RouteNames.wardrobeSuggestions,
        builder: (context, state) => const OutfitSuggestionsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobePlanner,
        name: RouteNames.wardrobePlanner,
        builder: (context, state) => OutfitPlannerScreen(
          outfitId: state.uri.queryParameters['outfitId'],
          eventId: state.uri.queryParameters['eventId'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobeHistory,
        name: RouteNames.wardrobeHistory,
        builder: (context, state) => const WardrobeHistoryScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.body,
        name: RouteNames.body,
        builder: (context, state) => const BodyCompositionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.wardrobeSettings,
        name: RouteNames.wardrobeSettings,
        builder: (context, state) => const WardrobeSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.connectedApps,
        name: RouteNames.connectedApps,
        builder: (context, state) => const ConnectedAppsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.integrationDiagnostics,
        name: RouteNames.integrationDiagnostics,
        builder: (context, state) => const IntegrationDiagnosticsScreen(),
      ),
      if (kDebugMode && capabilities.debugIntegrationLab)
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: RoutePaths.integrationLab,
          name: RouteNames.integrationLab,
          builder: (context, state) => const IntegrationLabScreen(),
        ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.privacy,
        name: RouteNames.privacy,
        builder: (context, state) => const PrivacyDataCenterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.privacyExport,
        name: RouteNames.privacyExport,
        builder: (context, state) => const PrivacyExportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.privacyDeletion,
        name: RouteNames.privacyDeletion,
        builder: (context, state) => const PrivacyDeletionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.privacyAiDataUse,
        name: RouteNames.privacyAiDataUse,
        builder: (context, state) => const AiDataUseScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.security,
        name: RouteNames.security,
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.syncCenter,
        name: RouteNames.syncCenter,
        builder: (context, state) => const SyncCenterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.conflictCenter,
        name: RouteNames.conflictCenter,
        builder: (context, state) => const ConflictCenterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.deviceSessions,
        name: RouteNames.deviceSessions,
        builder: (context, state) => const DeviceSessionsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.support,
        name: RouteNames.support,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.helpArticle,
        name: RouteNames.helpArticle,
        builder: (context, state) => SupportArticleDetailScreen(
          articleId: state.pathParameters['articleId'] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.helpContact,
        name: RouteNames.helpContact,
        builder: (context, state) => const HelpContactScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.helpReportProblem,
        name: RouteNames.helpReportProblem,
        builder: (context, state) => const ReportProblemScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.helpFeatureRequest,
        name: RouteNames.helpFeatureRequest,
        builder: (context, state) => const FeatureRequestScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.legal,
        name: RouteNames.legal,
        builder: (context, state) => const LegalCenterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.legalDocument,
        name: RouteNames.legalDocument,
        builder: (context, state) {
          final raw = state.pathParameters['documentType'] ?? '';
          final type = TrustDocumentType.values.firstWhere(
            (t) => t.name == raw,
            orElse: () => TrustDocumentType.privacyPolicy,
          );
          return LegalDocumentScreen(type: type);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.about,
        name: RouteNames.about,
        builder: (context, state) => const AboutMemyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.whatsNew,
        name: RouteNames.whatsNew,
        builder: (context, state) => const WhatsNewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.appearance,
        name: RouteNames.appearance,
        builder: (context, state) => const AppearanceAccessibilityScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsRemindersScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.nutritionComingSoon,
        name: RouteNames.nutritionComingSoon,
        builder: (context, state) => const ComingSoonView(
          featureName: 'Nutrition logging',
          explanation:
              'Nutrition logging will be added in a future milestone. '
              'This Quick Add option is intentionally available so no action is a dead end.',
          showBottomNav: true,
          navIndex: 1,
          fallbackPath: RoutePaths.plan,
        ),
      ),
    ],
  );
});
