import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_feature_card.dart';
import '../../../core/widgets/inline_error_card.dart';
import '../../../core/widgets/loading_card_skeleton.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/metric_tile.dart';
import '../../../core/widgets/progress_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../calendar/domain/entities/schedule_item.dart';
import '../../coach/domain/entities/coach_suggestion.dart';
import '../../finance/domain/entities/finance_summary.dart';
import '../../goals/domain/entities/goal_summary.dart';
import '../../habits/domain/entities/habit_summary.dart';
import '../application/providers/today_providers.dart';
import '../domain/entities/daily_focus.dart';
import '../domain/entities/today_summary.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(todaySummaryProvider);
    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    return SafeArea(
      child: asyncSummary.when(
        loading: () => _TodayScaffold(
          greetingName: '…',
          dateLabel: dateLabel,
          child: const _TodayLoadingBody(key: Key('today_loading')),
        ),
        error: (error, _) => _TodayScaffold(
          greetingName: 'there',
          dateLabel: dateLabel,
          child: InlineErrorCard(
            key: const Key('today_error'),
            message: error.toString(),
            onRetry: () => ref.invalidate(todaySummaryProvider),
          ),
        ),
        data: (summary) {
          if (!summary.hasDailyInformation) {
            return _TodayScaffold(
              greetingName: summary.greetingName,
              dateLabel: dateLabel,
              child: const EmptyFeatureCard(
                key: Key('today_empty'),
                title: AppStrings.dayAtAGlance,
                message: AppStrings.todayEmptyMessage,
                icon: Icons.wb_sunny_outlined,
              ),
            );
          }

          return _TodayScaffold(
            greetingName: summary.greetingName,
            dateLabel: dateLabel,
            child: _TodayPopulatedBody(
              key: const Key('today_populated'),
              summary: summary,
            ),
          );
        },
      ),
    );
  }
}

class _TodayScaffold extends StatelessWidget {
  const _TodayScaffold({
    required this.greetingName,
    required this.dateLabel,
    required this.child,
  });

  final String greetingName;
  final String dateLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('today_scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day, $greetingName',
                  style: AppTextStyles.displayMedium(),
                ),
                const SizedBox(height: 4),
                Text(dateLabel, style: AppTextStyles.bodyMedium()),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  AppStrings.dayAtAGlance,
                  style: AppTextStyles.titleLarge(),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.demoContentLabel,
                  style: AppTextStyles.kicker(),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayLoadingBody extends StatelessWidget {
  const _TodayLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LoadingCardSkeleton(height: 96, lines: 2),
        SizedBox(height: AppSpacing.md),
        LoadingCardSkeleton(height: 108, lines: 3),
        SizedBox(height: AppSpacing.md),
        LoadingCardSkeleton(height: 96, lines: 2),
        SizedBox(height: AppSpacing.md),
        LoadingCardSkeleton(height: 88, lines: 2),
      ],
    );
  }
}

class _TodayPopulatedBody extends StatelessWidget {
  const _TodayPopulatedBody({super.key, required this.summary});

  final TodaySummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (summary.focus != null) ...[
          _FocusSection(focus: summary.focus!),
          const SizedBox(height: AppSpacing.md),
        ],
        _ScheduleSection(items: summary.schedule),
        const SizedBox(height: AppSpacing.md),
        _GoalsSection(goals: summary.goals),
        const SizedBox(height: AppSpacing.md),
        _HabitsSection(habits: summary.habits),
        const SizedBox(height: AppSpacing.md),
        _FinanceSection(finance: summary.finance),
        const SizedBox(height: AppSpacing.md),
        _CoachSection(suggestion: summary.coachRecommendation),
      ],
    );
  }
}

class _FocusSection extends StatelessWidget {
  const _FocusSection({required this.focus});

  final DailyFocus focus;

  @override
  Widget build(BuildContext context) {
    return ProgressCard(
      title: AppStrings.dailyFocus,
      headline: focus.title,
      progressPercent: focus.progressPercent,
      detail:
          '${focus.progressPercent.round()}% complete · demo'
          '${focus.subtitle == null ? '' : ' · ${focus.subtitle}'}',
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.items});

  final List<ScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyFeatureCard(
        title: AppStrings.schedulePreview,
        message: AppStrings.sectionEmptyMessage,
        icon: Icons.event_outlined,
      );
    }

    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: AppStrings.schedulePreview),
          for (var i = 0; i < items.length; i++) ...[
            _ScheduleRow(item: items[i]),
            if (i < items.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(item.timeLabel, style: AppTextStyles.mono(fontSize: 13)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: AppTextStyles.bodyLarge()),
              if (item.place != null)
                Text(item.place!, style: AppTextStyles.bodySmall()),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.goals});

  final List<GoalSummary> goals;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const EmptyFeatureCard(
        title: AppStrings.goalProgress,
        message: AppStrings.sectionEmptyMessage,
        icon: Icons.flag_outlined,
      );
    }

    final goal = goals.first;
    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: AppStrings.goalProgress),
          Text(goal.title, style: AppTextStyles.titleSmall()),
          const SizedBox(height: 4),
          Text(goal.subtitle, style: AppTextStyles.mono(fontSize: 16)),
        ],
      ),
    );
  }
}

class _HabitsSection extends StatelessWidget {
  const _HabitsSection({required this.habits});

  final List<HabitSummary> habits;

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const EmptyFeatureCard(
        title: AppStrings.habitPreview,
        message: AppStrings.sectionEmptyMessage,
        icon: Icons.repeat_rounded,
      );
    }

    return MemyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: AppStrings.habitPreview),
          for (final habit in habits) ...[
            Text(
              '${habit.title} · ${habit.valueLabel}',
              style: AppTextStyles.titleSmall(),
            ),
            Text(
              habit.isOnTrack
                  ? '${habit.detailLabel} · on track'
                  : habit.detailLabel,
              style: AppTextStyles.bodyMedium(),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FinanceSection extends StatelessWidget {
  const _FinanceSection({required this.finance});

  final FinanceSummary? finance;

  @override
  Widget build(BuildContext context) {
    if (finance == null) {
      return const EmptyFeatureCard(
        title: AppStrings.financePreview,
        message: AppStrings.sectionEmptyMessage,
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    return MetricTile(
      label: AppStrings.financePreview,
      value: finance!.spentTodayLabel,
      caption: 'Spent today · Demo envelope: ${finance!.envelopeLabel}',
      icon: Icons.payments_outlined,
      color: AppColors.finance,
    );
  }
}

class _CoachSection extends StatelessWidget {
  const _CoachSection({required this.suggestion});

  final CoachSuggestion? suggestion;

  @override
  Widget build(BuildContext context) {
    if (suggestion == null) {
      return const EmptyFeatureCard(
        title: AppStrings.aiRecommendation,
        message: AppStrings.sectionEmptyMessage,
        icon: Icons.auto_awesome,
      );
    }

    return MemyCard(
      color: AppColors.depth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.aiRecommendation,
            style: AppTextStyles.labelMedium(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            suggestion!.demoResponse,
            style: AppTextStyles.bodyLarge(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Static demo suggestion — not live AI.',
            style: AppTextStyles.bodySmall(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
