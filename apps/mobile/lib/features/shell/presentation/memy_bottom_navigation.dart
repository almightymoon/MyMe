import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class MemyBottomNavigation extends StatelessWidget {
  const MemyBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onQuickAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onQuickAddPressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: AppColors.surface.withValues(alpha: 0.94),
      elevation: 8,
      shadowColor: const Color(0x1A1A1712),
      child: SizedBox(
        height: 72 + bottomInset,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  key: const Key('nav_today'),
                  icon: Icons.wb_sunny_outlined,
                  selectedIcon: Icons.wb_sunny_rounded,
                  label: AppStrings.today,
                  selected: currentIndex == 0,
                  onTap: () => onDestinationSelected(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  key: const Key('nav_plan'),
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: AppStrings.plan,
                  selected: currentIndex == 1,
                  onTap: () => onDestinationSelected(1),
                ),
              ),
              SizedBox(
                width: 72,
                child: Center(
                  child: _QuickAddButton(
                    key: const Key('nav_quick_add'),
                    onPressed: onQuickAddPressed,
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  key: const Key('nav_coach'),
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: AppStrings.coach,
                  selected: currentIndex == 2,
                  onTap: () => onDestinationSelected(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  key: const Key('nav_more'),
                  icon: Icons.more_horiz_rounded,
                  selectedIcon: Icons.more_horiz_rounded,
                  label: AppStrings.more,
                  selected: currentIndex == 3,
                  onTap: () => onDestinationSelected(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ember : AppColors.secondaryText;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: AppSpacing.minTouch + 8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.navLabel(color: color)),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppStrings.quickAdd,
      child: Material(
        color: AppColors.ember,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: AppColors.ember.withValues(alpha: 0.45),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
