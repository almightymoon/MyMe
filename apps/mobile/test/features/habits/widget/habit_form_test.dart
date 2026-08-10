import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/habits/application/controllers/habit_form_controller.dart';
import 'package:memy/features/habits/application/providers/habit_providers.dart';
import 'package:memy/features/habits/domain/entities/habit_enums.dart';

import '../../../helpers/test_app.dart';

Future<void> _openAddHabit(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav_quick_add')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('quick_add_habit')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('add_habit_screen')), findsOneWidget);
}

Future<void> _fillMorningWalkDailyBinary(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('habit_name_field')),
    'Morning Walk',
  );

  await tester.tap(find.byKey(const Key('habit_category_field')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Fitness').last);
  await tester.pumpAndSettle();

  // Goal type Binary and frequency Daily are defaults.
  final context = tester.element(find.byKey(const Key('habit_form_scroll')));
  final container = ProviderScope.containerOf(context);
  final controller = container.read(addHabitFormControllerProvider.notifier);
  controller.setGoalType(HabitGoalType.binary);
  controller.setFrequencyType(HabitFrequencyType.daily);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('name is required', (tester) async {
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

    await tester.tap(find.byKey(const Key('habit_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Habit name is required'), findsOneWidget);
  });

  testWidgets('successful create navigates to detail', (tester) async {
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
    await _fillMorningWalkDailyBinary(tester);

    await tester.tap(find.byKey(const Key('habit_save_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('habit_detail')), findsOneWidget);
    expect(find.text('Morning Walk'), findsWidgets);
  });

  testWidgets('duplicate save protection creates only one habit', (
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
    await _fillMorningWalkDailyBinary(tester);

    final context = tester.element(find.byKey(const Key('habit_form_scroll')));
    final container = ProviderScope.containerOf(context);
    final controller = container.read(addHabitFormControllerProvider.notifier);

    final first = controller.submitCreate();
    final second = controller.submitCreate();
    final ids = await Future.wait([first, second]);
    final createdIds = ids.whereType<String>().toList();
    expect(createdIds, hasLength(1));

    await tester.pumpAndSettle();
    final habits = await container.read(habitRepositoryProvider).getHabits();
    expect(habits.where((h) => h.name == 'Morning Walk'), hasLength(1));
  });
}
