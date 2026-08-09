import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../../app/theme/app_radii.dart';

class FinancePlaceholderScreen extends StatelessWidget {
  const FinancePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MemyModuleScaffold(
      key: const Key('finance_overview'),
      title: 'Finance Overview',
      heroAsset: 'assets/images/modules/mod-finance.png',
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addTransaction),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total Balance',
            style: AppTextStyles.bodySmall().copyWith(
              color: AppColors.faintText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'PKR 245,000',
            style: AppTextStyles.mono(fontSize: 36).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PKR 180,000',
                        style: AppTextStyles.titleMedium(
                          color: AppColors.finance,
                        ).copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expenses',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PKR 89,000',
                        style: AppTextStyles.titleMedium(
                          color: AppColors.health,
                        ).copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Spending Breakdown', style: AppTextStyles.titleMedium()),
          const SizedBox(height: AppSpacing.sm),
          MemyCard(
            child: Column(
              children: const [
                _SpendRow(
                  label: 'Food & Dining',
                  amount: 'PKR 28,400',
                  pct: 0.32,
                ),
                _SpendRow(label: 'Transport', amount: 'PKR 14,200', pct: 0.16),
                _SpendRow(label: 'Shopping', amount: 'PKR 22,100', pct: 0.25),
                _SpendRow(
                  label: 'Bills',
                  amount: 'PKR 24,300',
                  pct: 0.27,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendRow extends StatelessWidget {
  const _SpendRow({
    required this.label,
    required this.amount,
    required this.pct,
    this.isLast = false,
  });

  final String label;
  final String amount;
  final double pct;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.bodyMedium())),
              Text(
                amount,
                style: AppTextStyles.bodySmall().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppRadii.pillRadius,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.progressTrack,
              color: AppColors.ember,
            ),
          ),
        ],
      ),
    );
  }
}
