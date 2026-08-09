import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_enums.dart';
import '../widgets/finance_balance_header.dart';
import '../widgets/income_expense_summary.dart';
import '../widgets/planned_finance_feature_card.dart';
import '../widgets/spending_breakdown_card.dart';

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
          },
        ),
        data: (summary) {
          final allEmpty = txsAsync.maybeWhen(
            data: (txs) => txs.isEmpty,
            orElse: () => !summary.hasTransactions,
          );
          if (allEmpty) {
            return EmptyFeatureCard(
              key: const Key('finance_empty'),
              title: 'Finance',
              message: 'Add your first income or expense to start tracking.',
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: 'Add transaction',
              onAction: () => context.push(RoutePaths.addTransaction),
            );
          }

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
              const SizedBox(height: 22),
              SpendingBreakdownCard(summary: summary),
              const SizedBox(height: 22),
              const PlannedFinanceFeatureCard(),
              const SizedBox(height: AppSpacing.md),
            ],
          );
        },
      ),
    );
  }
}
