import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/quick_add_destinations.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../today/application/providers/today_tasks_provider.dart';

Future<void> showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x47141210),
    builder: (context) => const QuickAddSheet(),
  );
}

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  bool _addingTask = false;
  final _taskController = TextEditingController();
  final _taskFocus = FocusNode();

  @override
  void dispose() {
    _taskController.dispose();
    _taskFocus.dispose();
    super.dispose();
  }

  void _go(String actionKey) {
    Navigator.of(context).pop();
    context.push(QuickAddDestinations.pathFor(actionKey));
  }

  void _openTaskForm() {
    HapticFeedback.selectionClick();
    setState(() => _addingTask = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _taskFocus.requestFocus();
    });
  }

  void _submitTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    ref.read(todayTasksProvider.notifier).add(title);
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    router.go(RoutePaths.today);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Added “$title” to Today’s Tasks'),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    const sheetRadius = BorderRadius.vertical(
      top: Radius.circular(AppRadii.card),
      bottom: Radius.circular(24),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10 + bottom + keyboard),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: sheetRadius,
          boxShadow: [
            BoxShadow(
              color: Color(0x2E14100C),
              blurRadius: 48,
              offset: Offset(0, 18),
            ),
            BoxShadow(
              color: Color(0x14FF6A1A),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: const Color(0xF0FFFFFF),
          borderRadius: sheetRadius,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _addingTask ? _buildTaskForm() : _buildMenu(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4E8),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHandle(),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppStrings.quickAdd,
            style: AppTextStyles.titleLarge().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _QuickAddRow(
          key: const Key('quick_add_task'),
          icon: Icons.checklist_rounded,
          accent: AppColors.ember,
          title: AppStrings.addDailyTask,
          subtitle: 'Checklist item for Home',
          onTap: _openTaskForm,
        ),
        _QuickAddRow(
          key: const Key('quick_add_goal'),
          icon: Icons.flag_rounded,
          accent: AppColors.career,
          title: 'Goal',
          subtitle: 'Create a new goal',
          onTap: () => _go('quick_add_goal'),
        ),
        _QuickAddRow(
          key: const Key('quick_add_transaction'),
          icon: Icons.payments_outlined,
          accent: AppColors.finance,
          title: 'Transaction',
          subtitle: 'Income or expense',
          onTap: () => _go('quick_add_transaction'),
        ),
        _QuickAddRow(
          key: const Key('quick_add_event'),
          icon: Icons.event_outlined,
          accent: AppColors.learning,
          title: 'Calendar Event',
          subtitle: 'Schedule something',
          onTap: () => _go('quick_add_event'),
        ),
        _QuickAddRow(
          key: const Key('quick_add_habit'),
          icon: Icons.repeat_rounded,
          accent: AppColors.habits,
          title: 'Habit',
          subtitle: 'Build a daily streak',
          onTap: () => _go('quick_add_habit'),
        ),
        _QuickAddRow(
          key: const Key('quick_add_meal'),
          icon: Icons.restaurant_outlined,
          accent: AppColors.health,
          title: 'Meal',
          subtitle: 'Log food & calories',
          onTap: () => _go('quick_add_meal'),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTaskForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHandle(),
        const SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              key: const Key('quick_add_task_back'),
              onPressed: () {
                setState(() {
                  _addingTask = false;
                  _taskController.clear();
                });
              },
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.primaryText,
            ),
            Expanded(
              child: Text(
                AppStrings.addDailyTask,
                style: AppTextStyles.titleLarge().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            'Added to Today’s Tasks on Home',
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          ),
        ),
        TextField(
          key: const Key('quick_add_task_field'),
          controller: _taskController,
          focusNode: _taskFocus,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _submitTask(),
          decoration: InputDecoration(
            hintText: 'e.g. Pack gym bag',
            filled: true,
            fillColor: AppColors.canvas,
            border: OutlineInputBorder(
              borderRadius: AppRadii.controlRadius,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('quick_add_task_submit'),
          onPressed: _submitTask,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ember,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
          ),
          child: const Text('Add to Today'),
        ),
      ],
    );
  }
}

class _QuickAddRow extends StatelessWidget {
  const _QuickAddRow({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.controlRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.controlRadius,
          splashColor: AppColors.ember.withValues(alpha: 0.10),
          highlightColor: AppColors.ember.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.chipRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        accent.withValues(alpha: 0.14),
                      ],
                    ),
                    border: Border.all(color: accent.withValues(alpha: 0.16)),
                  ),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFC7C7CC),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
