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
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_chrome.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../../shell/presentation/memy_bottom_navigation.dart';
import '../../../shell/presentation/memy_drawer.dart';
import '../../../shell/presentation/quick_add_sheet.dart';
import '../../application/providers/goal_providers.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/services/money_format.dart';
import '../../domain/value_objects/money_minor.dart';

class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(goalsFilterProvider);
    final goalsAsync = ref.watch(filteredGoalsProvider);
    final avgProgress = ref.watch(averageActiveProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      extendBody: true,
      endDrawer: const MemyDrawer(activeShellIndex: 1),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MemyPageHeader(
              title: 'My Goals',
              leading: IconButton(
                key: const Key('goals_back'),
                tooltip: AppStrings.back,
                onPressed: () => memyBack(context, fallback: RoutePaths.plan),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              trailing: MemyHeaderActions(
                showAvatar: false,
                menuKey: const Key('goals_open_drawer'),
                leading: [
                  MemyIconPlain(
                    key: const Key('goals_add_button'),
                    icon: Icons.add_rounded,
                    onPressed: () => context.push(RoutePaths.addGoal),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: MemyCard(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average progress',
                            style: AppTextStyles.kicker(),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${avgProgress.round()}',
                                  style: AppTextStyles.mono(fontSize: 40),
                                ),
                                TextSpan(
                                  text: '%',
                                  style: AppTextStyles.titleMedium(
                                    color: AppColors.faintText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.orangeSoft,
                        borderRadius: AppRadii.controlRadius,
                      ),
                      child: Icon(
                        Icons.flag_rounded,
                        color: AppColors.ember,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.canvasDeep,
                      borderRadius: AppRadii.pillRadius,
                    ),
                    child: Row(
                      children: [
                        for (final value in [
                          GoalsListFilter.all,
                          GoalsListFilter.active,
                          GoalsListFilter.completed,
                        ])
                          Expanded(
                            child: _FilterPill(
                              key: Key('goals_filter_${value.name}'),
                              label: _filterLabel(value),
                              selected: filter == value,
                              onTap: () {
                                ref.read(goalsFilterProvider.notifier).state =
                                    value;
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const Key('goals_filter_archived'),
                      onPressed: () {
                        ref.read(goalsFilterProvider.notifier).state =
                            GoalsListFilter.archived;
                      },
                      child: Text(
                        filter == GoalsListFilter.archived
                            ? 'Viewing archived'
                            : 'Archived',
                        style: AppTextStyles.labelSmall(
                          color: filter == GoalsListFilter.archived
                              ? AppColors.emberDark
                              : AppColors.faintText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                    message: userFacingErrorMessage(error),
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
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        8 + MemyBottomNavigation.contentBottomInset(context),
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
      bottomNavigationBar: MemyBottomNavigation(
        currentIndex: 1,
        onDestinationSelected: (index) => memyGoShellTab(context, index),
        onQuickAddPressed: () => showQuickAddSheet(context),
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
    try {
      await ref.read(goalRepositoryProvider).archiveGoal(goal.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Archived “${goal.name}”')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    }
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
    try {
      await repo.deleteGoal(goal.id);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted “${goal.name}”'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await repo.createGoal(goal);
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(userFacingErrorMessage(error))),
                );
              }
            },
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    }
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ember : Colors.transparent,
      borderRadius: AppRadii.pillRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium(
              color: selected ? Colors.white : AppColors.secondaryText,
            ),
          ),
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
            goal.currentAmountMinor ?? MoneyMinor.zero,
            goal.currencyCode!,
          );
    final pct = goal.progressPercent.clamp(0, 100);

    return MemyCard(
      key: Key('goal_tile_${goal.id}'),
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.orangeSoft,
              borderRadius: AppRadii.controlRadius,
            ),
            child: Text(
              goal.displayCategory.characters.first.toUpperCase(),
              style: AppTextStyles.titleMedium(color: AppColors.emberDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: AppTextStyles.titleSmall()),
                const SizedBox(height: 2),
                Text(
                  '$amount · due $deadline',
                  style: AppTextStyles.bodySmall(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.progressTrack,
                    color: AppColors.ember,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${pct.round()}%', style: AppTextStyles.titleSmall()),
          PopupMenuButton<String>(
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
        ],
      ),
    );
  }
}
