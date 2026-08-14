import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../domain/entities/finance_summary.dart';

class IncomeExpenseSummary extends StatelessWidget {
  const IncomeExpenseSummary({super.key, required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MemyCard(
            key: const Key('finance_income_card'),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  MoneyFormat.formatMinor(
                    summary.periodIncomeMinor,
                    summary.currencyCode,
                  ),
                  style: AppTextStyles.titleMedium(color: AppColors.ember)
                      .copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MemyCard(
            key: const Key('finance_expense_card'),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expenses',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  MoneyFormat.formatMinor(
                    summary.periodExpenseMinor,
                    summary.currencyCode,
                  ),
                  style: AppTextStyles.titleMedium().copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
