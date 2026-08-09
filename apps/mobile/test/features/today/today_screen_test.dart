import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memy/core/constants/app_strings.dart';
import 'package:memy/features/goals/application/providers/goal_providers.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/today/application/providers/today_providers.dart';
import 'package:memy/features/today/application/providers/today_tasks_provider.dart';
import 'package:memy/features/today/data/seed/today_seed.dart';
import 'package:memy/features/today/domain/entities/today_summary.dart';
import 'package:memy/features/today/presentation/today_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Today shows loading skeletons while fetching', (tester) async {
    final prefs = await setupTestPreferences(seedGoals: false);
    final completer = Completer<TodaySummary>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          todayBaseProvider.overrideWith((ref) => completer.future),
          goalsProvider.overrideWith(
            (ref) => Stream<List<Goal>>.value(const []),
          ),
        ],
        child: const MaterialApp(home: TodayScreen()),
      ),
    );

    await tester.pump();
    expect(find.byKey(const Key('today_loading')), findsOneWidget);

    completer.complete(TodaySeed.populated());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today_populated')), findsOneWidget);
  });

  testWidgets('Today shows populated demo content', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    expect(find.byKey(const Key('today_populated')), findsOneWidget);
    expect(find.text(TodaySeed.demoFocus.title), findsOneWidget);
    expect(find.textContaining('Team Meeting'), findsOneWidget);
    expect(find.textContaining('Gym Workout'), findsOneWidget);
    expect(find.text('84%'), findsOneWidget);
    expect(find.text("You're doing great!"), findsOneWidget);
    expect(find.byKey(const Key('today_tasks')), findsOneWidget);
    expect(find.text("Today's Tasks"), findsOneWidget);
    expect(find.text('2 of 5'), findsOneWidget);
    expect(find.text('Morning stretch routine'), findsOneWidget);
    // Active goals and live Finance glance appear when data exists.
    expect(find.byKey(const Key('today_goals_card')), findsOneWidget);
    expect(find.byKey(const Key('today_finance_card')), findsOneWidget);
    expect(find.textContaining('Spent today'), findsOneWidget);
    expect(find.text(AppStrings.habitPreview), findsNothing);
  });

  testWidgets('Today tasks checklist toggles and updates count', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    expect(find.byKey(const Key('today_tasks')), findsOneWidget);
    expect(find.text('2 of 5'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('today_tasks'))),
    );
    container.read(todayTasksProvider.notifier).toggle('task-literature');
    await tester.pumpAndSettle();
    expect(find.text('3 of 5'), findsOneWidget);

    container.read(todayTasksProvider.notifier).toggle('task-stretch');
    await tester.pumpAndSettle();
    expect(find.text('2 of 5'), findsOneWidget);
  });

  testWidgets('Today shows error and Retry recovers', (tester) async {
    final config = createTestFakeConfig(forceFailure: true);
    await pumpMemyApp(tester, config: config);
    await signInToToday(tester);

    expect(find.byKey(const Key('today_error')), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);

    config.forceFailure = false;
    await tester.tap(find.byKey(const Key('retry_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_populated')), findsOneWidget);
    expect(find.text(TodaySeed.demoFocus.title), findsOneWidget);
  });

  testWidgets('Today shows empty state when base and goals are empty', (
    tester,
  ) async {
    await pumpMemyApp(
      tester,
      config: createTestFakeConfig(forceEmpty: true),
      seedGoals: false,
      seedFinance: false,
    );
    await signInToToday(tester);

    expect(find.byKey(const Key('today_empty')), findsOneWidget);
    expect(find.text(AppStrings.todayEmptyMessage), findsOneWidget);
  });
}
