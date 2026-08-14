import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/quick_add_destinations.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/release_capabilities.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/memy_primary_button.dart';
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
        decoration: BoxDecoration(
          borderRadius: sheetRadius,
          boxShadow: AppColors.liftShadow,
          gradient: RadialGradient(
            center: const Alignment(0.85, -0.85),
            radius: 1.15,
            colors: [
              AppColors.orangeSoft.withValues(alpha: 0.95),
              AppColors.canvas,
            ],
            stops: const [0.0, 0.62],
          ),
        ),
        child: Material(
          color: Colors.transparent,
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
          color: AppColors.sheetHandle,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }

  Widget _buildMenu() {
    final showMeal = ref.watch(releaseCapabilitiesProvider).nutritionQuickAdd;
    final tiles = <_QuickAddAction>[
      _QuickAddAction(
        keyName: 'quick_add_goal',
        icon: Icons.flag_rounded,
        accent: AppColors.career,
        title: 'Goal',
        subtitle: 'A target to chase',
        onTap: () => _go('quick_add_goal'),
      ),
      _QuickAddAction(
        keyName: 'quick_add_transaction',
        icon: Icons.payments_rounded,
        accent: AppColors.finance,
        title: 'Money',
        subtitle: 'Income or expense',
        onTap: () => _go('quick_add_transaction'),
      ),
      _QuickAddAction(
        keyName: 'quick_add_event',
        icon: Icons.event_rounded,
        accent: AppColors.learning,
        title: 'Event',
        subtitle: 'On your calendar',
        onTap: () => _go('quick_add_event'),
      ),
      _QuickAddAction(
        keyName: 'quick_add_habit',
        icon: Icons.local_fire_department_rounded,
        accent: AppColors.habits,
        title: 'Habit',
        subtitle: 'Keep a streak',
        onTap: () => _go('quick_add_habit'),
      ),
      if (showMeal)
        _QuickAddAction(
          keyName: 'quick_add_meal',
          icon: Icons.restaurant_rounded,
          accent: AppColors.health,
          title: 'Meal',
          subtitle: 'Food & calories',
          onTap: () => _go('quick_add_meal'),
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHandle(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Capture',
                style: AppTextStyles.bodySmall().copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ember,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.quickAdd,
                style: AppTextStyles.displayMedium().copyWith(fontSize: 26),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _FeaturedTaskCard(onTap: _openTaskForm),
        const SizedBox(height: 10),
        _ActionGrid(actions: tiles),
      ],
    );
  }

  Widget _buildTaskForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHandle(),
        const SizedBox(height: 8),
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
                style: AppTextStyles.displayMedium().copyWith(fontSize: 22),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 4, 14),
          child: Text(
            'Pins to Today’s Tasks on Home',
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
            fillColor: AppColors.surface,
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
        const SizedBox(height: 14),
        MemyPrimaryButton(
          key: const Key('quick_add_task_submit'),
          label: 'Add to Today',
          onPressed: _submitTask,
        ),
      ],
    );
  }
}

class _QuickAddAction {
  const _QuickAddAction({
    required this.keyName,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _FeaturedTaskCard extends StatelessWidget {
  const _FeaturedTaskCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const Key('quick_add_task'),
          onTap: onTap,
          borderRadius: AppRadii.cardRadius,
          splashColor: AppColors.ember.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.ember,
                    borderRadius: AppRadii.chipRadius,
                    boxShadow: AppColors.orangeGlow,
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.addDailyTask,
                        style: AppTextStyles.titleMedium().copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pin a checklist item on Home',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.faintText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.add_rounded, color: AppColors.ember, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<_QuickAddAction> actions;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < actions.length; i += 2) {
      final left = actions[i];
      final hasRight = i + 1 < actions.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < actions.length ? 10 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _QuickAddTile(action: left)),
              const SizedBox(width: 10),
              Expanded(
                child: hasRight
                    ? _QuickAddTile(action: actions[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({required this.action});

  final _QuickAddAction action;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: Key(action.keyName),
          onTap: action.onTap,
          borderRadius: AppRadii.panelRadius,
          splashColor: action.accent.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: action.accent.withValues(alpha: 0.14),
                    borderRadius: AppRadii.thumbRadius,
                  ),
                  child: Icon(action.icon, size: 20, color: action.accent),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  action.title,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action.subtitle,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
