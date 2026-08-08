import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

class MemyCard extends StatelessWidget {
  const MemyCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.color = AppColors.surface,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Padding(
      padding: margin,
      child: Material(
        color: color,
        borderRadius: AppRadii.cardRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.cardRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.cardRadius,
              boxShadow: AppColors.softShadow,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
