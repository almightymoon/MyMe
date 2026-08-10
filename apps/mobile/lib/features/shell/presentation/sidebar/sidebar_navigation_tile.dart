import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../trust/domain/entities/sidebar_destination.dart';

/// Single tappable row in the MeMy sidebar drawer.
class SidebarNavigationTile extends StatelessWidget {
  const SidebarNavigationTile({
    super.key,
    required this.destination,
    required this.onTap,
    this.active = false,
  });

  final SidebarDestination destination;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ember : AppColors.primaryText;
    final showPlanned = destination.isPlanned || destination.badgeLabel != null;

    return Semantics(
      button: true,
      selected: active,
      label: destination.semanticLabel,
      child: Material(
        color: active ? AppColors.orangeSoft : Colors.transparent,
        borderRadius: AppRadii.chipRadius,
        child: InkWell(
          key: Key(destination.keyName),
          borderRadius: AppRadii.chipRadius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    destination.icon,
                    size: 20,
                    color: active ? AppColors.ember : AppColors.secondaryText,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      destination.label,
                      style: AppTextStyles.bodyMedium().copyWith(
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                  if (showPlanned) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.canvasDeep,
                        borderRadius: AppRadii.pillRadius,
                      ),
                      child: Text(
                        destination.badgeLabel ?? 'Planned',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.faintText,
                        ),
                      ),
                    ),
                  ],
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Color(0xFFC7C7CC),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
