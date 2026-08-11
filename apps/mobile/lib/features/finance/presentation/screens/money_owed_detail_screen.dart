import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_money_position.dart';

class MoneyOwedDetailScreen extends ConsumerWidget {
  const MoneyOwedDetailScreen({super.key, required this.positionId});

  final String positionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(
      financeMoneyPositionByIdProvider(positionId),
    );
    final today = LocalDate.fromDateTime(DateTime.now());

    return MemyModuleScaffold(
      key: const Key('money_owed_detail'),
      title: 'Money owed',
      fallbackPath: RoutePaths.financeMoneyOwed,
      showBottomNav: false,
      child: positionAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(financeMoneyPositionsProvider),
        ),
        data: (position) {
          if (position == null) {
            return InlineErrorCard(
              title: 'Not found',
              message: 'This money-owed entry is no longer on this device.',
              onRetry: () => context.go(RoutePaths.financeMoneyOwed),
            );
          }
          final status = position.statusAt(today);
          final due = position.dueDate;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                position.counterparty,
                style: AppTextStyles.titleMedium().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(position.direction.label),
              const SizedBox(height: 12),
              Text(
                'Remaining ${MoneyFormat.formatMinor(position.remainingMinor, position.currencyCode)}',
              ),
              Text(
                'Original ${MoneyFormat.formatMinor(position.originalAmountMinor, position.currencyCode)}',
              ),
              Text(
                'Paid ${MoneyFormat.formatMinor(position.paidMinor, position.currencyCode)}',
              ),
              const SizedBox(height: 8),
              Text(
                status.label,
                style: AppTextStyles.bodySmall(
                  color: status == MoneyPositionStatus.overdue
                      ? AppColors.health
                      : AppColors.faintText,
                ),
              ),
              if (due != null)
                Text(
                  'Due ${DateFormat.yMMMd().format(due.toDateTimeLocal())}',
                  style: AppTextStyles.bodySmall(color: AppColors.faintText),
                ),
              if (position.note != null) ...[
                const SizedBox(height: 8),
                Text(position.note!),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  TextButton(
                    key: const Key('money_owed_edit_button'),
                    onPressed: () =>
                        context.push(RoutePaths.editMoneyOwedPath(position.id)),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    key: const Key('money_owed_delete_button'),
                    onPressed: () => _confirmDelete(context, ref, position),
                    child: const Text('Delete'),
                  ),
                ],
              ),
              if (!position.isSettled) ...[
                const SizedBox(height: AppSpacing.sm),
                MemyPrimaryButton(
                  key: const Key('money_owed_record_payment'),
                  label: 'Record payment',
                  onPressed: () => _recordPayment(context, ref, position),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Payments',
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (position.payments.isEmpty)
                const Text('No payments recorded yet.')
              else
                for (final payment in position.payments.reversed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${MoneyFormat.formatMinor(payment.amountMinor, position.currencyCode)} · ${DateFormat.yMMMd().format(payment.paidAt)}'
                      '${payment.note == null ? '' : ' · ${payment.note}'}',
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _recordPayment(
    BuildContext context,
    WidgetRef ref,
    FinanceMoneyPosition position,
  ) async {
    final amountController = TextEditingController();
    final recorded = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record payment'),
          content: TextField(
            key: const Key('money_owed_payment_amount'),
            controller: amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              helperText:
                  'Up to ${MoneyFormat.formatMinor(position.remainingMinor, position.currencyCode)} remaining',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('money_owed_payment_confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    final raw = amountController.text;
    amountController.dispose();
    if (recorded != true || !context.mounted) return;
    MoneyMinor? amount;
    try {
      amount = MoneyFormat.parseMajorToMinor(raw);
    } on FormatException {
      amount = null;
    }
    if (amount == null || !amount.isPositive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid payment amount')),
      );
      return;
    }
    try {
      final uuid = ref.read(uuidProvider);
      await ref
          .read(financeRepositoryProvider)
          .recordMoneyPayment(
            positionId: position.id,
            payment: FinanceMoneyPayment(
              id: uuid.v4(),
              amountMinor: amount,
              paidAt: DateTime.now(),
            ),
          );
      ref.invalidate(financeMoneyPositionsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment recorded')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    FinanceMoneyPosition position,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text(
          'This removes the amount and its payment history from this device.',
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
      await ref
          .read(financeRepositoryProvider)
          .deleteMoneyPosition(position.id);
      ref.invalidate(financeMoneyPositionsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
      memyBack(context, fallback: RoutePaths.financeMoneyOwed);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    }
  }
}
