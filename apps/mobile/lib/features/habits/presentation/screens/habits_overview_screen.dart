import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/habit_providers.dart';
import '../../domain/entities/habit_progress.dart';
import '../widgets/habit_list_tile.dart';

class HabitsOverviewScreen extends ConsumerWidget {
  const HabitsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(habitsOverviewProvider);
    final habitsAsync = ref.watch(filteredHabitsProvider);
    final filter = ref.watch(habitsFilterProvider);

    return MemyModuleScaffold(
      key: const Key('habits_overview'),
      title: 'Habits',
      fillBody: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.sm,
      ),
      trailing: MemyIconPlain(
        key: const Key('habits_add_button'),
        icon: Icons.add_rounded,
        onPressed: () => context.push(RoutePaths.addHabit),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          overviewAsync.when(
            loading: () => const LoadingCardSkeleton(height: 88, lines: 2),
            error: (error, _) => InlineErrorCard(
              key: const Key('habits_error'),
              message: userFacingErrorMessage(error),
              onRetry: () async {
                await ref.read(habitRepositoryProvider).refresh();
                ref.invalidate(habitsListProvider);
                ref.invalidate(habitCheckInsProvider);
              },
              retryButtonKey: const Key('habits_retry'),
            ),
            data: (overview) => _OverviewSummaryCard(overview: overview),
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterChips(
            filter: filter,
            onChanged: (value) =>
                ref.read(habitsFilterProvider.notifier).state = value,
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: habitsAsync.when(
              loading: () => ListView(
                key: const Key('habits_loading'),
                children: [
                  LoadingCardSkeleton(height: 88, lines: 2),
                  SizedBox(height: AppSpacing.md),
                  LoadingCardSkeleton(height: 88, lines: 2),
                ],
              ),
              error: (error, _) => InlineErrorCard(
                key: const Key('habits_error'),
                message: userFacingErrorMessage(error),
                onRetry: () async {
                  await ref.read(habitRepositoryProvider).refresh();
                  ref.invalidate(habitsListProvider);
                  ref.invalidate(habitCheckInsProvider);
                },
                retryButtonKey: const Key('habits_retry'),
              ),
              data: (habits) {
                if (habits.isEmpty) {
                  return ListView(
                    children: [
                      EmptyFeatureCard(
                        key: const Key('habits_empty'),
                        title: 'Habits',
                        message: filter == HabitsListFilter.active
                            ? 'No active habits yet. Tap + to create one.'
                            : 'No ${filter.name} habits.',
                        icon: Icons.loop_rounded,
                        actionLabel: filter == HabitsListFilter.active
                            ? 'Add habit'
                            : null,
                        onAction: filter == HabitsListFilter.active
                            ? () => context.push(RoutePaths.addHabit)
                            : null,
                      ),
                      if (filter == HabitsListFilter.active) ...[
                        const SizedBox(height: AppSpacing.lg),
                        MemyPrimaryButton(
                          label: 'Add habit',
                          onPressed: () => context.push(RoutePaths.addHabit),
                        ),
                      ],
                    ],
                  );
                }

                final todayById = overviewAsync.valueOrNull?.items ?? const [];
                final todayMap = {
                  for (final item in todayById) item.habit.id: item,
                };

                return RefreshIndicator(
                  onRefresh: () => ref.read(habitRepositoryProvider).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    itemCount: habits.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return HabitListTile(
                        habit: habit,
                        todayItem: todayMap[habit.id],
                        onOpen: () =>
                            context.push(RoutePaths.habitDetailPath(habit.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewSummaryCard extends StatelessWidget {
  const _OverviewSummaryCard({required this.overview});

  final HabitsOverviewSummary overview;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today', style: AppTextStyles.kicker()),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${overview.completedToday}',
                        style: AppTextStyles.mono(fontSize: 40),
                      ),
                      TextSpan(
                        text: ' / ${overview.scheduledToday}',
                        style: AppTextStyles.titleMedium(
                          color: AppColors.faintText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'completed · ${overview.week.completionPercent}% this week',
                  style: AppTextStyles.bodySmall(),
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
            child: const Icon(
              Icons.loop_rounded,
              color: AppColors.habits,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.onChanged});

  final HabitsListFilter filter;
  final ValueChanged<HabitsListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.canvasDeep,
        borderRadius: AppRadii.pillRadius,
      ),
      child: Row(
        children: [
          for (final value in HabitsListFilter.values)
            Expanded(
              child: _FilterPill(
                key: Key('habits_filter_${value.name}'),
                label: _label(value),
                selected: filter == value,
                onTap: () => onChanged(value),
              ),
            ),
        ],
      ),
    );
  }

  String _label(HabitsListFilter filter) => switch (filter) {
    HabitsListFilter.active => 'Active',
    HabitsListFilter.paused => 'Paused',
    HabitsListFilter.archived => 'Archived',
  };
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
