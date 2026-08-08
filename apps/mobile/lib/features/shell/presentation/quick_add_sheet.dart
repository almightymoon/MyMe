import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/quick_add_destinations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

Future<void> showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const QuickAddSheet(),
  );
}

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  void _go(BuildContext context, String actionKey) {
    Navigator.of(context).pop();
    context.push(QuickAddDestinations.pathFor(actionKey));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.canvasDeep,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(AppStrings.quickAdd, style: AppTextStyles.titleLarge()),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create something for your day',
                style: AppTextStyles.bodySmall(),
              ),
              const SizedBox(height: AppSpacing.lg),
              _QuickAddTile(
                key: const Key('quick_add_goal'),
                icon: Icons.flag_rounded,
                color: AppColors.career,
                title: AppStrings.addGoal,
                onTap: () => _go(context, 'quick_add_goal'),
              ),
              _QuickAddTile(
                key: const Key('quick_add_transaction'),
                icon: Icons.payments_outlined,
                color: AppColors.finance,
                title: AppStrings.addTransaction,
                onTap: () => _go(context, 'quick_add_transaction'),
              ),
              _QuickAddTile(
                key: const Key('quick_add_event'),
                icon: Icons.event_outlined,
                color: AppColors.learning,
                title: AppStrings.addEvent,
                onTap: () => _go(context, 'quick_add_event'),
              ),
              _QuickAddTile(
                key: const Key('quick_add_habit'),
                icon: Icons.repeat_rounded,
                color: AppColors.habits,
                title: AppStrings.addHabit,
                onTap: () => _go(context, 'quick_add_habit'),
              ),
              _QuickAddTile(
                key: const Key('quick_add_meal'),
                icon: Icons.restaurant_outlined,
                color: AppColors.health,
                title: AppStrings.logMeal,
                onTap: () => _go(context, 'quick_add_meal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 14,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
        tileColor: AppColors.canvas,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: AppRadii.controlRadius,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTextStyles.titleSmall()),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
