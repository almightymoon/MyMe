import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_transaction.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  final FinanceTransaction transaction;
  final FinanceCategory? category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountPrefix = isIncome ? '+' : '−';
    final title = transaction.merchantOrSource?.trim().isNotEmpty == true
        ? transaction.merchantOrSource!
        : (category?.name ?? 'Transaction');
    final subtitle =
        '${category?.name ?? 'Unknown'} · '
        '${DateFormat.MMMd().add_jm().format(transaction.occurredAt.toLocal())}';

    return MemyCard(
      key: Key('transaction_tile_${transaction.id}'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isIncome ? AppColors.orangeSoft : AppColors.well,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 18,
              color: isIncome ? AppColors.ember : AppColors.primaryText,
              semanticLabel: isIncome ? 'Income' : 'Expense',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$amountPrefix${MoneyFormat.formatMinor(transaction.amountMinor, transaction.currencyCode)}',
            style: AppTextStyles.bodyMedium().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isIncome ? AppColors.ember : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
