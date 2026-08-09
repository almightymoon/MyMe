import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../domain/entities/finance_summary.dart';

class FinanceBalanceHeader extends StatelessWidget {
  const FinanceBalanceHeader({
    super.key,
    required this.summary,
    required this.periodLabel,
    required this.onPeriodTap,
  });

  final FinanceSummary summary;
  final String periodLabel;
  final VoidCallback onPeriodTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: AppTextStyles.bodySmall().copyWith(
                  color: AppColors.faintText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                key: const Key('finance_balance_value'),
                MoneyFormat.formatSignedMinor(
                  summary.currentBalanceMinor,
                  summary.currencyCode,
                ),
                style: AppTextStyles.mono(fontSize: 30).copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.surface,
          borderRadius: AppRadii.pillRadius,
          elevation: 0,
          shadowColor: Colors.transparent,
          child: InkWell(
            key: const Key('finance_period_selector'),
            borderRadius: AppRadii.pillRadius,
            onTap: onPeriodTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: AppRadii.pillRadius,
                boxShadow: AppColors.softShadow,
                color: AppColors.surface,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    periodLabel,
                    style: AppTextStyles.labelSmall(
                      color: AppColors.secondaryText,
                    ).copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
