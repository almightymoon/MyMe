import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/empty_feature_card.dart';
import '../../../core/widgets/inline_error_card.dart';
import '../../../core/widgets/loading_card_skeleton.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../calendar/application/providers/calendar_providers.dart';
import '../../calendar/domain/entities/schedule_item.dart';
import '../../goals/application/providers/goal_providers.dart';
import '../../goals/domain/entities/goal.dart';
import '../../goals/domain/entities/goal_summary.dart';
import '../../habits/application/providers/habit_providers.dart';
import '../../habits/domain/entities/habit_summary.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return SafeArea(
      child: ListView(
        key: const PageStorageKey('plan_scroll'),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          const MemyPageHeader(title: 'Plan', subtitle: 'Shape the week ahead'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PlanSummaryCard(
                  goalsAsync: goalsAsync,
                  habitsAsync: habitsAsync,
                  eventsAsync: eventsAsync,
                ),
                const SizedBox(height: AppSpacing.md),
                _GoalsPlanSection(
                  asyncValue: goalsAsync,
                  onRetry: () => ref.invalidate(goalsProvider),
                  onOpen: () => context.push(RoutePaths.goals),
                ),
                const SizedBox(height: AppSpacing.md),
                _HabitsPlanSection(
                  asyncValue: habitsAsync,
                  onRetry: () => ref.invalidate(habitsProvider),
                  onOpen: () => context.push(RoutePaths.habits),
                ),
                const SizedBox(height: AppSpacing.md),
                _CalendarPlanSection(
                  asyncValue: eventsAsync,
                  onRetry: () => ref.invalidate(upcomingEventsProvider),
                  onOpen: () => context.push(RoutePaths.calendar),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({
    required this.goalsAsync,
    required this.habitsAsync,
    required this.eventsAsync,
  });

  final AsyncValue<List<Goal>> goalsAsync;
  final AsyncValue<List<HabitSummary>> habitsAsync;
  final AsyncValue<List<ScheduleItem>> eventsAsync;

  @override
  Widget build(BuildContext context) {
    final goalsCount = goalsAsync.asData?.value.length;
    final habitsCount = habitsAsync.asData?.value.length;
    final eventsCount = eventsAsync.asData?.value.length;

    final summary = [
      if (goalsCount != null) '$goalsCount goals in focus',
      if (habitsCount != null) '$habitsCount habits tracked',
      if (eventsCount != null) '$eventsCount calendar events',
    ].join(' · ');

    return MemyCard(
      key: const Key('plan_summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly planning summary', style: AppTextStyles.titleSmall()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary.isEmpty
                ? 'Loading planning summary…'
                : '$summary. Demo summary only.',
            style: AppTextStyles.bodyMedium(),
          ),
        ],
      ),
    );
  }
}

class _GoalsPlanSection extends StatelessWidget {
  const _GoalsPlanSection({
    required this.asyncValue,
    required this.onRetry,
    required this.onOpen,
  });

  final AsyncValue<List<Goal>> asyncValue;
  final VoidCallback onRetry;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const LoadingCardSkeleton(
        key: Key('plan_goals_loading'),
        height: 120,
        lines: 3,
      ),
      error: (error, _) => InlineErrorCard(
        key: const Key('plan_goals_error'),
        title: 'Goals',
        message: userFacingErrorMessage(error),
        onRetry: onRetry,
      ),
      data: (goals) {
        if (goals.isEmpty) {
          return EmptyFeatureCard(
            key: const Key('plan_goals_empty'),
            title: 'Goals',
            message: AppStrings.sectionEmptyMessage,
            icon: Icons.flag_outlined,
            actionLabel: AppStrings.addGoal,
            onAction: () => context.push(RoutePaths.addGoal),
          );
        }

        return MemyCard(
          key: const Key('plan_goals_populated'),
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Goals',
                subtitle: 'Track outcomes and milestones',
              ),
              for (final goal in goals.take(3)) ...[
                Text(goal.name, style: AppTextStyles.titleSmall()),
                Text(
                  '${goal.progressPercent.round()}% · ${GoalSummary.fromGoal(goal).subtitle}',
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              _PlanLinkFooter(
                icon: Icons.flag_rounded,
                color: AppColors.career,
                label: 'Open Goals',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HabitsPlanSection extends StatelessWidget {
  const _HabitsPlanSection({
    required this.asyncValue,
    required this.onRetry,
    required this.onOpen,
  });

  final AsyncValue<List<HabitSummary>> asyncValue;
  final VoidCallback onRetry;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const LoadingCardSkeleton(
        key: Key('plan_habits_loading'),
        height: 120,
        lines: 3,
      ),
      error: (error, _) => InlineErrorCard(
        key: const Key('plan_habits_error'),
        title: 'Habits',
        message: userFacingErrorMessage(error),
        onRetry: onRetry,
      ),
      data: (habits) {
        if (habits.isEmpty) {
          return EmptyFeatureCard(
            key: const Key('plan_habits_empty'),
            title: 'Habits',
            message: AppStrings.sectionEmptyMessage,
            icon: Icons.repeat_rounded,
          );
        }

        return MemyCard(
          key: const Key('plan_habits_populated'),
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Habits',
                subtitle: 'Daily systems that compound',
              ),
              for (final habit in habits.take(3)) ...[
                Text(
                  '${habit.title} · ${habit.valueLabel}',
                  style: AppTextStyles.titleSmall(),
                ),
                Text(habit.detailLabel, style: AppTextStyles.bodySmall()),
                const SizedBox(height: AppSpacing.sm),
              ],
              _PlanLinkFooter(
                icon: Icons.repeat_rounded,
                color: AppColors.habits,
                label: 'Open Habits',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarPlanSection extends StatelessWidget {
  const _CalendarPlanSection({
    required this.asyncValue,
    required this.onRetry,
    required this.onOpen,
  });

  final AsyncValue<List<ScheduleItem>> asyncValue;
  final VoidCallback onRetry;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const LoadingCardSkeleton(
        key: Key('plan_calendar_loading'),
        height: 120,
        lines: 3,
      ),
      error: (error, _) => InlineErrorCard(
        key: const Key('plan_calendar_error'),
        title: 'Calendar',
        message: userFacingErrorMessage(error),
        onRetry: onRetry,
      ),
      data: (events) {
        if (events.isEmpty) {
          return EmptyFeatureCard(
            key: const Key('plan_calendar_empty'),
            title: 'Calendar',
            message: AppStrings.sectionEmptyMessage,
            icon: Icons.calendar_month_rounded,
          );
        }

        return MemyCard(
          key: const Key('plan_calendar_populated'),
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Calendar',
                subtitle: 'Events and time blocks',
              ),
              for (final event in events.take(3)) ...[
                Text(
                  '${event.timeLabel} · ${event.title}',
                  style: AppTextStyles.titleSmall(),
                ),
                if (event.place != null)
                  Text(event.place!, style: AppTextStyles.bodySmall()),
                const SizedBox(height: AppSpacing.sm),
              ],
              _PlanLinkFooter(
                icon: Icons.calendar_month_rounded,
                color: AppColors.learning,
                label: 'Open Calendar',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanLinkFooter extends StatelessWidget {
  const _PlanLinkFooter({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label, style: AppTextStyles.labelLarge())),
        const Icon(Icons.chevron_right_rounded, color: AppColors.faintText),
      ],
    );
  }
}
