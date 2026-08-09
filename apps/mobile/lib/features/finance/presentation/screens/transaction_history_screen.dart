import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_category.dart';
import '../widgets/transaction_list_tile.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(financeTransactionsProvider);
    final catsAsync = ref.watch(financeCategoriesProvider);
    final categoriesById = <String, FinanceCategory>{
      for (final c in catsAsync.valueOrNull ?? const <FinanceCategory>[])
        c.id: c,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Transaction History',
              subtitle: 'Income and expenses',
              leading: IconButton(
                key: const Key('transaction_history_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.finance),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              trailing: IconButton(
                key: const Key('transaction_history_add'),
                tooltip: 'Add transaction',
                onPressed: () => context.push(RoutePaths.addTransaction),
                icon: const Icon(Icons.add_rounded),
              ),
            ),
            Expanded(
              child: txsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.page),
                  child: LoadingCardSkeleton(
                    key: Key('transaction_history_loading'),
                    height: 120,
                    lines: 3,
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: InlineErrorCard(
                    key: const Key('transaction_history_error'),
                    message: userFacingErrorMessage(error),
                    onRetry: () {
                      ref.invalidate(financeTransactionsProvider);
                      ref.invalidate(financeCategoriesProvider);
                    },
                  ),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return EmptyFeatureCard(
                      key: const Key('transaction_history_empty'),
                      title: 'Transactions',
                      message: 'No transactions yet. Add income or an expense.',
                      icon: Icons.receipt_long_outlined,
                      actionLabel: 'Add transaction',
                      onAction: () => context.push(RoutePaths.addTransaction),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(financeRepositoryProvider).refresh();
                      ref.invalidate(financeTransactionsProvider);
                    },
                    child: ListView.separated(
                      key: const Key('transaction_history_list'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.xl,
                      ),
                      itemCount: transactions.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return TransactionListTile(
                          transaction: tx,
                          category: categoriesById[tx.categoryId],
                          onTap: () => context.push(
                            RoutePaths.transactionDetailPath(tx.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
