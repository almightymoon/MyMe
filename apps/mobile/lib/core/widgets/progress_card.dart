import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'memy_card.dart';
import 'section_header.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.headline,
    required this.progressPercent,
    this.detail,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String headline;
  final double progressPercent;
  final String? detail;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final clamped = progressPercent.clamp(0, 100) / 100;

    return MemyCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, trailing: trailing),
          Text(headline, style: AppTextStyles.titleMedium()),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8,
              backgroundColor: AppColors.progressTrack,
              color: AppColors.ember,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(detail!, style: AppTextStyles.bodySmall()),
          ],
        ],
      ),
    );
  }
}
