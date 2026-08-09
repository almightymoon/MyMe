import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/quick_add_destinations.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/constants/app_strings.dart';

import '../../helpers/test_app.dart';

void main() {
  test('Quick Add destination mapping is complete', () {
    expect(
      QuickAddDestinations.byActionKey.keys,
      containsAll([
        'quick_add_goal',
        'quick_add_transaction',
        'quick_add_event',
        'quick_add_habit',
        'quick_add_meal',
      ]),
    );
    expect(QuickAddDestinations.pathFor('quick_add_goal'), RoutePaths.addGoal);
    expect(
      QuickAddDestinations.pathFor('quick_add_meal'),
      RoutePaths.nutritionComingSoon,
    );
  });

  testWidgets('placeholder feature routes are available', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    final comingSoonRoutes = <String, Finder>{
      RoutePaths.habits: find.text('Habits'),
      RoutePaths.nutritionComingSoon: find.text('Nutrition logging'),
    };
    final liveModuleRoutes = <String, Finder>{
      RoutePaths.finance: find.byKey(const Key('finance_overview')),
      RoutePaths.calendar: find.byKey(const Key('calendar_overview')),
      RoutePaths.health: find.byKey(const Key('health_overview')),
      RoutePaths.body: find.byKey(const Key('body_composition')),
      RoutePaths.wardrobe: find.byKey(const Key('wardrobe_overview')),
      RoutePaths.settings: find.byKey(const Key('settings_scroll')),
      RoutePaths.profile: find.byKey(const Key('profile_scroll')),
    };

    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    for (final entry in comingSoonRoutes.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(entry.value, findsWidgets, reason: 'Missing UI for ${entry.key}');
      expect(find.text(AppStrings.comingSoon), findsOneWidget);
      expect(find.byKey(const Key('coming_soon_back')), findsOneWidget);
      expect(find.byKey(const Key('nav_today')), findsOneWidget);
    }
    for (final entry in liveModuleRoutes.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(
        entry.value,
        findsOneWidget,
        reason: 'Missing UI for ${entry.key}',
      );
      if (entry.key == RoutePaths.settings || entry.key == RoutePaths.profile) {
        expect(
          find.byKey(
            Key(
              entry.key == RoutePaths.settings
                  ? 'settings_back'
                  : 'profile_back',
            ),
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('nav_today')), findsNothing);
      } else {
        expect(find.byKey(const Key('module_back')), findsOneWidget);
        expect(find.byKey(const Key('nav_today')), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Exercise route is live (not a placeholder)', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.exercise);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('exercise_overview')), findsOneWidget);
    expect(find.text(AppStrings.comingSoon), findsNothing);
  });

  testWidgets('Goals routes are live (not placeholders)', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));

    router.go(RoutePaths.goals);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goals_list')), findsOneWidget);
    expect(find.text(AppStrings.comingSoon), findsNothing);

    router.go(RoutePaths.addGoal);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('add_goal_form')), findsOneWidget);
  });

  testWidgets('Quick Add Add Goal maps to /goals/new', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick_add_goal')));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Add Goal').first);
    expect(GoRouter.of(context).state.uri.path, RoutePaths.addGoal);
  });
}
