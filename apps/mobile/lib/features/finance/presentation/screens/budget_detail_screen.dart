import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_budget.dart';
import '../../domain/entities/finance_enums.dart';
import '../widgets/transaction_list_tile.dart';

class BudgetDetailScreen extends ConsumerWidget {
  const BudgetDetailScreen({super.key, required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(financeBudgetByIdProvider(budgetId));
    final txsAsync = ref.watch(financeTransactionsProvider);
    final cats = ref.watch(financeCategoriesProvider).valueOrNull ?? const [];
    final report = ref.watch(financeReportServiceProvider);

    return MemyModuleScaffold(
      key: const Key('budget_detail'),
      title: 'Budget',
      fallbackPath: RoutePaths.financeBudgets,
      showBottomNav: false,
      child: budgetAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(financeBudgetsProvider),
        ),
        data: (budget) {
          if (budget == null) {
            return InlineErrorCard(
              title: 'Budget not found',
              message: 'This budget is no longer on this device.',
              onRetry: () => context.go(RoutePaths.financeBudgets),
            );
          }
          final txs = txsAsync.valueOrNull ?? const [];
          final spent = report.spentForBudget(
            budget: budget,
            transactions: txs,
            currencyCode: budget.currencyCode,
          );
          final progress = FinanceBudgetProgress(
            budget: budget,
            spentMinor: spent,
          );
          final related = txs
              .where((tx) {
                if (tx.type != TransactionType.expense) return false;
                final occurred = tx.occurredAt.toLocal();
                if (occurred.isBefore(budget.month.startLocal) ||
                    !occurred.isBefore(budget.month.endExclusiveLocal)) {
                  return false;
                }
                if (!budget.isOverall && tx.categoryId != budget.categoryId) {
                  return false;
                }
                return true;
              })
              .toList(growable: false);
          final remaining = progress.remainingSigned;
          final remainingLabel = progress.isOverspent
              ? 'Overspent ${MoneyFormat.formatSignedMinor(remaining.abs(), budget.currencyCode)}'
              : 'Remaining ${MoneyFormat.formatMinor(MoneyMinor.fromBigInt(remaining), budget.currencyCode)}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                budget.name,
                style: AppTextStyles.titleMedium().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(DateFormat.yMMMM().format(budget.month.startLocal)),
              const SizedBox(height: 12),
              Text(
                'Budget ${MoneyFormat.formatMinor(budget.amountMinor, budget.currencyCode)}',
              ),
              Text(
                'Spent ${MoneyFormat.formatMinor(spent, budget.currencyCode)}',
              ),
              Text(remainingLabel),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  TextButton(
                    key: const Key('budget_edit_button'),
                    onPressed: () =>
                        context.push(RoutePaths.editBudgetPath(budget.id)),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    key: const Key('budget_delete_button'),
                    onPressed: () => _confirmDelete(context, ref, budget),
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Related expenses',
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (related.isEmpty)
                const Text('No expenses counted against this budget yet.')
              else
                for (final tx in related.take(20))
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
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FinanceBudget budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this budget?'),
        content: const Text(
          'Spending totals stay. Only this monthly limit is removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(financeRepositoryProvider).deleteBudget(budget.id);
      ref.invalidate(financeBudgetsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget deleted')));
      memyBack(context, fallback: RoutePaths.financeBudgets);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    }
  }
}
