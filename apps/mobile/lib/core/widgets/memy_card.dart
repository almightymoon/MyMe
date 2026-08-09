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

    // Color + shadow share one rounded decoration. Content is ClipRRect so
    // nested InkWell highlights cannot paint square corners past the radius.
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
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
      ),
    );

    if (margin == EdgeInsets.zero) return card;
    return Padding(padding: margin, child: card);
  }
}
