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
    final radius = AppRadii.cardRadius;

    // Color + shadow must share one rounded BoxDecoration. Splitting shadow onto
    // a separate layer (or putting it on Ink inside Material) paints a square
    // dark bbox that peeks past the rounded white corners.
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: onTap == null ? Colors.transparent : null,
          highlightColor: onTap == null ? Colors.transparent : null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (margin == EdgeInsets.zero) return card;
    return Padding(padding: margin, child: card);
  }
}
