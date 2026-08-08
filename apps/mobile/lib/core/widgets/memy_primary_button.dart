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
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ember,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.canvasDeep,
        minimumSize: Size(expanded ? double.infinity : 48, AppSpacing.minTouch),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.controlRadius,
        ),
      ),
      child: Text(label, style: AppTextStyles.labelLarge(color: Colors.white)),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
