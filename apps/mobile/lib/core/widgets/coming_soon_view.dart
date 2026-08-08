import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';

class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.featureName,
    required this.explanation,
    this.onBack,
  });

  final String featureName;
  final String explanation;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text(AppStrings.back),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.hourglass_empty_rounded,
            size: 56,
            color: AppColors.ember,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            featureName,
            style: AppTextStyles.displayMedium(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.comingSoon,
            style: AppTextStyles.kicker(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            explanation,
            style: AppTextStyles.bodyLarge(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
