import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Fixed medical/wellness disclaimer shown on every Health screen.
///
/// MeMy shows wellness metrics only — never a diagnosis, "Health Score", or
/// medical advice. This text must stay visible wherever Health data is
/// displayed; do not hide it behind a tooltip or "learn more" link.
class HealthDisclaimerBanner extends StatelessWidget {
  const HealthDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('health_disclaimer'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.canvasDeep,
        borderRadius: AppRadii.chipRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.faintText,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Wellness information only — not a diagnosis or medical '
              'advice. Talk to a healthcare professional about any health '
              'concerns.',
              style: AppTextStyles.bodySmall().copyWith(
                fontSize: 12,
                color: AppColors.faintText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
