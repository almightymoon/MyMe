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

  testWidgets('primary feature routes are available', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    final routes = <String, Finder>{
      RoutePaths.goals: find.text('Goals'),
      RoutePaths.habits: find.text('Habits'),
      RoutePaths.finance: find.text('Finance'),
      RoutePaths.calendar: find.text('Calendar'),
      RoutePaths.health: find.text('Health'),
      RoutePaths.exercise: find.text('Exercise'),
      RoutePaths.wardrobe: find.text('Wardrobe'),
      RoutePaths.settings: find.text('Settings'),
      RoutePaths.addGoal: find.text('Add Goal'),
      RoutePaths.nutritionComingSoon: find.text('Nutrition logging'),
    };

    final router = GoRouter.of(
      tester.element(find.textContaining('Good day,')),
    );
    for (final entry in routes.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(entry.value, findsWidgets, reason: 'Missing UI for ${entry.key}');
      expect(tester.takeException(), isNull);
      expect(find.text(AppStrings.comingSoon), findsOneWidget);
    }
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
