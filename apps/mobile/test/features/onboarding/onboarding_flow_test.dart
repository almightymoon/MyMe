import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/config/release_capabilities.dart';
import 'package:memy/core/constants/app_strings.dart';
import 'package:memy/features/auth/application/auth_session_controller.dart';
import 'package:memy/features/auth/data/account_local_store.dart';
import 'package:memy/features/auth/domain/secure_session_store.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';

import '../../helpers/test_app.dart';

List<Override> productionOverrides() => [
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
];

Future<void> tapStep(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('production first launch starts in onboarding, not sign in', (
    tester,
  ) async {
    await pumpMemyApp(tester, overrides: productionOverrides());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding_screen')), findsOneWidget);
    expect(find.text(AppStrings.productTagline), findsOneWidget);
    expect(find.byKey(const Key('continue_to_memy')), findsNothing);
  });

  testWidgets('welcome copy avoids AI positioning', (tester) async {
    await pumpMemyApp(tester, overrides: productionOverrides());
    await tester.pumpAndSettle();

    expect(find.textContaining('AI'), findsNothing);
  });

  testWidgets('completing setup persists preferences and opens Today', (
    tester,
  ) async {
    final prefs = await setupTestPreferences();
    await pumpMemyApp(tester, prefs: prefs, overrides: productionOverrides());
    await tester.pumpAndSettle();

    await tapStep(tester, const Key('onboarding_welcome_next'));
    await tapStep(tester, const Key('onboarding_privacy_next'));

    expect(find.byKey(const Key('onboarding_currency')), findsOneWidget);
    expect(find.byKey(const Key('onboarding_timezone')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('onboarding_display_name')),
      'Moon',
    );
    await tapStep(tester, const Key('profile_avatar_memy_3d_02'));
    await tapStep(tester, const Key('onboarding_preferences_next'));

    await tapStep(tester, const Key('onboarding_calendar_skip'));
    await tapStep(tester, const Key('onboarding_health_skip'));
    await tapStep(tester, const Key('onboarding_finish'));

    expect(find.textContaining('Hi,'), findsOneWidget);
    expect(OnboardingPreferences.isComplete(prefs), isTrue);
    expect(OnboardingPreferences.readDisplayName(prefs), 'Moon');
    expect(OnboardingPreferences.readAvatarId(prefs), 'memy_3d_02');
    expect(OnboardingPreferences.readBaseCurrency(prefs), 'PKR');
    expect(OnboardingPreferences.readLanguage(prefs).code, 'en');
    expect(OnboardingPreferences.readUnits(prefs), MeasurementUnits.metric);
  });

  testWidgets('a completed device skips onboarding on next launch', (
    tester,
  ) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);

    await pumpMemyApp(tester, prefs: prefs, overrides: productionOverrides());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding_screen')), findsNothing);
    expect(find.textContaining('Hi,'), findsOneWidget);
  });

  testWidgets('production redirects away from demo auth routes', (
    tester,
  ) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);

    await pumpMemyApp(tester, prefs: prefs, overrides: productionOverrides());
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    for (final path in [
      RoutePaths.signIn,
      RoutePaths.signUp,
      RoutePaths.forgotPassword,
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(
        router.state.uri.path,
        RoutePaths.today,
        reason: '$path must not be reachable in production',
      );
    }
  });

  testWidgets('incomplete setup redirects app routes back to onboarding', (
    tester,
  ) async {
    await pumpMemyApp(tester, overrides: productionOverrides());
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('onboarding_screen'))),
    );
    router.go(RoutePaths.today);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, RoutePaths.onboarding);
  });

  testWidgets('Settings reset clears completion without deleting data', (
    tester,
  ) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);

    await pumpMemyApp(tester, prefs: prefs, overrides: productionOverrides());
    await tester.pumpAndSettle();

    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.goals);
    await tester.pumpAndSettle();
    const account = AccountLocalStore('11111111-1111-4111-8111-111111111111');
    final goalsKey = account.key(LocalGoalRepository.storageKey);
    final goalsBefore = prefs.getString(goalsKey);
    expect(goalsBefore, isNotNull);

    router.go(RoutePaths.settings);
    await tester.pumpAndSettle();

    final resetRow = find.byKey(const Key('settings_reset_onboarding'));
    await tester.scrollUntilVisible(resetRow, 200);
    await tester.pumpAndSettle();
    await tester.tap(resetRow);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('settings_reset_onboarding_confirm')),
    );
    await tester.pumpAndSettle();

    expect(OnboardingPreferences.isComplete(prefs), isFalse);
    expect(prefs.getString(goalsKey), goalsBefore);
  });
}
