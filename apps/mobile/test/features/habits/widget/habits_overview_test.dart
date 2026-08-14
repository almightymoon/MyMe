import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/features/habits/application/providers/habit_providers.dart';
import 'package:memy/features/habits/data/repositories/fake_habit_repository.dart';
import 'package:memy/features/habits/presentation/screens/habits_overview_screen.dart';

import '../../../helpers/test_app.dart';

Future<void> _openHabitsOverview(WidgetTester tester) async {
  final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
  router.go(RoutePaths.habits);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('habits overview shows populated list with seed data', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);
    await _openHabitsOverview(tester);

    expect(find.byKey(const Key('habits_overview')), findsOneWidget);
    expect(find.byKey(const Key('habits_empty')), findsNothing);
    expect(
      find.byKey(const Key('habit_tile_habit_morning_walk')),
      findsOneWidget,
    );
    expect(find.text('Morning Walk'), findsWidgets);
  });

  testWidgets('habits overview shows empty state when cleared', (tester) async {
    final prefs = await setupTestPreferences(
      seedGoals: false,
      seedFinance: false,
      seedHabits: false,
    );
    await pumpMemyApp(
      tester,
      prefs: prefs,
      seedGoals: false,
      seedFinance: false,
      seedHabits: false,
      overrides: habitTestOverrides(prefs: prefs),
    );
    await signInToToday(tester);
    await _openHabitsOverview(tester);

    expect(find.byKey(const Key('habits_empty')), findsOneWidget);
  });

  testWidgets('habits overview shows loading skeleton while list loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredHabitsProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
          habitsOverviewProvider.overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
        ],
        child: const MaterialApp(home: HabitsOverviewScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('habits_overview')), findsOneWidget);
    expect(find.byKey(const Key('habits_loading')), findsOneWidget);
  });

  testWidgets('habits overview shows error and retry recovers', (tester) async {
    final fakeRepo = FakeHabitRepository(forceFailure: true);
    addTearDown(fakeRepo.dispose);

    await pumpMemyApp(
      tester,
      overrides: [habitRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    await signInToToday(tester);
    await _openHabitsOverview(tester);

    expect(find.byKey(const Key('habits_error')), findsWidgets);
    expect(find.byKey(const Key('habits_retry')), findsWidgets);

    fakeRepo.forceFailure = false;
    await tester.tap(find.byKey(const Key('habits_retry')).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('habits_error')), findsNothing);
    expect(
      find.byKey(const Key('habit_tile_habit_morning_walk')),
      findsOneWidget,
    );
  });

  testWidgets('binary check-in toggles from overview list', (tester) async {
    final prefs = await setupTestPreferences(
      seedGoals: false,
      seedFinance: false,
    );
    await pumpMemyApp(
      tester,
      prefs: prefs,
      seedGoals: false,
      seedFinance: false,
      overrides: habitTestOverrides(prefs: prefs),
    );
    await signInToToday(tester);
    await _openHabitsOverview(tester);

    final toggle = find.byKey(const Key('habit_toggle_habit_morning_walk'));
    expect(toggle, findsOneWidget);

    final switchWidget = tester.widget<Switch>(toggle);
    expect(switchWidget.value, isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(toggle).value, isTrue);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(toggle).value, isFalse);
  });
}
