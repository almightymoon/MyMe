import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../data/seed/finance_seed.dart';

/// Finance Overview matching prototype `data-screen="finance"`.
class FinancePlaceholderScreen extends StatefulWidget {
  const FinancePlaceholderScreen({super.key});

  @override
  State<FinancePlaceholderScreen> createState() =>
      _FinancePlaceholderScreenState();
}

class _FinancePlaceholderScreenState extends State<FinancePlaceholderScreen> {
  /// `lent` = Expecting back, `loans` = You owe
  String _moneyTab = 'lent';

  @override
  Widget build(BuildContext context) {
    final rows = _moneyTab == 'loans' ? FinanceSeed.loans : FinanceSeed.lent;

    return MemyModuleScaffold(
      key: const Key('finance_overview'),
      title: 'Finance Overview',
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addTransaction),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: AppTextStyles.bodySmall().copyWith(
                        color: AppColors.faintText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FinanceSeed.demoSummary.balanceLabel,
                      style: AppTextStyles.mono(fontSize: 30).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.surface,
                borderRadius: AppRadii.pillRadius,
                elevation: 0,
                shadowColor: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.pillRadius,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Period filter — demo only'),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.pillRadius,
                      boxShadow: AppColors.softShadow,
                      color: AppColors.surface,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'This Month',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.secondaryText,
                          ).copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        FinanceSeed.demoSummary.incomeLabel,
                        style: AppTextStyles.titleMedium(
                          color: AppColors.ember,
                        ).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expenses',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        FinanceSeed.demoSummary.expensesLabel,
                        style: AppTextStyles.titleMedium().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Spending Breakdown',
                  style: AppTextStyles.titleMedium().copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push(RoutePaths.addTransaction),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.faintText,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _DonutPainter(
                    categories: FinanceSeed.categories,
                    holeColor: AppColors.canvas,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    for (final cat in FinanceSeed.categories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                color: Color(cat.color.value),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: AppTextStyles.bodySmall().copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${cat.pct.round()}%',
                                  style: AppTextStyles.bodySmall().copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  cat.amountLabel,
                                  style: AppTextStyles.bodySmall(
                                    color: AppColors.faintText,
                                  ).copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Loans & Money Out',
                  style: AppTextStyles.titleMedium().copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add entry coming soon'),
                      duration: Duration(milliseconds: 900),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.faintText,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Add',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MoneyTab(
                  label: 'Expecting back',
                  selected: _moneyTab == 'lent',
                  onTap: () => setState(() => _moneyTab = 'lent'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MoneyTab(
                  label: 'You owe',
                  selected: _moneyTab == 'loans',
                  onTap: () => setState(() => _moneyTab = 'loans'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expecting back',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FinanceSeed.formatPkr(FinanceSeed.lentTotal),
                        style: AppTextStyles.titleMedium().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${FinanceSeed.lent.length} people',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MemyCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You owe',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FinanceSeed.formatPkr(FinanceSeed.loanTotal),
                        style: AppTextStyles.titleMedium().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${FinanceSeed.loans.length} loans',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _moneyTab == 'loans'
                    ? 'No loans listed yet.'
                    : 'No money lent out yet.',
                style: AppTextStyles.bodySmall(color: AppColors.faintText),
              ),
            )
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _MoneyRow(party: rows[i]),
            ],
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _MoneyTab extends StatelessWidget {
  const _MoneyTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.ember : AppColors.surface,
        borderRadius: AppRadii.pillRadius,
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x47FF6A1A),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ]
            : AppColors.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.pillRadius,
          splashColor: selected
              ? Colors.white24
              : AppColors.ember.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium(
                color: selected ? Colors.white : AppColors.faintText,
              ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.party});

  final MoneyParty party;

  String get _initials {
    final parts = party.name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2);
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  Color get _dueColor {
    switch (party.status) {
      case 'overdue':
        return AppColors.health;
      case 'due-soon':
        return AppColors.ember;
      default:
        return AppColors.faintText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${party.name}: ${party.amountLabel}'),
            duration: const Duration(milliseconds: 900),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.orangeSoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials,
              style: AppTextStyles.labelMedium(color: AppColors.ember).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  party.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  party.note,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                party.amountLabel,
                style: AppTextStyles.bodyMedium().copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Due ${party.dueLabel}',
                style: AppTextStyles.bodySmall(color: _dueColor).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.categories, required this.holeColor});

  final List<SpendCategory> categories;
  final Color holeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final stroke = radius * 0.42;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    for (final cat in categories) {
      final sweep = (cat.pct / 100) * 2 * math.pi;
      paint.color = Color(cat.color.value);
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }

    canvas.drawCircle(
      center,
      radius - stroke,
      Paint()..color = holeColor,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.holeColor != holeColor;
  }
}
