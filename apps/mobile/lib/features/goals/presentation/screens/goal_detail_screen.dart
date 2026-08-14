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
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/section_header.dart';
import '../../application/providers/goal_providers.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_forecast.dart';
import '../../domain/entities/goal_milestone.dart';
import '../../domain/services/money_format.dart';
import '../../domain/value_objects/money_minor.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalByIdProvider(goalId));
    final forecast = ref.watch(goalForecastProvider(goalId));

    return Scaffold(
      body: SafeArea(
        child: goalAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.page),
            child: LoadingCardSkeleton(height: 160, lines: 4),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: InlineErrorCard(
              message: userFacingErrorMessage(error),
              onRetry: () => ref.invalidate(goalByIdProvider(goalId)),
            ),
          ),
          data: (goal) {
            if (goal == null) {
              return Column(
                children: [
                  MemyPageHeader(
                    title: 'Goal',
                    leading: IconButton(
                      tooltip: 'Back',
                      onPressed: () =>
                          memyBack(context, fallback: RoutePaths.goals),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.page),
                    child: Text('This goal was deleted or is unavailable.'),
                  ),
                ],
              );
            }

            return Column(
              children: [
                MemyPageHeader(
                  title: goal.name,
                  subtitle: '${goal.displayCategory} · ${goal.status.label}',
                  leading: IconButton(
                    key: const Key('goal_detail_back'),
                    tooltip: 'Back',
                    onPressed: () =>
                        memyBack(context, fallback: RoutePaths.goals),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  trailing: PopupMenuButton<String>(
                    key: const Key('goal_detail_menu'),
                    onSelected: (value) async {
                      final repo = ref.read(goalRepositoryProvider);
                      try {
                        if (value == 'archive') {
                          await repo.archiveGoal(goal.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Goal archived')),
                            );
                          }
                        } else if (value == 'delete') {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete goal?'),
                              content: Text('Delete “${goal.name}”?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  key: const Key('confirm_delete_goal'),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await repo.deleteGoal(goal.id);
                            if (context.mounted) {
                              context.go(RoutePaths.goals);
                            }
                          }
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(userFacingErrorMessage(error)),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      if (goal.status != GoalStatus.archived)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Text('Archive'),
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
                    key: const Key('goal_detail_scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.xxxl,
                    ),
                    children: [
                      _ProgressHero(goal: goal),
                      const SizedBox(height: AppSpacing.md),
                      if (forecast != null) ...[
                        _ForecastCard(forecast: forecast, goal: goal),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _MetaCard(goal: goal),
                      const SizedBox(height: AppSpacing.md),
                      _MilestonesCard(goal: goal),
                      if (goal.notes.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        MemyCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Notes'),
                              Text(
                                goal.notes,
                                style: AppTextStyles.bodyMedium(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _UpdateProgressCard(goal: goal),
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
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: (goal.progressPercent.clamp(0, 100)) / 100,
                  strokeWidth: 8,
                  backgroundColor: AppColors.canvasDeep,
                  color: AppColors.ember,
                ),
                Center(
                  child: Text(
                    '${goal.progressPercent.round()}%',
                    style: AppTextStyles.titleSmall(),
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
                Text(goal.priority.label, style: AppTextStyles.kicker()),
                const SizedBox(height: 4),
                Text(goal.status.label, style: AppTextStyles.titleMedium()),
                const SizedBox(height: 4),
                Text(
                  'Due ${DateFormat.yMMMd().format(goal.deadline)}',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.forecast, required this.goal});

  final GoalForecast forecast;
  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final currency = goal.currencyCode ?? MoneyFormat.defaultCurrencyCode;
    return MemyCard(
      key: const Key('goal_forecast_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Forecast',
            subtitle: _statusLabel(forecast.status),
          ),
          Text(forecast.message, style: AppTextStyles.bodyMedium()),
          const SizedBox(height: AppSpacing.md),
          if (forecast.remainingAmountMinor != null)
            _kv(
              'Remaining',
              MoneyFormat.formatMinor(forecast.remainingAmountMinor!, currency),
            ),
          if (forecast.daysRemaining != null)
            _kv('Days remaining', '${forecast.daysRemaining}'),
          if (forecast.estimatedMonthsRemaining != null)
            _kv('Est. months', '${forecast.estimatedMonthsRemaining}'),
          if (forecast.requiredMonthlyContributionMinor != null)
            _kv(
              'Required monthly',
              MoneyFormat.formatMinor(
                forecast.requiredMonthlyContributionMinor!,
                currency,
              ),
            ),
          if (forecast.requiredWeeklyContributionMinor != null)
            _kv(
              'Required weekly',
              MoneyFormat.formatMinor(
                forecast.requiredWeeklyContributionMinor!,
                currency,
              ),
            ),
          if (forecast.projectedCompletionDate != null)
            _kv(
              'Projected completion',
              DateFormat.yMMMd().format(forecast.projectedCompletionDate!),
            ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySmall())),
          Text(value, style: AppTextStyles.mono(fontSize: 14)),
        ],
      ),
    );
  }

  String _statusLabel(GoalForecastStatus status) => switch (status) {
    GoalForecastStatus.onTrack => 'On track',
    GoalForecastStatus.atRisk => 'At risk',
    GoalForecastStatus.overdue => 'Overdue',
    GoalForecastStatus.completed => 'Completed',
    GoalForecastStatus.insufficientData => 'Insufficient data',
  };
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final currency = goal.currencyCode;
    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Details'),
          if (goal.description.trim().isNotEmpty) ...[
            Text(goal.description, style: AppTextStyles.bodyMedium()),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            'Category · ${goal.displayCategory}',
            style: AppTextStyles.bodySmall(),
          ),
          if (goal.targetAmountMinor != null && currency != null) ...[
            const SizedBox(height: 6),
            Text(
              '${MoneyFormat.formatMinor(goal.currentAmountMinor ?? MoneyMinor.zero, currency)}'
              ' of ${MoneyFormat.formatMinor(goal.targetAmountMinor!, currency)}',
              style: AppTextStyles.mono(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class _MilestonesCard extends ConsumerStatefulWidget {
  const _MilestonesCard({required this.goal});

  final Goal goal;

  @override
  ConsumerState<_MilestonesCard> createState() => _MilestonesCardState();
}

class _MilestonesCardState extends ConsumerState<_MilestonesCard> {
  bool _busy = false;

  Future<void> _runMutation(Future<void> Function() action) async {
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

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Milestones',
            trailing: TextButton(
              key: const Key('add_milestone_button'),
              onPressed: _busy ? null : () => _addMilestone(context),
              child: const Text('Add'),
            ),
          ),
          if (goal.milestones.isEmpty)
            Text('No milestones yet.', style: AppTextStyles.bodyMedium())
          else
            for (final milestone in goal.milestones)
              Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  key: Key('milestone_${milestone.id}'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: milestone.isCompleted,
                  title: Text(
                    milestone.title,
                    style: AppTextStyles.titleSmall(),
                  ),
                  subtitle: milestone.description == null
                      ? null
                      : Text(milestone.description!),
                  secondary: IconButton(
                    tooltip: 'Delete milestone',
                    onPressed: _busy
                        ? null
                        : () => _runMutation(
                            () => ref
                                .read(goalRepositoryProvider)
                                .deleteMilestone(goal.id, milestone.id),
                          ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  onChanged: _busy
                      ? null
                      : (value) => _runMutation(
                          () => ref
                              .read(goalRepositoryProvider)
                              .setMilestoneCompletion(
                                goalId: goal.id,
                                milestoneId: milestone.id,
                                isCompleted: value ?? false,
                              ),
                        ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _addMilestone(BuildContext context) async {
    final titleController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add milestone'),
        content: TextField(
          key: const Key('new_milestone_title'),
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_add_milestone'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    final title = titleController.text.trim();
    titleController.dispose();
    if (ok != true || title.isEmpty) return;

    final goal = widget.goal;
    final id = ref.read(uuidProvider).v4();
    await _runMutation(
      () => ref
          .read(goalRepositoryProvider)
          .addMilestone(
            goal.id,
            GoalMilestone(
              id: id,
              goalId: goal.id,
              title: title,
              order: goal.milestones.length,
            ),
          ),
    );
  }
}

class _UpdateProgressCard extends ConsumerStatefulWidget {
  const _UpdateProgressCard({required this.goal});

  final Goal goal;

  @override
  ConsumerState<_UpdateProgressCard> createState() =>
      _UpdateProgressCardState();
}

class _UpdateProgressCardState extends ConsumerState<_UpdateProgressCard> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: MoneyFormat.majorStringFromMinor(widget.goal.currentAmountMinor),
    );
  }

  @override
  void didUpdateWidget(covariant _UpdateProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goal.currentAmountMinor != widget.goal.currentAmountMinor) {
      _controller.text = MoneyFormat.majorStringFromMinor(
        widget.goal.currentAmountMinor,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final minor = MoneyFormat.parseMajorToMinor(_controller.text);
      if (minor == null) return;
      await ref
          .read(goalRepositoryProvider)
          .updateGoalProgress(
            goalId: widget.goal.id,
            currentAmountMinor: minor,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Progress updated')));
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.goal.targetAmountMinor == null) {
      return const SizedBox.shrink();
    }

    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Update progress'),
          TextField(
            key: const Key('update_current_amount_field'),
            controller: _controller,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText:
                  'Current amount (${widget.goal.currencyCode ?? 'PKR'})',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            key: const Key('save_progress_button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ember,
              minimumSize: const Size.fromHeight(48),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadii.controlRadius,
              ),
            ),
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save progress'),
          ),
        ],
      ),
    );
  }
}
