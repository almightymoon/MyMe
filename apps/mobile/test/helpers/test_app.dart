import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memy/app/app.dart';
import 'package:memy/core/data/fake_repository_config.dart';
import 'package:memy/core/config/environment_config.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/features/finance/data/repositories/local_finance_repository.dart';
import 'package:memy/features/finance/data/seed/finance_seed.dart';
import 'package:memy/features/goals/application/controllers/add_goal_controller.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/habits/application/providers/habit_providers.dart';
import 'package:memy/features/habits/data/repositories/local_habit_repository.dart';
import 'package:memy/features/today/application/providers/weather_providers.dart';
import 'package:memy/features/today/domain/services/device_location_service.dart';
import 'package:memy/features/today/domain/weather_exception.dart';
import 'package:memy/features/auth/application/auth_session_controller.dart';
import 'package:memy/features/auth/domain/secure_session_store.dart';
import 'package:memy/features/wardrobe/application/providers/wardrobe_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestLocationService implements DeviceLocationService {
  @override
  Future<DeviceCoordinates> currentCoordinates() async {
    throw const WeatherException(
      kind: WeatherFailureKind.locationUnavailable,
      message: 'Location is unavailable in tests.',
    );
  }

  @override
  Future<bool> openLocationSettings() async => false;
}

FakeRepositoryConfig createTestFakeConfig({
  Duration delay = Duration.zero,
  bool forceEmpty = false,
  bool forceFailure = false,
}) {
  return FakeRepositoryConfig(
    delay: delay,
    forceEmpty: forceEmpty,
    forceFailure: forceFailure,
  );
}

/// [seedGoals]: when true (default), first launch seeds demo goals.
/// When false, marks storage initialized with an empty goal list.
///
/// [seedFinance]: when true (default), first launch seeds demo finance.
/// When false, marks storage initialized with an empty finance ledger.
///
/// [seedHabits]: when true (default), first launch seeds demo habits.
/// When false, marks storage initialized with an empty habits ledger.
Future<SharedPreferences> setupTestPreferences({
  bool seedGoals = true,
  bool seedFinance = true,
  bool seedHabits = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  if (!seedGoals) {
    await prefs.setBool(LocalGoalRepository.initializedKey, true);
    await prefs.setString(
      LocalGoalRepository.storageKey,
      '{"schemaVersion":1,"goals":[]}',
    );
  }
  if (!seedFinance) {
    await prefs.setBool(LocalFinanceRepository.initializedKey, true);
    final categoriesJson = FinanceSeed.demoCategories()
        .map((c) => c.toJson())
        .toList();
    await prefs.setString(
      LocalFinanceRepository.storageKey,
      jsonEncode({
        'schemaVersion': 1,
        'baseCurrencyCode': 'PKR',
        'categories': categoriesJson,
        'transactions': <Map<String, dynamic>>[],
      }),
    );
  }
  if (!seedHabits) {
    await prefs.setBool(LocalHabitRepository.initializedKey, true);
    await prefs.setString(
      LocalHabitRepository.storageKey,
      '{"schemaVersion":1,"habits":[],"checkIns":[]}',
    );
  }
  return prefs;
}

/// Common overrides for deterministic Habits widget/integration tests.
List<Override> habitTestOverrides({
  required SharedPreferences prefs,
  DateTime? fixedNow,
}) {
  final clock = FixedAppClock(fixedNow ?? DateTime(2026, 8, 9, 12));
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
    habitsDataSourceProvider.overrideWithValue(HabitsDataSource.local),
    appClockProvider.overrideWithValue(clock),
  ];
}

Future<void> pumpMemyApp(
  WidgetTester tester, {
  FakeRepositoryConfig? config,
  List<Override> overrides = const [],
  bool seedGoals = true,
  bool seedFinance = true,
  bool seedHabits = true,
  SharedPreferences? prefs,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  final preferences =
      prefs ??
      await setupTestPreferences(
        seedGoals: seedGoals,
        seedFinance: seedFinance,
        seedHabits: seedHabits,
      );
  final wardrobeRoot = await Directory.systemTemp.createTemp(
    'memy_wardrobe_test',
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        secureSessionStoreProvider.overrideWithValue(
          InMemorySecureSessionStore(),
        ),
        fakeRepositoryConfigProvider.overrideWithValue(
          config ?? createTestFakeConfig(),
        ),
        wardrobeDocumentsDirectoryProvider.overrideWithValue(
          () async => wardrobeRoot,
        ),
        deviceLocationServiceProvider.overrideWithValue(_TestLocationService()),
        ...overrides,
      ],
      child: const MemyApp(),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> signInToToday(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final signIn = find.byKey(const Key('continue_to_memy'));
  await tester.ensureVisible(signIn);
  await tester.pumpAndSettle();
  await tester.tap(signIn);
  await tester.pumpAndSettle();
  expect(find.textContaining('Hi,'), findsOneWidget);
}

/// Sets a valid future deadline on the Add Goal form.
///
/// Uses the controller directly — Material date-picker hit-testing is flaky
/// when the sticky Save bar overlaps the deadline tile in the default test
/// viewport. Validation/save flows still exercise the deadline field.
Future<void> pickRequiredDeadline(WidgetTester tester) async {
  final context = tester.element(find.byKey(const Key('add_goal_form')));
  final container = ProviderScope.containerOf(context);
  container
      .read(addGoalControllerProvider.notifier)
      .setDeadline(DateTime.now().add(const Duration(days: 30)));
  await tester.pumpAndSettle();
}
