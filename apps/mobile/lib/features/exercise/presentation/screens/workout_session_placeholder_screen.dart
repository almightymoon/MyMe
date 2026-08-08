import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../data/exercise_demo_data.dart';
import '../widgets/exercise_artwork.dart';

/// Clearly labeled workout-session placeholder — Start Workout is never a dead end.
class WorkoutSessionPlaceholderScreen extends StatelessWidget {
  const WorkoutSessionPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = ExerciseDemoData.featuredWorkout;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const Key('workout_session_placeholder'),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            MemyPageHeader(
              title: 'Workout session',
              subtitle: 'Placeholder — live coaching arrives later',
              leading: IconButton(
                key: const Key('workout_session_back'),
                tooltip: 'Back',
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.exercise);
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
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: ExerciseArtwork(
                      category: featured.category,
                      cacheWidth: 800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(featured.title, style: AppTextStyles.displayMedium()),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This screen confirms Start Workout opened successfully. '
                    'Timers, sets, and form coaching are not live yet.',
                    style: AppTextStyles.bodyLarge(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'The illustration above is decorative category art — not a '
                    'substitute for exercise-form instruction.',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  MemyPrimaryButton(
                    key: const Key('end_workout_placeholder'),
                    label: 'End placeholder session',
                    onPressed: () => context.pop(),
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
