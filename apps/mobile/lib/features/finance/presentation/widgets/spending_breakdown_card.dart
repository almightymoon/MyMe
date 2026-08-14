import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../domain/entities/finance_category_breakdown.dart';
import '../../domain/entities/finance_summary.dart';
import 'finance_category_colors.dart';

class SpendingBreakdownCard extends StatelessWidget {
  const SpendingBreakdownCard({super.key, required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = summary.categoryBreakdown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              key: const Key('finance_see_all'),
              onPressed: () => context.push(RoutePaths.transactionHistory),
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
        if (items.isEmpty)
          Text(
            key: const Key('finance_breakdown_empty'),
            'No expenses in this period yet.',
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: _DonutPainter(
                    items: items,
                    holeColor: AppColors.canvas,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    for (final item in items)
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
                                color: FinanceCategoryColors.forCategoryId(
                                  item.categoryId,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.categoryName,
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
                                  '${item.percentageRounded}%',
                                  style: AppTextStyles.bodySmall().copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  MoneyFormat.formatMinor(
                                    item.amountMinor,
                                    summary.currencyCode,
                                  ),
                                  style:
                                      AppTextStyles.bodySmall(
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
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.items, required this.holeColor});

  final List<FinanceCategoryBreakdown> items;
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
    final totalPoints = items.fold<int>(
      0,
      (sum, item) => sum + item.percentageBasisPoints,
    );
    if (totalPoints <= 0) {
      paint.color = AppColors.progressTrack;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
    } else {
      for (final item in items) {
        final sweep = (item.percentageBasisPoints / totalPoints) * 2 * math.pi;
        paint.color = FinanceCategoryColors.forCategoryId(item.categoryId);
        canvas.drawArc(rect, start, sweep, false, paint);
        start += sweep;
      }
    }

    canvas.drawCircle(center, radius - stroke, Paint()..color = holeColor);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.holeColor != holeColor;
  }
}
