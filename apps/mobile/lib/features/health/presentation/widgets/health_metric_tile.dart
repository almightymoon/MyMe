import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_text_styles.dart';

/// One metric readout — Steps, Heart rate, Sleep, etc.
///
/// Shows a real value when available, or an explicit "not connected"/
/// "no data" state instead of a misleading zero/placeholder number.
class HealthMetricTile extends StatelessWidget {
  const HealthMetricTile({
    super.key,
    required this.label,
    this.value,
    this.unit,
    this.icon,
    this.isPermitted = true,
  });

  final String label;

  /// Null when there is no reading to show (see [isPermitted]).
  final String? value;
  final String? unit;
  final IconData? icon;

  /// False when this metric's permission group was never granted — shows
  /// "Not connected" instead of "No data" so the user knows *why*.
  final bool isPermitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.ember),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall().copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (value != null)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.mono(fontSize: 24),
                  ),
                  if (unit != null && unit!.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: AppTextStyles.bodySmall().copyWith(fontSize: 13),
                    ),
                ],
              ),
            )
          else
            Text(
              isPermitted ? 'No data' : 'Not connected',
              style: AppTextStyles.bodySmall().copyWith(
                fontSize: 13,
                color: AppColors.faintText,
              ),
            ),
        ],
      ),
    );
  }
}
