import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/config/release_capabilities.dart';
import 'package:memy/core/constants/app_strings.dart';
import 'package:memy/features/auth/application/auth_session_controller.dart';
import 'package:memy/features/auth/domain/secure_session_store.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';

import '../../helpers/test_app.dart';
import 'production_navigation_test.dart';

void main() {
  testWidgets('production Today greets from onboarding display name', (
    tester,
  ) async {
    final prefs = await setupTestPreferences(
      seedGoals: false,
      seedFinance: false,
    );
    await OnboardingPreferences.markComplete(prefs);
    await OnboardingPreferences.writeDisplayName(prefs, 'Alex');

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
    await tester.pumpAndSettle();

    expect(find.text('Hi, Alex!'), findsOneWidget);
    expect(find.text('Hi, Emma!'), findsNothing);
    expect(find.byKey(const Key('today_life_score')), findsOneWidget);
    expect(find.text('84%'), findsNothing);
    expect(find.text(AppStrings.samplePreviewCaption), findsNothing);
    expect(find.text('Finish AI Research Paper'), findsNothing);
  });

  testWidgets('production Plan hides fake modules and coach strip', (
    tester,
  ) async {
    await pumpProductionApp(tester);

    await tester.tap(find.byKey(const Key('nav_plan')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard_module_goals')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_health')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_calendar')), findsOneWidget);
    expect(find.text('95 bpm'), findsNothing);
    expect(find.byKey(const Key('dashboard_module_wardrobe')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_nutrition')), findsNothing);
    expect(find.byKey(const Key('dashboard_module_body')), findsNothing);
    expect(find.byKey(const Key('dashboard_coach_strip')), findsNothing);
  });

  testWidgets('production Exercise hides Start Workout and fake activity', (
    tester,
  ) async {
    await pumpProductionApp(tester);
    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );
    router.go(RoutePaths.exercise);
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byKey(const Key('exercise_overview')), findsOneWidget);
    expect(find.byKey(const Key('start_workout_button')), findsNothing);
    expect(find.byKey(const Key('featured_start_workout')), findsNothing);
    expect(find.byKey(const Key('workout_summary_card')), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const Key('view_exercise_library_button')),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('exercise_overview')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(
      find.byKey(const Key('view_exercise_library_button')),
      findsOneWidget,
    );

    router.go(RoutePaths.workoutSession);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, RoutePaths.exercise);
  });
}
