import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';

/// Placeholder for deferred loans / lending — not fake live data.
class PlannedFinanceFeatureCard extends StatelessWidget {
  const PlannedFinanceFeatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Loans & Money Out',
          style: AppTextStyles.titleMedium().copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        MemyCard(
          key: const Key('finance_planned_feature'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule_rounded, color: AppColors.faintText),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Planned feature',
                      style: AppTextStyles.titleSmall().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Loans, lending, and money owed will arrive in a later '
                      'release. Manual income and expenses are available now.',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.faintText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
