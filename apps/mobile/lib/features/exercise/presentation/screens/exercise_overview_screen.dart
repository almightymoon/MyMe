import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/release_capabilities.dart';
import '../../../../core/widgets/memy_chrome.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../shell/presentation/memy_bottom_navigation.dart';
import '../../../shell/presentation/memy_drawer.dart';
import '../../../shell/presentation/quick_add_sheet.dart';
import '../../data/exercise_demo_data.dart';
import '../../domain/entities/exercise_category.dart';
import '../widgets/exercise_category_card.dart';
import '../widgets/featured_workout_card.dart';
import '../widgets/workout_summary_card.dart';

class ExerciseOverviewScreen extends ConsumerWidget {
  const ExerciseOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(releaseCapabilitiesProvider);
    final featured = ExerciseDemoData.featuredWorkout;
    final bottomPad = MemyBottomNavigation.contentBottomInset(context);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      extendBody: true,
      endDrawer: const MemyDrawer(activeShellIndex: 1),
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('exercise_overview'),
          padding: EdgeInsets.only(bottom: 8 + bottomPad),
          children: [
            MemyPageHeader(
              title: 'Exercise',
              subtitle:
                  'Move with clarity — art is decorative, not form coaching',
              leading: IconButton(
                key: const Key('exercise_back'),
                tooltip: 'Back',
                onPressed: () => memyBack(context, fallback: RoutePaths.more),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              trailing: const MemyHeaderActions(
                showAvatar: false,
                menuKey: Key('exercise_open_drawer'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (capabilities.exerciseSessions) ...[
                    WorkoutSummaryCard(summary: ExerciseDemoData.weeklySummary),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  FeaturedWorkoutCard(
                    workout: featured,
                    onStart: capabilities.exerciseSessions
                        ? () => context.push(RoutePaths.workoutSession)
                        : null,
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
                  if (capabilities.exerciseSessions) ...[
                    const SectionHeader(title: 'Recent activity'),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sample activity for internal previews only.',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.faintText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...ExerciseDemoData.recentActivity.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Semantics(
                          label:
                              '${item.title}, ${item.completedLabel}, ${item.durationMinutes} minutes',
                          child: ListTile(
                            key: Key('recent_${item.id}'),
                            enabled: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.controlRadius,
                              side: BorderSide(color: AppColors.line),
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
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    MemyPrimaryButton(
                      key: const Key('start_workout_button'),
                      label: 'Start workout',
                      onPressed: () => context.push(RoutePaths.workoutSession),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ] else ...[
                    Text(
                      'Browse the library for movement ideas. Live workout '
                      'tracking is not included in this release.',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  OutlinedButton(
                    key: const Key('view_exercise_library_button'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.minTouch),
                      foregroundColor: AppColors.primaryText,
                      side: BorderSide(color: AppColors.line),
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
      bottomNavigationBar: MemyBottomNavigation(
        currentIndex: 3,
        onDestinationSelected: (index) => memyGoShellTab(context, index),
        onQuickAddPressed: () => showQuickAddSheet(context),
      ),
    );
  }
}
