import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/exercise_difficulty.dart';

class ExerciseDifficultyBadge extends StatelessWidget {
  const ExerciseDifficultyBadge({super.key, required this.difficulty});

  final ExerciseDifficulty difficulty;

  Color get _background {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return const Color(0xFFE8F6EF);
      case ExerciseDifficulty.intermediate:
        return const Color(0xFFFFF1DF);
      case ExerciseDifficulty.advanced:
        return const Color(0xFFFFE8E2);
    }
  }

  Color get _foreground {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return AppColors.finance;
      case ExerciseDifficulty.intermediate:
        return const Color(0xFFB86A00);
      case ExerciseDifficulty.advanced:
        return AppColors.emberDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Difficulty ${difficulty.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          difficulty.label,
          style: AppTextStyles.labelMedium(color: _foreground),
        ),
      ),
    );
  }
}
