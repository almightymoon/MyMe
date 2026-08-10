import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../application/providers/habit_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_check_in.dart';
import '../../domain/entities/habit_enums.dart';
import '../../domain/entities/habit_progress.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  var _busy = false;

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

  Future<void> _confirmDelete(Habit habit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text(
          '“${habit.name}” and its check-ins will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_habit'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() async {
      await ref.read(habitRepositoryProvider).deleteHabit(habit.id);
      if (mounted) context.go(RoutePaths.habits);
    });
  }

  Future<void> _toggleToday(Habit habit, HabitTodayItem today) async {
    final repo = ref.read(habitRepositoryProvider);
    await _run(() async {
      if (today.isCompleted && habit.goalType == HabitGoalType.binary) {
        await repo.removeCheckIn(habitId: habit.id, localDate: today.date);
      } else if (habit.goalType == HabitGoalType.binary) {
        await repo.upsertCheckIn(
          HabitCheckInDraft(habitId: habit.id, localDate: today.date, value: 1),
        );
      } else {
        final step = habit.goalType == HabitGoalType.duration ? 5 : 1;
        await repo.upsertCheckIn(
          HabitCheckInDraft(
            habitId: habit.id,
            localDate: today.date,
            value: today.value + step,
          ),
        );
      }
    });
  }

  Future<void> _removeToday(Habit habit, LocalDate date) async {
    await _run(
      () => ref
          .read(habitRepositoryProvider)
          .removeCheckIn(habitId: habit.id, localDate: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitAsync = ref.watch(habitByIdProvider(widget.habitId));
    final progressAsync = ref.watch(habitProgressByIdProvider(widget.habitId));
    final checkInsAsync = ref.watch(
      habitCheckInsForHabitProvider(widget.habitId),
    );

    return Scaffold(
      key: const Key('habit_detail'),
      body: SafeArea(
        child: habitAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.page),
            child: LoadingCardSkeleton(height: 160, lines: 4),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: InlineErrorCard(
              message: userFacingErrorMessage(error),
              onRetry: () => ref.invalidate(habitByIdProvider(widget.habitId)),
            ),
          ),
          data: (habit) {
            if (habit == null) {
              return Column(
                children: [
                  MemyPageHeader(
                    title: 'Habit',
                    leading: IconButton(
                      onPressed: () =>
                          memyBack(context, fallback: RoutePaths.habits),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.page),
                    child: Text('This habit was deleted or is unavailable.'),
                  ),
                ],
              );
            }

            return Column(
              children: [
                MemyPageHeader(
                  title: habit.name,
                  subtitle: '${habit.displayCategory} · ${habit.status.label}',
                  leading: IconButton(
                    key: const Key('habit_detail_back'),
                    tooltip: 'Back',
                    onPressed: () =>
                        memyBack(context, fallback: RoutePaths.habits),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  trailing: PopupMenuButton<String>(
                    key: const Key('habit_detail_menu'),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push(RoutePaths.editHabitPath(habit.id));
                        return;
                      }
                      if (value == 'delete') {
                        await _confirmDelete(habit);
                        return;
                      }
                      final repo = ref.read(habitRepositoryProvider);
                      await _run(() async {
                        switch (value) {
                          case 'pause':
                            await repo.pauseHabit(habit.id);
                          case 'resume':
                            await repo.resumeHabit(habit.id);
                          case 'archive':
                            await repo.archiveHabit(habit.id);
                          case 'restore':
                            await repo.restoreHabit(habit.id);
                          default:
                            break;
                        }
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (habit.status == HabitStatus.active)
                        const PopupMenuItem(
                          value: 'pause',
                          child: Text('Pause'),
                        ),
                      if (habit.status == HabitStatus.paused)
                        const PopupMenuItem(
                          value: 'resume',
                          child: Text('Resume'),
                        ),
                      if (habit.status != HabitStatus.archived)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Text('Archive'),
                        )
                      else
                        const PopupMenuItem(
                          value: 'restore',
                          child: Text('Restore'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.xxxl,
                    ),
                    children: [
                      progressAsync.when(
                        loading: () =>
                            const LoadingCardSkeleton(height: 120, lines: 3),
                        error: (error, _) => InlineErrorCard(
                          message: userFacingErrorMessage(error),
                          onRetry: () => ref.invalidate(
                            habitProgressByIdProvider(widget.habitId),
                          ),
                        ),
                        data: (progress) {
                          if (progress == null) {
                            return const SizedBox.shrink();
                          }
                          return _ProgressCard(progress: progress);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DetailsCard(habit: habit),
                      const SizedBox(height: AppSpacing.md),
                      progressAsync.maybeWhen(
                        data: (progress) {
                          if (progress == null ||
                              habit.status != HabitStatus.active) {
                            return const SizedBox.shrink();
                          }
                          return _TodayActionsCard(
                            habit: habit,
                            today: progress.today,
                            busy: _busy,
                            onCheckIn: () =>
                                _toggleToday(habit, progress.today),
                            onRemoveToday: () =>
                                _removeToday(habit, progress.today.date),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      checkInsAsync.when(
                        loading: () =>
                            const LoadingCardSkeleton(height: 100, lines: 2),
                        error: (error, _) => InlineErrorCard(
                          message: userFacingErrorMessage(error),
                          onRetry: () => ref.invalidate(
                            habitCheckInsForHabitProvider(widget.habitId),
                          ),
                        ),
                        data: (checkIns) => _RecentCheckInsCard(
                          checkIns: _recentCheckIns(checkIns),
                          habit: habit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<HabitCheckIn> _recentCheckIns(List<HabitCheckIn> all) {
    final sorted = [...all]..sort((a, b) => b.localDate.compareTo(a.localDate));
    return sorted.take(14).toList(growable: false);
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress});

  final HabitProgressSummary progress;

  @override
  Widget build(BuildContext context) {
    final today = progress.today;
    final streak = progress.streak;
    final week = progress.week;
    final pct = today.targetValue <= 0
        ? 0.0
        : (today.value / today.targetValue).clamp(0.0, 1.0);

    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Progress',
            subtitle: today.isScheduled
                ? 'Scheduled today'
                : 'Not scheduled today',
          ),
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 7,
                      backgroundColor: AppColors.canvasDeep,
                      color: AppColors.habits,
                    ),
                    Center(
                      child: Text(
                        '${(pct * 100).round()}%',
                        style: AppTextStyles.labelMedium(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current streak · ${streak.currentStreak}',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    Text(
                      'Best streak · ${streak.longestStreak}',
                      style: AppTextStyles.bodySmall(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This week · ${week.completedCount}/${week.scheduledCount} '
                      '(${week.completionPercent}%)',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Details'),
          if (habit.description?.trim().isNotEmpty == true) ...[
            Text(habit.description!, style: AppTextStyles.bodyMedium()),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            'Goal · ${habit.goalType.label}',
            style: AppTextStyles.bodySmall(),
          ),
          const SizedBox(height: 4),
          Text(
            'Target · ${habit.targetValue}${habit.unitLabel != null ? ' ${habit.unitLabel}' : ''}',
            style: AppTextStyles.bodySmall(),
          ),
          const SizedBox(height: 4),
          Text(
            'Frequency · ${habit.frequencyType.label}',
            style: AppTextStyles.bodySmall(),
          ),
          const SizedBox(height: 4),
          Text(
            'Started · ${DateFormat.yMMMd().format(habit.startDate.toDateTimeLocal())}',
            style: AppTextStyles.bodySmall(),
          ),
        ],
      ),
    );
  }
}

class _TodayActionsCard extends StatelessWidget {
  const _TodayActionsCard({
    required this.habit,
    required this.today,
    required this.busy,
    required this.onCheckIn,
    required this.onRemoveToday,
  });

  final Habit habit;
  final HabitTodayItem today;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onRemoveToday;

  @override
  Widget build(BuildContext context) {
    if (!today.isScheduled) {
      return MemyCard(
        child: Text(
          'Not scheduled for today.',
          style: AppTextStyles.bodyMedium(),
        ),
      );
    }

    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Today',
            subtitle: today.isCompleted ? 'Completed' : 'In progress',
          ),
          if (habit.goalType == HabitGoalType.binary)
            SwitchListTile(
              key: const Key('habit_detail_checkin_toggle'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Mark complete'),
              value: today.isCompleted,
              onChanged: busy ? null : (_) => onCheckIn(),
            )
          else ...[
            Text(
              '${today.value} / ${today.targetValue} '
              '${habit.unitLabel ?? (habit.goalType == HabitGoalType.duration ? 'min' : '')}',
              style: AppTextStyles.mono(fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              key: const Key('habit_detail_checkin_button'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ember,
                minimumSize: const Size.fromHeight(44),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.controlRadius,
                ),
              ),
              onPressed: busy || today.isCompleted ? null : onCheckIn,
              icon: const Icon(Icons.add),
              label: Text(
                habit.goalType == HabitGoalType.duration
                    ? 'Add 5 minutes'
                    : 'Add 1',
              ),
            ),
          ],
          if (today.value > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              key: const Key('habit_detail_remove_today'),
              onPressed: busy ? null : onRemoveToday,
              child: const Text('Remove today\'s check-in'),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentCheckInsCard extends StatelessWidget {
  const _RecentCheckInsCard({required this.checkIns, required this.habit});

  final List<HabitCheckIn> checkIns;
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Recent check-ins'),
          if (checkIns.isEmpty)
            Text('No check-ins yet.', style: AppTextStyles.bodyMedium())
          else
            for (final checkIn in checkIns)
              ListTile(
                key: Key('habit_checkin_${checkIn.id}'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  checkIn.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: checkIn.isCompleted
                      ? AppColors.finance
                      : AppColors.faintText,
                ),
                title: Text(
                  DateFormat.yMMMd().format(
                    checkIn.localDate.toDateTimeLocal(),
                  ),
                  style: AppTextStyles.titleSmall(),
                ),
                subtitle: Text(_valueLabel(habit, checkIn.value)),
              ),
        ],
      ),
    );
  }

  String _valueLabel(Habit habit, int value) {
    return switch (habit.goalType) {
      HabitGoalType.binary => value >= 1 ? 'Complete' : 'Incomplete',
      HabitGoalType.count =>
        '$value${habit.unitLabel != null ? ' ${habit.unitLabel}' : ''}',
      HabitGoalType.duration => '$value min',
    };
  }
}
