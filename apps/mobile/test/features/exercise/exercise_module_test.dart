import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/constants/app_strings.dart';
import 'package:memy/features/exercise/data/exercise_assets.dart';
import 'package:memy/features/exercise/data/exercise_demo_data.dart';
import 'package:memy/features/exercise/domain/entities/exercise_category.dart';
import 'package:memy/features/exercise/domain/entities/exercise_item.dart';
import 'package:memy/features/exercise/presentation/widgets/exercise_artwork.dart';

import '../../helpers/test_app.dart';

void main() {
  test('maps all six categories to distinct assets', () {
    final paths = ExerciseCategory.values.map(ExerciseAssets.pathFor).toSet();
    expect(paths, hasLength(6));
    expect(paths, containsAll(ExerciseAssets.allCategoryImages));

    expect(
      ExerciseAssets.pathFor(ExerciseCategory.strength),
      ExerciseAssets.strengthLungeDumbbells,
    );
    expect(
      ExerciseAssets.pathFor(ExerciseCategory.running),
      ExerciseAssets.runningCardio,
    );
    expect(
      ExerciseAssets.pathFor(ExerciseCategory.yoga),
      ExerciseAssets.yogaWarrior,
    );
    expect(
      ExerciseAssets.pathFor(ExerciseCategory.cycling),
      ExerciseAssets.cyclingCardio,
    );
    expect(
      ExerciseAssets.pathFor(ExerciseCategory.hiit),
      ExerciseAssets.hiitBodyweightSquat,
    );
    expect(
      ExerciseAssets.pathFor(ExerciseCategory.mobility),
      ExerciseAssets.mobilitySideStretch,
    );
  });

  test('semantic labels clarify decorative intent', () {
    for (final category in ExerciseCategory.values) {
      final label = ExerciseAssets.semanticLabelFor(category);
      expect(label.toLowerCase(), contains('decorative'));
      expect(label.toLowerCase(), isNot(contains('medical instruction')));
    }
  });

  test('skips malformed demo data rows', () {
    final parsed = ExerciseDemoData.parseSafely([
      {
        'id': 'ok',
        'name': 'Easy jog',
        'category': 'running',
        'difficulty': 'beginner',
        'equipment': 'Shoes',
        'primaryMuscles': ['Legs'],
        'description': 'Steady pace',
        'safetyNote': 'Warm up first.',
        'durationMinutes': 20,
      },
      {'id': 'bad', 'category': 'not-real'},
      'not-a-map',
    ]);
    expect(parsed, hasLength(1));
    expect(parsed.first, isA<ExerciseItem>());
    expect(parsed.first.name, 'Easy jog');
  });

  testWidgets('Exercise overview renders and Start Workout opens session', (
    tester,
  ) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);

    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.exercise);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byKey(const Key('exercise_overview')), findsOneWidget);
    expect(find.byKey(const Key('workout_summary_card')), findsOneWidget);
    expect(find.byKey(const Key('featured_workout_card')), findsOneWidget);
    expect(find.text(AppStrings.comingSoon), findsNothing);
    expect(find.byKey(const Key('featured_start_workout')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('featured_start_workout')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('featured_start_workout')));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(
      find.byKey(const Key('workout_session_placeholder')),
      findsOneWidget,
    );
    expect(find.textContaining('Placeholder'), findsWidgets);
  });

  testWidgets('category navigation opens filtered library', (tester) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.exerciseLibraryPath('yoga'));
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(find.byKey(const Key('exercise_library_list')), findsOneWidget);
    expect(find.text('Warrior II hold'), findsOneWidget);
  });

  testWidgets('view library button opens full catalog', (tester) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.exerciseLibrary);
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(find.byKey(const Key('exercise_library_list')), findsOneWidget);
    expect(find.text('Goblet squat'), findsOneWidget);
  });

  testWidgets('start workout route is reachable and labeled', (tester) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.workoutSession);
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(
      find.byKey(const Key('workout_session_placeholder')),
      findsOneWidget,
    );
    expect(find.text('Workout session'), findsOneWidget);
    expect(find.byKey(const Key('end_workout_placeholder')), findsOneWidget);
  });

  testWidgets('missing-image fallback is available for artwork', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 150,
            child: ExerciseArtwork(
              key: Key('test_artwork'),
              category: ExerciseCategory.strength,
              assetPathOverride: 'assets/images/exercise/missing.webp',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('exercise_art_fallback_strength')),
      findsOneWidget,
    );
  });

  testWidgets('empty category shows empty state', (tester) async {
    await pumpMemyApp(tester, seedGoals: false);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go('${RoutePaths.exerciseLibrary}?category=unknown');
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(find.byKey(const Key('exercise_library_empty')), findsOneWidget);
  });
}
