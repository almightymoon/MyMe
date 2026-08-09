import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'memy_card.dart';
import '../../app/theme/app_radii.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.color = AppColors.ember,
    this.onTap,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadii.chipRadius,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelMedium()),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.mono(fontSize: 20)),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(caption!, style: AppTextStyles.bodySmall()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
