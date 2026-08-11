import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_money_position.dart';

class MoneyOwedOverviewScreen extends ConsumerWidget {
  const MoneyOwedOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionsAsync = ref.watch(financeMoneyPositionsProvider);
    final totalsAsync = ref.watch(financeMoneyOwedTotalsProvider);
    final today = LocalDate.fromDateTime(DateTime.now());

    return MemyModuleScaffold(
      key: const Key('money_owed_overview'),
      title: 'Money owed',
      fallbackPath: RoutePaths.finance,
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addMoneyOwed),
      ),
      child: positionsAsync.when(
        loading: () => const LoadingCardSkeleton(height: 88, lines: 2),
        error: (error, _) => InlineErrorCard(
          key: const Key('money_owed_error'),
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(financeMoneyPositionsProvider),
        ),
        data: (positions) {
          if (positions.isEmpty) {
            return EmptyFeatureCard(
              key: const Key('money_owed_empty'),
              title: 'No money owed',
              message:
                  'Track what you owe someone, or what they owe you. '
                  'No interest, just amounts and payments.',
              icon: Icons.handshake_outlined,
              actionLabel: 'Add entry',
              onAction: () => context.push(RoutePaths.addMoneyOwed),
            );
          }
          final totals = totalsAsync.valueOrNull;
          final iOwe = positions
              .where((p) => p.direction == MoneyPositionDirection.iOwe)
              .toList(growable: false);
          final owedToMe = positions
              .where((p) => p.direction == MoneyPositionDirection.owedToMe)
              .toList(growable: false);
          return Column(
            key: const Key('money_owed_populated'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (totals != null) ...[
                Text(
                  'I owe ${MoneyFormat.formatMinor(totals.iOweRemaining, totals.currencyCode)} · '
                  'Owed to me ${MoneyFormat.formatMinor(totals.owedToMeRemaining, totals.currencyCode)}',
                  style: AppTextStyles.bodySmall(color: AppColors.faintText),
                ),
                if (totals.overdueCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${totals.overdueCount} overdue',
                    style: AppTextStyles.bodySmall(color: AppColors.health),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
              if (iOwe.isNotEmpty) ...[
                Text(
                  'I owe',
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final position in iOwe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MoneyOwedTile(position: position, today: today),
                  ),
              ],
              if (owedToMe.isNotEmpty) ...[
                Text(
                  'Owed to me',
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final position in owedToMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MoneyOwedTile(position: position, today: today),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MoneyOwedTile extends StatelessWidget {
  const _MoneyOwedTile({required this.position, required this.today});

  final FinanceMoneyPosition position;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final status = position.statusAt(today);
    final due = position.dueDate;
    final dueLabel = due == null
        ? null
        : 'Due ${DateFormat.yMMMd().format(due.toDateTimeLocal())}';

    return MemyCard(
      key: Key('money_owed_tile_${position.id}'),
      onTap: () => context.push(RoutePaths.moneyOwedDetailPath(position.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  position.counterparty,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                status.label,
                style: AppTextStyles.bodySmall(
                  color: status == MoneyPositionStatus.overdue
                      ? AppColors.health
                      : AppColors.faintText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${MoneyFormat.formatMinor(position.remainingMinor, position.currencyCode)} remaining of ${MoneyFormat.formatMinor(position.originalAmountMinor, position.currencyCode)}',
            style: AppTextStyles.bodySmall(),
          ),
          if (dueLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              dueLabel,
              style: AppTextStyles.bodySmall(color: AppColors.faintText),
            ),
          ],
        ],
      ),
    );
  }
}
