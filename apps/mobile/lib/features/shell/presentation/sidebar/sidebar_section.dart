import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../trust/domain/entities/sidebar_destination.dart';
import 'sidebar_destinations.dart';
import 'sidebar_navigation_tile.dart';

/// Labeled group of sidebar destinations.
class SidebarSection extends StatelessWidget {
  const SidebarSection({
    super.key,
    required this.sectionId,
    required this.destinations,
    required this.isActive,
    required this.onDestinationSelected,
  });

  final SidebarSectionId sectionId;
  final List<SidebarDestination> destinations;
  final bool Function(SidebarDestination destination) isActive;
  final ValueChanged<SidebarDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, AppSpacing.sm, 12, 4),
          child: Text(
            SidebarDestinations.titleFor(sectionId).toUpperCase(),
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.faintText,
            ),
          ),
        ),
        ...destinations.map(
          (destination) => SidebarNavigationTile(
            destination: destination,
            active: isActive(destination),
            onTap: () => onDestinationSelected(destination),
          ),
        ),
      ],
    );
  }
}
