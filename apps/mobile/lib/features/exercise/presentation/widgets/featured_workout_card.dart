import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../domain/entities/featured_workout.dart';
import 'exercise_artwork.dart';

class FeaturedWorkoutCard extends StatelessWidget {
  const FeaturedWorkoutCard({
    super.key,
    required this.workout,
    required this.onStart,
  });

  final FeaturedWorkout workout;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        container: true,
        label:
            'Featured workout ${workout.title}, ${workout.durationMinutes} minutes',
        child: Container(
          key: const Key('featured_workout_card'),
          decoration: BoxDecoration(
            color: AppColors.depth,
            borderRadius: AppRadii.cardRadius,
            boxShadow: AppColors.liftShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ExerciseArtwork(
                      category: workout.category,
                      borderRadius: BorderRadius.zero,
                      cacheWidth: 900,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.depth.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FEATURED · DECORATIVE ART',
                            style: AppTextStyles.kicker(color: Colors.white70),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            workout.title,
                            style: AppTextStyles.titleLarge(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            workout.subtitle,
                            style: AppTextStyles.bodyMedium(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${workout.durationMinutes} min · ${workout.focusAreas.join(' · ')}',
                      style: AppTextStyles.bodySmall(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MemyPrimaryButton(
                      key: const Key('featured_start_workout'),
                      label: 'Start this workout',
                      onPressed: onStart,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
