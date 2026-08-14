import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../constants/app_strings.dart';
import 'memy_card.dart';
import 'retry_button.dart';
import 'section_header.dart';

class InlineErrorCard extends StatelessWidget {
  const InlineErrorCard({
    super.key,
    required this.onRetry,
    this.title,
    this.message,
    this.retryButtonKey,
  });

  final VoidCallback onRetry;
  final String? title;
  final String? message;
  final Key? retryButtonKey;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('inline_error_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title ?? AppStrings.couldNotLoad),
          Text(
            message ?? AppStrings.demoLoadFailed,
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.ember),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.tryAgainHint,
                  style: AppTextStyles.bodySmall(),
                ),
              ),
              RetryButton(key: retryButtonKey, onPressed: onRetry),
            ],
          ),
        ],
      ),
    );
  }
}
