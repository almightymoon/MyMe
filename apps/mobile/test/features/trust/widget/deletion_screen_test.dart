import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/app/theme/app_theme.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/core/widgets/memy_primary_button.dart';
import 'package:memy/features/finance/data/repositories/fake_finance_repository.dart';
import 'package:memy/features/goals/data/repositories/fake_goal_repository.dart';
import 'package:memy/features/goals/domain/entities/goal.dart';
import 'package:memy/features/goals/domain/entities/goal_enums.dart';
import 'package:memy/features/habits/data/repositories/fake_habit_repository.dart';
import 'package:memy/features/health/data/gateways/fake_platform_health_gateway.dart';
import 'package:memy/features/health/data/repositories/fake_health_repository.dart';
import 'package:memy/features/health/domain/entities/health_connection_config.dart';
import 'package:memy/features/trust/application/providers/trust_providers.dart';
import 'package:memy/features/trust/data/repositories/memy_local_data_deletion_coordinator.dart';
import 'package:memy/features/trust/domain/services/local_data_deletion_coordinator.dart';
import 'package:memy/features/trust/presentation/privacy/deletion_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('typed confirmation gates global wipe button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final goals = FakeGoalRepository(
      initial: [
        Goal(
          id: 'g1',
          name: 'Run',
          category: GoalCategory.health,
          priority: GoalPriority.high,
          status: GoalStatus.active,
          deadline: DateTime(2027),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          progressPercent: 0,
        ),
      ],
    );
    final finance = FakeFinanceRepository();
    final habits = FakeHabitRepository();
    final health = FakeHealthRepository(
      gateway: FakePlatformHealthGateway(),
      initialConnection: const HealthConnectionConfig(),
    );

    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localDataDeletionCoordinatorProvider.overrideWithValue(
            MemyLocalDataDeletionCoordinator(
              goalRepository: goals,
              financeRepository: finance,
              habitRepository: habits,
              healthRepository: health,
              prefs: prefs,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const PrivacyDeletionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final globalScope = find.byKey(const Key('delete_scope_allLocalMeMyData'));
    await tester.ensureVisible(globalScope);
    await tester.tap(globalScope);
    await tester.pumpAndSettle();

    expect(find.textContaining('Will remain'), findsOneWidget);
    expect(find.textContaining('HealthKit'), findsWidgets);

    MemyPrimaryButton button() =>
        tester.widget<MemyPrimaryButton>(find.byKey(const Key('delete_run')));

    expect(button().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('delete_confirmation_phrase')),
      'wrong',
    );
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('delete_confirmation_phrase')),
      '  ${LocalDataDeletionCoordinator.globalConfirmationPhrase}  ',
    );
    await tester.pump();
    expect(button().onPressed, isNotNull);

    final run = find.byKey(const Key('delete_run'));
    await tester.ensureVisible(run);
    await tester.tap(run);
    await tester.pumpAndSettle();

    expect(find.textContaining('Completed'), findsWidgets);
    expect(await goals.getGoals(), isEmpty);

    goals.dispose();
    finance.dispose();
    habits.dispose();
    health.dispose();
  });
}
