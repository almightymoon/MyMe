import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../constants/app_strings.dart';
import 'memy_card.dart';
import 'section_header.dart';

class EmptyFeatureCard extends StatelessWidget {
  const EmptyFeatureCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('empty_feature_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.faintText),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.nothingHereYet,
                      style: AppTextStyles.titleSmall(),
                    ),
                    const SizedBox(height: 4),
                    Text(message, style: AppTextStyles.bodyMedium()),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        key: const Key('empty_feature_action'),
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
