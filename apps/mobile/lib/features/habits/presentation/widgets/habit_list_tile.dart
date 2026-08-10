import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../application/providers/habit_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_enums.dart';
import '../../domain/entities/habit_progress.dart';

class HabitListTile extends ConsumerStatefulWidget {
  const HabitListTile({
    super.key,
    required this.habit,
    this.todayItem,
    required this.onOpen,
  });

  final Habit habit;
  final HabitTodayItem? todayItem;
  final VoidCallback onOpen;

  @override
  ConsumerState<HabitListTile> createState() => _HabitListTileState();
}

class _HabitListTileState extends ConsumerState<HabitListTile> {
  var _busy = false;

  Color get _accentColor => switch (widget.habit.colorKey) {
    'health' => AppColors.health,
    'learning' => AppColors.learning,
    'habits' => AppColors.habits,
    'finance' => AppColors.finance,
    _ => AppColors.ember,
  };

  IconData get _icon => switch (widget.habit.iconKey) {
    'walk' => Icons.directions_walk_rounded,
    'book' => Icons.menu_book_rounded,
    'water' => Icons.water_drop_outlined,
    'fitness' => Icons.fitness_center_rounded,
    'mind' => Icons.self_improvement_rounded,
    _ => Icons.check_circle_outline,
  };

  String get _progressLabel {
    final item = widget.todayItem;
    if (item == null || !item.isScheduled) {
      return widget.habit.status.label;
    }
    if (widget.habit.goalType == HabitGoalType.binary) {
      return item.isCompleted ? 'Done today' : 'Not yet today';
    }
    final unit = widget.habit.unitLabel ?? 'units';
    return '${item.value}/${item.targetValue} $unit';
  }

  String get _semanticLabel {
    final streak = widget.todayItem?.currentStreak ?? 0;
    return '${widget.habit.name}, ${widget.habit.displayCategory}, '
        '$_progressLabel, streak $streak';
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleBinary() async {
    final item = widget.todayItem;
    if (item == null || !item.isScheduled) return;
    final repo = ref.read(habitRepositoryProvider);
    final date = item.date;
    await _run(() async {
      if (item.isCompleted) {
        await repo.removeCheckIn(habitId: widget.habit.id, localDate: date);
      } else {
        await repo.upsertCheckIn(
          HabitCheckInDraft(
            habitId: widget.habit.id,
            localDate: date,
            value: 1,
          ),
        );
      }
    });
  }

  Future<void> _increment() async {
    final item = widget.todayItem;
    if (item == null || !item.isScheduled) return;
    final step = widget.habit.goalType == HabitGoalType.duration ? 5 : 1;
    final next = item.value + step;
    await _run(
      () => ref
          .read(habitRepositoryProvider)
          .upsertCheckIn(
            HabitCheckInDraft(
              habitId: widget.habit.id,
              localDate: item.date,
              value: next,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final item = widget.todayItem;
    final scheduled = item?.isScheduled ?? false;
    final pct = item == null || item.targetValue <= 0
        ? 0.0
        : (item.value / item.targetValue).clamp(0.0, 1.0);

    return Semantics(
      label: _semanticLabel,
      button: true,
      child: MemyCard(
        key: Key('habit_tile_${habit.id}'),
        onTap: widget.onOpen,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: AppRadii.controlRadius,
              ),
              child: Icon(_icon, color: _accentColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.name, style: AppTextStyles.titleSmall()),
                  const SizedBox(height: 2),
                  Text(
                    '${habit.displayCategory} · ${habit.frequencyType.label}',
                    style: AppTextStyles.bodySmall(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (scheduled) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.progressTrack,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (habit.status == HabitStatus.active && scheduled)
              _CheckInControl(
                key: Key('habit_checkin_${habit.id}'),
                habit: habit,
                item: item!,
                busy: _busy,
                onToggleBinary: _toggleBinary,
                onIncrement: _increment,
              )
            else
              Text(
                habit.status.label,
                style: AppTextStyles.labelSmall(color: AppColors.faintText),
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckInControl extends StatelessWidget {
  const _CheckInControl({
    super.key,
    required this.habit,
    required this.item,
    required this.busy,
    required this.onToggleBinary,
    required this.onIncrement,
  });

  final Habit habit;
  final HabitTodayItem item;
  final bool busy;
  final VoidCallback onToggleBinary;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    if (habit.goalType == HabitGoalType.binary) {
      return Semantics(
        label: item.isCompleted
            ? 'Mark ${habit.name} incomplete'
            : 'Mark ${habit.name} complete',
        child: Switch(
          key: Key('habit_toggle_${habit.id}'),
          value: item.isCompleted,
          onChanged: busy ? null : (_) => onToggleBinary(),
          activeTrackColor: AppColors.ember.withValues(alpha: 0.4),
          activeThumbColor: AppColors.ember,
        ),
      );
    }

    return Semantics(
      label: 'Increment ${habit.name}',
      button: true,
      child: IconButton(
        key: Key('habit_increment_${habit.id}'),
        tooltip: 'Add progress',
        onPressed: busy || item.isCompleted ? null : onIncrement,
        icon: const Icon(Icons.add_circle_outline),
        color: AppColors.ember,
      ),
    );
  }
}
