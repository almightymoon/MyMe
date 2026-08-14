import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_budget.dart';

class BudgetsOverviewScreen extends ConsumerWidget {
  const BudgetsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(financeBudgetMonthProvider);
    final progressAsync = ref.watch(financeBudgetsForSelectedMonthProvider);
    final categories =
        ref.watch(financeCategoriesProvider).valueOrNull ?? const [];
    final monthLabel = DateFormat.yMMMM().format(month.startLocal);

    return MemyModuleScaffold(
      key: const Key('budgets_overview'),
      title: 'Budgets',
      fallbackPath: RoutePaths.finance,
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addBudget),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                key: const Key('budget_prev_month'),
                tooltip: 'Previous month',
                onPressed: () =>
                    ref.read(financeBudgetMonthProvider.notifier).state =
                        month.previousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                key: const Key('budget_next_month'),
                tooltip: 'Next month',
                onPressed: () =>
                    ref.read(financeBudgetMonthProvider.notifier).state =
                        month.nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          progressAsync.when(
            loading: () => const LoadingCardSkeleton(height: 88, lines: 2),
            error: (error, _) => InlineErrorCard(
              key: const Key('budgets_error'),
              message: userFacingErrorMessage(error),
              onRetry: () {
                ref.invalidate(financeBudgetsProvider);
                ref.invalidate(financeTransactionsProvider);
              },
            ),
            data: (items) {
              if (items.isEmpty) {
                return EmptyFeatureCard(
                  key: const Key('budgets_empty'),
                  title: 'No budgets',
                  message:
                      'Set an overall or category spending limit for this month.',
                  icon: Icons.pie_chart_outline_rounded,
                  actionLabel: 'Add budget',
                  onAction: () => context.push(RoutePaths.addBudget),
                );
              }
              return Column(
                key: const Key('budgets_populated'),
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BudgetProgressTile(
                        progress: item,
                        categoryName: item.budget.isOverall
                            ? 'Overall'
                            : categories
                                  .where((c) => c.id == item.budget.categoryId)
                                  .map((c) => c.name)
                                  .firstOrNull,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressTile extends StatelessWidget {
  const _BudgetProgressTile({
    required this.progress,
    required this.categoryName,
  });

  final FinanceBudgetProgress progress;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final budget = progress.budget;
    final currency = budget.currencyCode;
    final remaining = progress.remainingSigned;
    final remainingLabel = progress.isOverspent
        ? 'Overspent ${MoneyFormat.formatSignedMinor(remaining.abs(), currency)}'
        : 'Remaining ${MoneyFormat.formatMinor(MoneyMinor.fromBigInt(remaining), currency)}';
    final ratio = (progress.spentBasisPoints / 10000).clamp(0.0, 1.0);

    return MemyCard(
      key: Key('budget_tile_${budget.id}'),
      onTap: () => context.push(RoutePaths.budgetDetailPath(budget.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            budget.name,
            style: AppTextStyles.titleSmall().copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            categoryName ?? 'Category',
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          ),
          const SizedBox(height: 10),
          Semantics(
            label:
                '${budget.name}. Spent ${MoneyFormat.formatMinor(progress.spentMinor, currency)} of ${MoneyFormat.formatMinor(budget.amountMinor, currency)}. $remainingLabel.',
            child: LinearProgressIndicator(
              value: ratio,
              color: progress.isOverspent ? AppColors.health : AppColors.ember,
              backgroundColor: AppColors.progressTrack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${MoneyFormat.formatMinor(progress.spentMinor, currency)} spent of ${MoneyFormat.formatMinor(budget.amountMinor, currency)}',
            style: AppTextStyles.bodySmall(),
          ),
          Text(
            remainingLabel,
            style: AppTextStyles.bodySmall(
              color: progress.isOverspent
                  ? AppColors.health
                  : AppColors.faintText,
            ),
          ),
        ],
      ),
    );
  }
}
