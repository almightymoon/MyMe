import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../constants/app_strings.dart';

class RetryButton extends StatelessWidget {
  const RetryButton({
    super.key,
    required this.onPressed,
    this.label = AppStrings.retry,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('retry_button'),
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.emberDark,
        side: BorderSide(color: AppColors.ember),
        minimumSize: const Size(0, AppSpacing.minTouch),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.controlRadius,
        ),
        textStyle: AppTextStyles.labelLarge(),
      ),
    );
  }
}
