import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../../../core/widgets/progress_card.dart';
import '../../application/providers/goal_providers.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/services/money_format.dart';

class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(goalsFilterProvider);
    final goalsAsync = ref.watch(filteredGoalsProvider);
    final avgProgress = ref.watch(averageActiveProgressProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MemyPageHeader(
              title: 'Goals',
              subtitle: 'Outcomes you are working toward',
              trailing: IconButton(
                key: const Key('goals_add_button'),
                tooltip: AppStrings.addGoal,
                onPressed: () => context.push(RoutePaths.addGoal),
                icon: const Icon(Icons.add_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: MemyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average active progress',
                      style: AppTextStyles.labelMedium(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${avgProgress.round()}%',
                      style: AppTextStyles.mono(fontSize: 28),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                children: [
                  for (final value in GoalsListFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: Key('goals_filter_${value.name}'),
                        label: Text(_filterLabel(value)),
                        selected: filter == value,
                        onSelected: (_) {
                          ref.read(goalsFilterProvider.notifier).state = value;
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: goalsAsync.when(
                loading: () => ListView(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  children: const [
                    LoadingCardSkeleton(height: 100, lines: 2),
                    SizedBox(height: AppSpacing.md),
                    LoadingCardSkeleton(height: 100, lines: 2),
                  ],
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: InlineErrorCard(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(goalsProvider),
                  ),
                ),
                data: (goals) {
                  if (goals.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      children: [
                        EmptyFeatureCard(
                          key: const Key('goals_empty'),
                          title: 'Goals',
                          message: filter == GoalsListFilter.all
                              ? 'No goals yet. Create one from Quick Add or the + button.'
                              : 'No ${_filterLabel(filter).toLowerCase()} goals.',
                          icon: Icons.flag_outlined,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        MemyPrimaryButton(
                          label: AppStrings.addGoal,
                          onPressed: () => context.push(RoutePaths.addGoal),
                        ),
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(goalsProvider);
                      await ref.read(goalsProvider.future);
                    },
                    child: ListView.separated(
                      key: const Key('goals_list'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.xxxl,
                      ),
                      itemCount: goals.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        return _GoalListTile(
                          goal: goal,
                          onOpen: () =>
                              context.push(RoutePaths.goalDetailPath(goal.id)),
                          onArchive: goal.status == GoalStatus.archived
                              ? null
                              : () => _archive(context, ref, goal),
                          onDelete: () => _confirmDelete(context, ref, goal),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _filterLabel(GoalsListFilter filter) => switch (filter) {
    GoalsListFilter.all => 'All',
    GoalsListFilter.active => 'Active',
    GoalsListFilter.completed => 'Completed',
    GoalsListFilter.archived => 'Archived',
  };

  Future<void> _archive(BuildContext context, WidgetRef ref, Goal goal) async {
    await ref.read(goalRepositoryProvider).archiveGoal(goal.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Archived “${goal.name}”')));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text(
          '“${goal.name}” will be permanently removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
    if (confirmed != true) return;

    final repo = ref.read(goalRepositoryProvider);
    await repo.deleteGoal(goal.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted “${goal.name}”'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            repo.createGoal(goal);
          },
        ),
      ),
    );
  }
}

class _GoalListTile extends StatelessWidget {
  const _GoalListTile({
    required this.goal,
    required this.onOpen,
    required this.onDelete,
    this.onArchive,
  });

  final Goal goal;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final deadline = DateFormat.yMMMd().format(goal.deadline);
    final amount = goal.targetAmountMinor == null || goal.currencyCode == null
        ? goal.displayCategory
        : MoneyFormat.formatMinor(
            goal.currentAmountMinor ?? 0,
            goal.currencyCode!,
          );

    return ProgressCard(
      key: Key('goal_tile_${goal.id}'),
      title: '${goal.priority.label} · ${goal.status.label}',
      headline: goal.name,
      progressPercent: goal.progressPercent,
      detail: '$amount · due $deadline',
      onTap: onOpen,
      trailing: PopupMenuButton<String>(
        key: Key('goal_menu_${goal.id}'),
        onSelected: (value) {
          if (value == 'archive') onArchive?.call();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (context) => [
          if (onArchive != null)
            const PopupMenuItem(value: 'archive', child: Text('Archive')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
