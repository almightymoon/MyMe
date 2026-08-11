import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../domain/entities/finance_enums.dart';
import '../widgets/finance_balance_header.dart';
import '../widgets/income_expense_summary.dart';
import '../widgets/spending_breakdown_card.dart';
import '../widgets/transaction_list_tile.dart';

class FinanceOverviewScreen extends ConsumerWidget {
  const FinanceOverviewScreen({super.key});

  Future<void> _pickPeriod(BuildContext context, WidgetRef ref) async {
    final current = ref.read(financePeriodProvider);
    final selected = await showModalBottomSheet<FinancePeriod>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final period in FinancePeriod.values)
                ListTile(
                  key: Key('finance_period_${period.name}'),
                  title: Text(period.label),
                  trailing: period == current
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(context, period),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      ref.read(financePeriodProvider.notifier).state = selected;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(financeSummaryProvider);
    final txsAsync = ref.watch(financeTransactionsProvider);
    final cats = ref.watch(financeCategoriesProvider).valueOrNull ?? const [];
    final budgetsAsync = ref.watch(financeBudgetsForSelectedMonthProvider);
    final moneyTotals = ref.watch(financeMoneyOwedTotalsProvider).valueOrNull;
    final moneyPositions =
        ref.watch(financeMoneyPositionsProvider).valueOrNull ?? const [];

    return MemyModuleScaffold(
      key: const Key('finance_overview'),
      title: 'Finance Overview',
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addTransaction),
      ),
      child: summaryAsync.when(
        loading: () => const Column(
          key: Key('finance_loading'),
          children: [
            LoadingCardSkeleton(height: 72, lines: 2),
            SizedBox(height: 12),
            LoadingCardSkeleton(height: 88, lines: 2),
            SizedBox(height: 12),
            LoadingCardSkeleton(height: 160, lines: 3),
          ],
        ),
        error: (error, _) => InlineErrorCard(
          key: const Key('finance_error'),
          message: userFacingErrorMessage(error),
          onRetry: () {
            ref.invalidate(financeTransactionsProvider);
            ref.invalidate(financeCategoriesProvider);
            ref.invalidate(financeBudgetsProvider);
            ref.invalidate(financeMoneyPositionsProvider);
          },
        ),
        data: (summary) {
          final allEmpty = txsAsync.maybeWhen(
            data: (txs) => txs.isEmpty,
            orElse: () => !summary.hasTransactions,
          );
          if (allEmpty && moneyPositions.isEmpty) {
            return Column(
              key: const Key('finance_empty'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmptyFeatureCard(
                  title: 'Finance',
                  message:
                      'Add your first income or expense to start tracking.',
                  icon: Icons.account_balance_wallet_outlined,
                  actionLabel: 'Add transaction',
                  onAction: () => context.push(RoutePaths.addTransaction),
                ),
                const SizedBox(height: AppSpacing.md),
                _FinanceNavTile(
                  keyName: 'finance_nav_money_owed',
                  label: 'Money owed',
                  onTap: () => context.push(RoutePaths.financeMoneyOwed),
                ),
                _FinanceNavTile(
                  keyName: 'finance_nav_budgets',
                  label: 'Budgets',
                  onTap: () => context.push(RoutePaths.financeBudgets),
                ),
              ],
            );
          }

          final recent = (txsAsync.valueOrNull ?? const []).take(5).toList();
          final budgetProgress = budgetsAsync.valueOrNull ?? const [];

          return Column(
            key: const Key('finance_populated'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FinanceBalanceHeader(
                summary: summary,
                periodLabel: summary.selectedPeriod.label,
                onPeriodTap: () => _pickPeriod(context, ref),
              ),
              const SizedBox(height: 14),
              IncomeExpenseSummary(summary: summary),
              const SizedBox(height: 14),
              if (budgetProgress.isNotEmpty) ...[
                for (final item in budgetProgress.take(2))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MemyCard(
                      key: Key('overview_budget_${item.budget.id}'),
                      onTap: () => context.push(RoutePaths.financeBudgets),
                      child: Text(
                        item.isOverspent
                            ? '${item.budget.name} is overspent by ${MoneyFormat.formatSignedMinor(item.remainingSigned.abs(), item.budget.currencyCode)}'
                            : '${item.budget.name}: ${MoneyFormat.formatMinor(MoneyMinor.fromBigInt(item.remainingSigned), item.budget.currencyCode)} remaining',
                      ),
                    ),
                  ),
              ],
              SpendingBreakdownCard(summary: summary),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent transactions',
                      style: AppTextStyles.titleMedium().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('finance_history_action'),
                    onPressed: () =>
                        context.push(RoutePaths.transactionHistory),
                    child: const Text('History'),
                  ),
                ],
              ),
              for (final tx in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionListTile(
                    transaction: tx,
                    category: cats
                        .where((c) => c.id == tx.categoryId)
                        .firstOrNull,
                    onTap: () =>
                        context.push(RoutePaths.transactionDetailPath(tx.id)),
                  ),
                ),
              const SizedBox(height: 8),
              _FinanceNavTile(
                keyName: 'finance_nav_budgets',
                label: 'Budgets',
                onTap: () => context.push(RoutePaths.financeBudgets),
              ),
              _FinanceNavTile(
                keyName: 'finance_nav_reports',
                label: 'Reports',
                onTap: () => context.push(RoutePaths.financeReports),
              ),
              _FinanceNavTile(
                keyName: 'finance_nav_categories',
                label: 'Categories',
                onTap: () => context.push(RoutePaths.financeCategories),
              ),
              _FinanceNavTile(
                keyName: 'finance_nav_money_owed',
                label: 'Money owed',
                onTap: () => context.push(RoutePaths.financeMoneyOwed),
              ),
              if (moneyTotals != null &&
                  (moneyTotals.openCount > 0 ||
                      moneyTotals.iOweRemaining.isPositive ||
                      moneyTotals.owedToMeRemaining.isPositive)) ...[
                const SizedBox(height: 10),
                MemyCard(
                  key: const Key('finance_money_owed_glance'),
                  onTap: () => context.push(RoutePaths.financeMoneyOwed),
                  child: Text(
                    'I owe ${MoneyFormat.formatMinor(moneyTotals.iOweRemaining, moneyTotals.currencyCode)} · '
                    'Owed to me ${MoneyFormat.formatMinor(moneyTotals.owedToMeRemaining, moneyTotals.currencyCode)}'
                    '${moneyTotals.overdueCount > 0 ? ' · ${moneyTotals.overdueCount} overdue' : ''}',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
          );
        },
      ),
    );
  }
}

class _FinanceNavTile extends StatelessWidget {
  const _FinanceNavTile({
    required this.keyName,
    required this.label,
    required this.onTap,
  });

  final String keyName;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: Key(keyName),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Icon(Icons.chevron_right_rounded, color: AppColors.faintText),
            ],
          ),
        ),
      ),
    );
  }
}
