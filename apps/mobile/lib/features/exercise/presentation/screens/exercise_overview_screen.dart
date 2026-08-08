import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/exercise_demo_data.dart';
import '../../domain/entities/exercise_category.dart';
import '../widgets/exercise_category_card.dart';
import '../widgets/featured_workout_card.dart';
import '../widgets/workout_summary_card.dart';

class ExerciseOverviewScreen extends StatelessWidget {
  const ExerciseOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = ExerciseDemoData.weeklySummary;
    final featured = ExerciseDemoData.featuredWorkout;
    final recent = ExerciseDemoData.recentActivity;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const Key('exercise_overview'),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            MemyPageHeader(
              title: 'Exercise',
              subtitle:
                  'Move with clarity — art is decorative, not form coaching',
              leading: IconButton(
                key: const Key('exercise_back'),
                tooltip: 'Back',
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.more);
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WorkoutSummaryCard(summary: summary),
                  const SizedBox(height: AppSpacing.lg),
                  FeaturedWorkoutCard(
                    workout: featured,
                    onStart: () => context.push(RoutePaths.workoutSession),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Categories'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Illustrations set the mood for each category. They are not '
                    'medical instructions or exact form demos.',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 260,
              child: ListView.separated(
                key: const Key('exercise_category_carousel'),
                primary: false,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                itemCount: ExerciseCategory.values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final category = ExerciseCategory.values[index];
                  final count = ExerciseDemoData.byCategory(category).length;
                  return SizedBox(
                    width: 168,
                    child: ExerciseCategoryCard(
                      category: category,
                      exerciseCount: count,
                      onTap: () => context.push(
                        RoutePaths.exerciseLibraryPath(category.id),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xl,
                AppSpacing.page,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'Recent activity'),
                  const SizedBox(height: AppSpacing.md),
                  ...recent.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        key: Key('recent_${item.id}'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.line),
                        ),
                        tileColor: AppColors.surface,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.canvasDeep,
                          child: Text(
                            item.category.label.characters.first,
                            style: AppTextStyles.titleSmall(),
                          ),
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.completedLabel} · ${item.durationMinutes} min',
                        ),
                        minVerticalPadding: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  MemyPrimaryButton(
                    key: const Key('start_workout_button'),
                    label: 'Start workout',
                    onPressed: () => context.push(RoutePaths.workoutSession),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    key: const Key('view_exercise_library_button'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.minTouch),
                      foregroundColor: AppColors.primaryText,
                      side: const BorderSide(color: AppColors.line),
                    ),
                    onPressed: () => context.push(RoutePaths.exerciseLibrary),
                    child: Text(
                      'View exercise library',
                      style: AppTextStyles.labelLarge(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
