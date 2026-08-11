import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/config/release_capabilities.dart';
import 'package:memy/features/auth/application/auth_session_controller.dart';
import 'package:memy/features/auth/domain/secure_session_store.dart';
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
      authSessionProvider.overrideWith(
        (ref) => AuthSessionController(
          InMemorySecureSessionStore(),
          initial: StoredAuthSession(
            userId: '11111111-1111-4111-8111-111111111111',
            deviceId: '22222222-2222-4222-8222-222222222222',
            clientGeneratedDeviceId: 'test-device-aaaaaaaa',
            provider: 'google',
            refreshToken: 'test-refresh',
            authenticatedAt: DateTime.utc(2026, 8, 11),
          ),
        ),
      ),
    ],
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return prefs;
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('home_open_drawer')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_more'))),
    );
    expect(router.state.uri.path, RoutePaths.more);
    expect(find.byKey(const Key('insights_life_trend')), findsOneWidget);
    expect(find.byKey(const Key('more_body')), findsNothing);
    expect(find.byKey(const Key('more_wardrobe')), findsOneWidget);
    expect(find.byKey(const Key('more_coach_preview')), findsNothing);
  });

  testWidgets('Quick Add drops Log Meal but keeps working actions', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('quick_add_task')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_goal')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_transaction')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_event')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_habit')), findsOneWidget);
    expect(find.byKey(const Key('quick_add_meal')), findsNothing);
  });

  testWidgets('sidebar hides Coach, Body, Notifications and keeps Sign Out', (
    tester,
  ) async {
    await pumpProductionApp(tester);
    await openDrawer(tester);

    expect(find.byKey(const Key('memy_drawer')), findsOneWidget);
    expect(find.byKey(const Key('drawer_goals')), findsOneWidget);
    expect(find.byKey(const Key('drawer_exercise')), findsOneWidget);
    expect(find.byKey(const Key('drawer_privacy')), findsOneWidget);

    expect(find.byKey(const Key('drawer_coach')), findsNothing);
    expect(find.byKey(const Key('drawer_wardrobe')), findsOneWidget);
    expect(find.byKey(const Key('drawer_body')), findsNothing);
    expect(find.byKey(const Key('drawer_notifications')), findsNothing);
    expect(find.byKey(const Key('drawer_logout')), findsOneWidget);
  });

  testWidgets('frozen routes redirect to Today instead of dead-ending', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );
    for (final path in [
      RoutePaths.coach,
      RoutePaths.body,
      RoutePaths.nutritionComingSoon,
      RoutePaths.workoutSession,
    ]) {
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        router.state.uri.path,
        path == RoutePaths.workoutSession
            ? RoutePaths.exercise
            : RoutePaths.today,
        reason: '$path must be frozen out of production',
      );
    }

    router.go(RoutePaths.notifications);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(router.state.uri.path, RoutePaths.settings);
  });

  testWidgets('Settings hides planned rows and shows account Log Out', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );
    router.go(RoutePaths.settings);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('settings_scroll')), findsOneWidget);
    expect(find.byKey(const Key('settings_currency')), findsOneWidget);
    expect(find.byKey(const Key('settings_units')), findsOneWidget);
    expect(find.byKey(const Key('settings_language')), findsOneWidget);
    expect(find.text('Change Password'), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_logout')),
      300,
      scrollable: find.descendant(
        of: find.byKey(const Key('settings_scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.byKey(const Key('settings_logout')), findsOneWidget);
    expect(find.byKey(const Key('settings_reset_onboarding')), findsOneWidget);
  });

  testWidgets('development defaults keep Coach and demo sign in', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    expect(find.byKey(const Key('nav_coach')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('quick_add_meal')), findsOneWidget);
  });
}
