import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/exercise_category.dart';
import '../../domain/entities/exercise_difficulty.dart';
import '../../domain/entities/exercise_item.dart';
import 'exercise_artwork.dart';
import 'exercise_difficulty_badge.dart';

class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({super.key, required this.exercise, this.onTap});

  final ExerciseItem exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label:
          '${exercise.name}, ${exercise.category.label}, ${exercise.difficulty.label}, ${exercise.effortLabel}',
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
        child: InkWell(
          key: Key('exercise_tile_${exercise.id}'),
          onTap: onTap,
          borderRadius: AppRadii.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  height: 90,
                  child: ExerciseArtwork(
                    category: exercise.category,
                    cacheWidth: 220,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: AppTextStyles.titleMedium()),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${exercise.category.label} · ${exercise.effortLabel}',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ExerciseDifficultyBadge(difficulty: exercise.difficulty),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        exercise.description,
                        style: AppTextStyles.bodySmall(
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Artwork is decorative — not form guidance.',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.faintText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
