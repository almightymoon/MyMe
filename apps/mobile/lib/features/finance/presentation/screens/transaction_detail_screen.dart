import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_enums.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(financeTransactionByIdProvider(transactionId));
    final categories =
        ref.watch(financeCategoriesProvider).valueOrNull ?? const [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Transaction',
              subtitle: 'Details',
              leading: IconButton(
                key: const Key('transaction_detail_back'),
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: RoutePaths.transactionHistory),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: txAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.page),
                  child: LoadingCardSkeleton(height: 160, lines: 4),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: InlineErrorCard(
                    message: userFacingErrorMessage(error),
                    onRetry: () => ref.invalidate(financeTransactionsProvider),
                  ),
                ),
                data: (tx) {
                  if (tx == null) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      child: InlineErrorCard(
                        key: const Key('transaction_detail_missing'),
                        message: 'This transaction is no longer available.',
                        onRetry: () =>
                            context.go(RoutePaths.transactionHistory),
                      ),
                    );
                  }

                  String resolvedCategory = 'Unknown';
                  for (final category in categories) {
                    if (category.id == tx.categoryId) {
                      resolvedCategory = category.name;
                      break;
                    }
                  }
                  final isIncome = tx.type == TransactionType.income;
                  final amountLabel =
                      '${isIncome ? '+' : '−'}${MoneyFormat.formatMinor(tx.amountMinor, tx.currencyCode)}';

                  return ListView(
                    key: const Key('transaction_detail_scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.xl,
                    ),
                    children: [
                      MemyCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              amountLabel,
                              style: AppTextStyles.mono(fontSize: 28).copyWith(
                                fontWeight: FontWeight.w700,
                                color: isIncome
                                    ? AppColors.ember
                                    : AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${tx.type.label} · $resolvedCategory',
                              style: AppTextStyles.bodyMedium(),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().add_jm().format(
                                tx.occurredAt.toLocal(),
                              ),
                              style: AppTextStyles.bodySmall(
                                color: AppColors.faintText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DetailRow(
                        label: 'Payment method',
                        value: tx.paymentMethod.label,
                      ),
                      _DetailRow(
                        label: isIncome ? 'Source' : 'Merchant',
                        value: tx.merchantOrSource?.trim().isNotEmpty == true
                            ? tx.merchantOrSource!
                            : '—',
                      ),
                      _DetailRow(
                        label: 'Note',
                        value: tx.note?.trim().isNotEmpty == true
                            ? tx.note!
                            : '—',
                      ),
                      _DetailRow(
                        label: 'Created',
                        value: DateFormat.yMMMd().add_jm().format(
                          tx.createdAt.toLocal(),
                        ),
                      ),
                      _DetailRow(
                        label: 'Updated',
                        value: DateFormat.yMMMd().add_jm().format(
                          tx.updatedAt.toLocal(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      MemyPrimaryButton(
                        key: const Key('transaction_edit_button'),
                        label: 'Edit',
                        onPressed: () =>
                            context.push(RoutePaths.editTransactionPath(tx.id)),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton(
                        key: const Key('transaction_delete_button'),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              key: const Key('transaction_delete_dialog'),
                              title: const Text('Delete transaction?'),
                              content: Text(
                                'Remove $amountLabel from your local ledger? '
                                'This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  key: const Key('transaction_delete_confirm'),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true || !context.mounted) return;
                          try {
                            await ref
                                .read(financeRepositoryProvider)
                                .deleteTransaction(tx.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transaction deleted'),
                              ),
                            );
                            context.go(RoutePaths.transactionHistory);
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(userFacingErrorMessage(error)),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Delete',
                          style: AppTextStyles.labelMedium(
                            color: AppColors.health,
                          ),
                        ),
                      ),
                    ],
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MemyCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall(color: AppColors.faintText),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
