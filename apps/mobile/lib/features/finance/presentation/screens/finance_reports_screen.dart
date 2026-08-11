import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_enums.dart';

class FinanceReportsScreen extends ConsumerWidget {
  const FinanceReportsScreen({super.key = const Key('finance_reports')});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(financePeriodProvider);
    final reportAsync = ref.watch(financePeriodReportProvider);

    return MemyModuleScaffold(
      title: 'Reports',
      fallbackPath: RoutePaths.finance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in FinancePeriod.values)
                ChoiceChip(
                  key: Key('report_period_${value.name}'),
                  label: Text(value.label),
                  selected: period == value,
                  onSelected: (_) =>
                      ref.read(financePeriodProvider.notifier).state = value,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          reportAsync.when(
            loading: () => const LoadingCardSkeleton(height: 160, lines: 4),
            error: (error, _) => InlineErrorCard(
              key: const Key('reports_error'),
              message: userFacingErrorMessage(error),
              onRetry: () {
                ref.invalidate(financeTransactionsProvider);
                ref.invalidate(financeBudgetsProvider);
              },
            ),
            data: (report) {
              if (report.transactionCount == 0) {
                return const EmptyFeatureCard(
                  key: Key('reports_empty'),
                  title: 'No report yet',
                  message:
                      'Add income or expenses to see period totals and categories.',
                  icon: Icons.insights_outlined,
                );
              }
              final currency = report.currencyCode;
              return Column(
                key: const Key('reports_populated'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReportLine(
                    label: 'Income',
                    value: MoneyFormat.formatMinor(
                      report.incomeMinor,
                      currency,
                    ),
                  ),
                  _ReportLine(
                    label: 'Expenses',
                    value: MoneyFormat.formatMinor(
                      report.expenseMinor,
                      currency,
                    ),
                  ),
                  _ReportLine(
                    label: 'Net cash flow',
                    value: MoneyFormat.formatSignedMinor(
                      report.netCashFlowMinor,
                      currency,
                    ),
                  ),
                  _ReportLine(
                    label: 'Transactions',
                    value: '${report.transactionCount}',
                  ),
                  _ReportLine(
                    label: 'Average daily spending',
                    value: MoneyFormat.formatMinor(
                      report.averageDailyExpenseMinor,
                      currency,
                    ),
                  ),
                  if (report.previousExpenseMinor != null)
                    _ReportLine(
                      label: 'Previous period expenses',
                      value: MoneyFormat.formatMinor(
                        report.previousExpenseMinor!,
                        currency,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Top expense categories',
                    style: AppTextStyles.titleSmall().copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (report.topExpenseCategories.isEmpty)
                    Text(
                      'No expenses in this period.',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.faintText,
                      ),
                    )
                  else
                    for (final item in report.topExpenseCategories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${item.categoryName}: ${MoneyFormat.formatMinor(item.amountMinor, currency)} (${item.percentageRounded}%)',
                        ),
                      ),
                  if (report.budgetProgress.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Budget performance',
                      style: AppTextStyles.titleSmall().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final item in report.budgetProgress)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${item.budget.name}: ${MoneyFormat.formatMinor(item.spentMinor, currency)} of ${MoneyFormat.formatMinor(item.budget.amountMinor, currency)}${item.isOverspent ? ' — overspent' : ''}',
                        ),
                      ),
                  ],
                  if (report.deterministicSummary != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      report.deterministicSummary!,
                      key: const Key('reports_text_summary'),
                      style: AppTextStyles.bodyMedium(),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportLine extends StatelessWidget {
  const _ReportLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: AppTextStyles.bodyMedium().copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
