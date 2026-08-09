import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/body/presentation/body_composition_screen.dart';
import '../../features/calendar/presentation/add_event_placeholder_screen.dart';
import '../../features/calendar/presentation/calendar_placeholder_screen.dart';
import '../../features/coach/presentation/coach_screen.dart';
import '../../features/exercise/presentation/screens/exercise_library_screen.dart';
import '../../features/exercise/presentation/screens/exercise_overview_screen.dart';
import '../../features/exercise/presentation/screens/workout_session_placeholder_screen.dart';
import '../../features/finance/presentation/add_transaction_placeholder_screen.dart';
import '../../features/finance/presentation/finance_placeholder_screen.dart';
import '../../features/goals/presentation/screens/add_goal_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/goals/presentation/screens/goals_list_screen.dart';
import '../../features/habits/presentation/add_habit_placeholder_screen.dart';
import '../../features/habits/presentation/habits_placeholder_screen.dart';
import '../../features/health/presentation/health_placeholder_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/memy_app_shell.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/wardrobe/presentation/wardrobe_placeholder_screen.dart';
import '../../core/widgets/coming_soon_view.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _todayNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final _planNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'plan');
final _coachNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'coach');
final _moreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'more');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.signIn,
    routes: [
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
        builder: (context, state) => const HabitsPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addHabit,
        name: RouteNames.addHabit,
        builder: (context, state) => const AddHabitPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.finance,
        name: RouteNames.finance,
        builder: (context, state) => const FinancePlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addTransaction,
        name: RouteNames.addTransaction,
        builder: (context, state) => const AddTransactionPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.calendar,
        name: RouteNames.calendar,
        builder: (context, state) => const CalendarPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.addEvent,
        name: RouteNames.addEvent,
        builder: (context, state) => const AddEventPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.health,
        name: RouteNames.health,
        builder: (context, state) => const HealthPlaceholderScreen(),
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
        builder: (context, state) => const WardrobePlaceholderScreen(),
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
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
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
