import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/config/release_capabilities.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app.dart';

/// Boots the app straight into Today with the production capability set.
Future<SharedPreferences> pumpProductionApp(WidgetTester tester) async {
  final prefs = await setupTestPreferences();
  await OnboardingPreferences.markComplete(prefs);
  await pumpMemyApp(
    tester,
    prefs: prefs,
    overrides: [
      releaseCapabilitiesProvider.overrideWithValue(
        ReleaseCapabilities.production(),
      ),
    ],
  );
  await tester.pumpAndSettle();
  return prefs;
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('home_open_drawer')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bottom nav shows Today, Plan, Quick Add and More only', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    expect(find.byKey(const Key('nav_today')), findsOneWidget);
    expect(find.byKey(const Key('nav_plan')), findsOneWidget);
    expect(find.byKey(const Key('nav_quick_add')), findsOneWidget);
    expect(find.byKey(const Key('nav_more')), findsOneWidget);
    expect(find.byKey(const Key('nav_coach')), findsNothing);
  });

  testWidgets('More still targets its own shell branch without Coach', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    await tester.tap(find.byKey(const Key('nav_more')));
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_more'))),
    );
    expect(router.state.uri.path, RoutePaths.more);
    expect(find.byKey(const Key('insights_life_trend')), findsOneWidget);
    expect(find.byKey(const Key('more_body')), findsNothing);
    expect(find.byKey(const Key('more_wardrobe')), findsNothing);
    expect(find.byKey(const Key('more_coach_preview')), findsNothing);
  });

  testWidgets('Quick Add drops Log Meal but keeps working actions', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quick_add_task')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_goal')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_transaction')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_event')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_habit')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_meal')), findsNothing);
  });

  testWidgets(
    'sidebar hides Coach, Wardrobe, Body, Notifications and Sign Out',
    (tester) async {
      await pumpProductionApp(tester);
      await openDrawer(tester);

      expect(find.byKey(const Key('memy_drawer')), findsOneWidget);
      expect(find.byKey(const Key('drawer_goals')), findsOneWidget);
      expect(find.byKey(const Key('drawer_exercise')), findsOneWidget);
      expect(find.byKey(const Key('drawer_privacy')), findsOneWidget);

      expect(find.byKey(const Key('drawer_coach')), findsNothing);
      expect(find.byKey(const Key('drawer_wardrobe')), findsNothing);
      expect(find.byKey(const Key('drawer_body')), findsNothing);
      expect(find.byKey(const Key('drawer_notifications')), findsNothing);
      expect(find.byKey(const Key('drawer_logout')), findsNothing);
    },
  );

  testWidgets('frozen routes redirect to Today instead of dead-ending', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );
    for (final path in [
      RoutePaths.coach,
      RoutePaths.wardrobe,
      RoutePaths.body,
      RoutePaths.nutritionComingSoon,
      RoutePaths.workoutSession,
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(
        router.state.uri.path,
        path == RoutePaths.workoutSession
            ? RoutePaths.exercise
            : RoutePaths.today,
        reason: '$path must be frozen out of production',
      );
    }

    router.go(RoutePaths.notifications);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, RoutePaths.settings);
  });

  testWidgets('Settings hides planned rows and Log Out', (tester) async {
    await pumpProductionApp(tester);

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );
    router.go(RoutePaths.settings);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings_scroll')), findsOneWidget);
    expect(find.text('Units'), findsNothing);
    expect(find.text('Language'), findsNothing);
    expect(find.text('Change Password'), findsNothing);
    expect(find.byKey(const Key('settings_logout')), findsNothing);
    expect(find.byKey(const Key('settings_reset_onboarding')), findsOneWidget);
  });

  testWidgets('development defaults keep Coach and demo sign in', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    expect(find.byKey(const Key('nav_coach')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick_add_meal')), findsOneWidget);
  });
}
