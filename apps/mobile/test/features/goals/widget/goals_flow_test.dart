import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/features/goals/application/providers/goal_providers.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('add-goal validation requires name and deadline', (tester) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick_add_goal')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add_goal_form')), findsOneWidget);
    await tester.tap(find.byKey(const Key('goal_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Goal name is required'), findsOneWidget);
    expect(find.text('Deadline is required'), findsWidgets);
  });

  testWidgets('Quick Add → Add Goal → Save → Goals list', (tester) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick_add_goal')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('goal_name_field')),
      'Run marathon',
    );
    await tester.tap(find.byKey(const Key('goal_deadline_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goal_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Run marathon'), findsWidgets);
    expect(find.byKey(const Key('goal_detail_scroll')), findsOneWidget);

    await tester.tap(find.byKey(const Key('goal_detail_back')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('goals_list')), findsOneWidget);
    expect(find.text('Run marathon'), findsWidgets);
  });

  testWidgets('goal appears in list and detail; milestone can be completed', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_plan')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_goals_populated')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('goals_list')), findsOneWidget);
    expect(find.text('Build Emergency Fund'), findsWidgets);

    await tester.tap(find.byKey(const Key('goal_tile_emergency')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goal_detail_scroll')), findsOneWidget);
    expect(find.byKey(const Key('goal_forecast_card')), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('goal_detail_scroll'))),
    );
    await container
        .read(goalRepositoryProvider)
        .setMilestoneCompletion(
          goalId: 'emergency',
          milestoneId: 'e2',
          isCompleted: true,
        );
    await tester.pumpAndSettle();

    final checkbox = tester.widget<CheckboxListTile>(
      find.byKey(const Key('milestone_e2')),
    );
    expect(checkbox.value, isTrue);
  });

  testWidgets('Today updates after goal creation', (tester) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);

    expect(find.text('Run a 5K'), findsNothing);

    await tester.tap(find.byKey(const Key('nav_quick_add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick_add_goal')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('goal_name_field')),
      'Run a 5K',
    );
    await tester.tap(find.byKey(const Key('goal_deadline_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('goal_save_button')));
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('goal_detail_scroll'))),
    );
    router.go(RoutePaths.today);
    await tester.pumpAndSettle();
    expect(find.text('Run a 5K'), findsWidgets);
  });

  testWidgets('delete confirmation removes goal', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);
    await tester.tap(find.byKey(const Key('nav_plan')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('plan_goals_populated')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('goal_menu_emergency')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete goal?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm_delete_goal')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('goal_tile_emergency')), findsNothing);
  });
}
