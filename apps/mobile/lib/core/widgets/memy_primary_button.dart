import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class MemyPrimaryButton extends StatelessWidget {
  const MemyPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadii.pillRadius,
        boxShadow: onPressed == null ? null : AppColors.orangeGlow,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.canvasDeep,
          disabledForegroundColor: AppColors.faintText,
          minimumSize: Size(
            expanded ? double.infinity : 48,
            AppSpacing.minTouch,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: Colors.white,
          ).copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
