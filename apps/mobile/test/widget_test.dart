import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/core/constants/app_strings.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('starts at demo sign-in screen', (tester) async {
    await pumpMemyApp(tester);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.welcomeHeading), findsOneWidget);
    expect(find.text(AppStrings.demoMode), findsOneWidget);
    expect(find.text(AppStrings.continueToMemy), findsOneWidget);
  });

  testWidgets('Continue to MeMy navigates to Today', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    expect(find.text('Good day, Emma'), findsOneWidget);
    expect(find.text(AppStrings.dayAtAGlance), findsOneWidget);
  });

  testWidgets('primary navigation items work', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_plan')));
    await tester.pumpAndSettle();
    expect(find.text('Weekly planning summary'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_coach')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.liveAiNotConnected), findsWidgets);

    await tester.tap(find.byKey(const Key('nav_more')));
    await tester.pumpAndSettle();
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Exercise'), findsOneWidget);
    expect(find.byKey(const Key('more_profile')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_today')));
    await tester.pumpAndSettle();
    expect(find.text('Good day, Emma'), findsOneWidget);
  });

  testWidgets('Quick Add opens sheet and Add Goal routes to /goals/new', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.quickAdd), findsWidgets);
    expect(find.byKey(const Key('quick_add_goal')), findsOneWidget);

    await tester.tap(find.byKey(const Key('quick_add_goal')));
    await tester.pumpAndSettle();

    expect(find.text('Add Goal'), findsOneWidget);
    expect(find.text(AppStrings.comingSoon), findsOneWidget);

    final context = tester.element(find.text('Add Goal').first);
    expect(GoRouter.of(context).state.uri.path, '/goals/new');
  });

  testWidgets('More → Exercise routes to /exercise', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('more_exercise')));
    await tester.pumpAndSettle();

    expect(find.text('Exercise'), findsWidgets);
    final context = tester.element(find.text('Exercise').first);
    expect(GoRouter.of(context).state.uri.path, '/exercise');
  });

  testWidgets('main navigation destinations do not throw', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    for (final key in [
      const Key('nav_today'),
      const Key('nav_plan'),
      const Key('nav_coach'),
      const Key('nav_more'),
    ]) {
      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
