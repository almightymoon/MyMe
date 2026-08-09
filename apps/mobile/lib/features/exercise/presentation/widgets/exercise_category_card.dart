import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/exercise_category.dart';
import 'exercise_artwork.dart';

class ExerciseCategoryCard extends StatelessWidget {
  const ExerciseCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.exerciseCount,
  });

  final ExerciseCategory category;
  final VoidCallback onTap;
  final int? exerciseCount;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: '${category.label} category. ${category.subtitle}',
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.cardRadius,
            boxShadow: AppColors.softShadow,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: Key('exercise_category_${category.id}'),
              onTap: onTap,
              borderRadius: AppRadii.cardRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.card),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ExerciseArtwork(
                            category: category,
                            borderRadius: BorderRadius.zero,
                            cacheWidth: 420,
                          ),
                          Positioned(
                            left: AppSpacing.sm,
                            top: AppSpacing.sm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(
                                  alpha: 0.92,
                                ),
                                borderRadius: AppRadii.pillRadius,
                              ),
                              child: Text(
                                'Decorative art',
                                style: AppTextStyles.labelSmall(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.label,
                          style: AppTextStyles.titleSmall(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.subtitle,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (exerciseCount != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$exerciseCount moves',
                            style: AppTextStyles.labelMedium(
                              color: AppColors.emberDark,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
