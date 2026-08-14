import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/features/habits/application/controllers/habit_form_controller.dart';
import 'package:memy/features/habits/application/providers/habit_providers.dart';
import 'package:memy/features/habits/data/repositories/local_habit_repository.dart';
import 'package:memy/features/habits/domain/entities/habit_enums.dart';

import '../../../helpers/test_app.dart';

Future<void> _openAddHabit(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav_quick_add')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('quick_add_habit')));
  await tester.pumpAndSettle();
}

Future<String> _createMorningWalkViaForm(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('habit_name_field')),
    'Morning Walk',
  );
  await tester.tap(find.byKey(const Key('habit_category_field')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Fitness').last);
  await tester.pumpAndSettle();

  final context = tester.element(find.byKey(const Key('habit_form_scroll')));
  final container = ProviderScope.containerOf(context);
  final controller = container.read(addHabitFormControllerProvider.notifier);
  controller.setGoalType(HabitGoalType.binary);
  controller.setFrequencyType(HabitFrequencyType.daily);

  final rapid = await Future.wait([
    controller.submitCreate(),
    controller.submitCreate(),
  ]);
  await tester.pumpAndSettle();
  final createdIds = rapid.whereType<String>().toList();
  expect(createdIds, hasLength(1));
  return createdIds.single;
}

void main() {
  testWidgets('Quick Add habit flow: create, today, persist, detail history', (
    tester,
  ) async {
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

    await _openAddHabit(tester);
    expect(find.byKey(const Key('add_habit_screen')), findsOneWidget);

    final habitId = await _createMorningWalkViaForm(tester);

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('habit_form_scroll'))),
    );
    router.go(RoutePaths.habitDetailPath(habitId));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('habit_detail')), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('habit_detail'))),
    );
    final habits = await container.read(habitRepositoryProvider).getHabits();
    expect(habits.where((h) => h.name == 'Morning Walk'), hasLength(1));

    router.go(RoutePaths.habits);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('habit_tile_$habitId')), findsOneWidget);

    router.go(RoutePaths.today);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today_habits_card')), findsOneWidget);
    expect(find.text('Morning Walk'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(Key('today_habit_toggle_$habitId')),
      120,
    );
    await tester.pumpAndSettle();
    final todayToggle = find.byKey(Key('today_habit_toggle_$habitId'));
    expect(todayToggle, findsOneWidget);
    await tester.tap(todayToggle);
    await tester.pumpAndSettle();

    final checkInsAfterComplete = await container
        .read(habitRepositoryProvider)
        .getCheckInsForHabit(habitId);
    expect(checkInsAfterComplete.where((c) => c.isCompleted), hasLength(1));

    router.go(RoutePaths.habitDetailPath(habitId));
    await tester.pumpAndSettle();
    expect(find.textContaining('Current streak · 1'), findsOneWidget);

    final reopened = LocalHabitRepository(
      prefs: prefs,
      clock: container.read(appClockProvider),
    );
    final persisted = await reopened.getHabits();
    expect(persisted.where((h) => h.name == 'Morning Walk'), hasLength(1));
    final checkIns = await reopened.getCheckInsForHabit(habitId);
    expect(checkIns.where((c) => c.isCompleted), hasLength(1));

    expect(find.text('Recent check-ins'), findsOneWidget);
    await tester.tap(find.byKey(const Key('habit_detail_remove_today')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('habit_detail_checkin_toggle')),
          )
          .value,
      isFalse,
    );
    final afterRemove = await container
        .read(habitRepositoryProvider)
        .getCheckInsForHabit(habitId);
    expect(afterRemove.where((c) => c.isCompleted), isEmpty);
  });
}
