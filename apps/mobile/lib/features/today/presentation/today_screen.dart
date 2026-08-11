import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/release_capabilities.dart';
import '../../../core/domain/value_objects/local_date.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/domain/services/money_format.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/integrations/domain/integration_connection_status.dart';
import '../../../core/widgets/empty_feature_card.dart';
import '../../../core/widgets/inline_error_card.dart';
import '../../../core/widgets/life_score_ring.dart';
import '../../../core/widgets/loading_card_skeleton.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_chrome.dart';
import '../../calendar/domain/entities/schedule_item.dart';
import '../../finance/application/providers/finance_providers.dart';
import '../../wardrobe/application/providers/wardrobe_providers.dart';
import '../../wardrobe/domain/entities/wardrobe_models.dart';
import '../../finance/domain/entities/finance_summary.dart';
import '../../goals/application/providers/goal_providers.dart';
import '../../goals/domain/entities/goal_summary.dart';
import '../../habits/application/providers/habit_providers.dart';
import '../../habits/domain/entities/habit_enums.dart';
import '../../habits/domain/entities/habit_progress.dart';
import '../../health/application/providers/health_providers.dart';
import '../../health/domain/entities/daily_health_summary.dart';
import '../../health/domain/entities/health_connection_config.dart';
import '../../health/presentation/widgets/health_format.dart';
import '../../onboarding/data/onboarding_preferences.dart';
import '../../user/application/providers/user_providers.dart';
import '../../shell/presentation/memy_bottom_navigation.dart';
import '../application/providers/today_providers.dart';
import '../application/providers/today_tasks_provider.dart';
import '../application/providers/weather_providers.dart';
import '../domain/entities/daily_focus.dart';
import '../domain/entities/today_summary.dart';
import '../domain/entities/today_task.dart';
import '../domain/entities/weather_snapshot.dart';
import '../domain/weather_exception.dart';

/// Home screen aligned to prototype `data-screen="home"`:
/// greeting → Life Score → Focus → shortcuts → Glance → Today's Tasks,
/// then live module cards (Goals / Finance / Habits / Health).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(todaySummaryProvider);

    return SafeArea(
      bottom: false,
      child: asyncSummary.when(
        loading: () => const _TodayScaffold(
          greetingName: '…',
          child: _TodayLoadingBody(key: Key('today_loading')),
        ),
        error: (error, _) => _TodayScaffold(
          greetingName: 'there',
          child: InlineErrorCard(
            key: const Key('today_error'),
            message: userFacingErrorMessage(error),
            onRetry: () {
              ref.invalidate(todayBaseProvider);
              ref.invalidate(goalsProvider);
              ref.invalidate(todayFinanceSummaryProvider);
            },
          ),
        ),
        data: (summary) {
          if (!summary.hasDailyInformation) {
            return _TodayScaffold(
              greetingName: summary.greetingName,
              child: EmptyFeatureCard(
                key: const Key('today_empty'),
                title: AppStrings.dayAtAGlance,
                message: AppStrings.todayEmptyMessage,
                icon: Icons.wb_sunny_outlined,
              ),
            );
          }

          return _TodayScaffold(
            greetingName: summary.greetingName,
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
  const _TodayScaffold({required this.greetingName, required this.child});

  final String greetingName;
  final Widget child;

  String get _dayPart {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _dayEmoji {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('today_scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              8,
              AppSpacing.page,
              4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $greetingName!',
                          style: AppTextStyles.bodyMedium().copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.faintText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: _dayPart,
                                style: AppTextStyles.displayMedium().copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.9,
                                  height: 1.15,
                                ),
                              ),
                              TextSpan(
                                text: ' $_dayEmoji',
                                style: AppTextStyles.displayMedium().copyWith(
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const MemyHeaderActions(
                  avatarSize: 44,
                  avatarKey: Key('home_avatar'),
                  menuKey: Key('home_open_drawer'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            MemyBottomNavigation.contentBottomInset(context) + 8,
          ),
          sliver: SliverToBoxAdapter(child: child),
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
        SizedBox(height: 12),
        LoadingCardSkeleton(height: 88, lines: 2),
        SizedBox(height: 12),
        LoadingCardSkeleton(height: 88, lines: 2),
        SizedBox(height: 12),
        LoadingCardSkeleton(height: 140, lines: 3),
      ],
    );
  }
}

class _TodayPopulatedBody extends ConsumerWidget {
  const _TodayPopulatedBody({super.key, required this.summary});

  final TodaySummary summary;

  /// Prototype home uses a fixed Life Score of 84 (non-production only).
  static const int demoLifeScore = 84;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(releaseCapabilitiesProvider);
    final showDemoFigures = !capabilities.isProduction;

    return Column(
      children: [
        if (showDemoFigures)
          const _LifeScoreCard(score: demoLifeScore)
        else
          const _TodayBuildDayCard(),
        const SizedBox(height: 12),
        if (showDemoFigures && summary.focus != null) ...[
          _FocusSection(focus: summary.focus!),
          const SizedBox(height: 12),
        ],
        const _ShortcutRow(),
        const SizedBox(height: 12),
        _GlanceSection(
          items: summary.schedule,
          showWeather: capabilities.weather,
        ),
        const SizedBox(height: 12),
        const _TasksSection(),
        if (summary.goals.isNotEmpty) ...[
          const SizedBox(height: 12),
          _TodayGoalsCard(goals: summary.goals),
        ],
        if (summary.finance != null) ...[
          const SizedBox(height: 12),
          _TodayFinanceCard(summary: summary.finance!),
        ],
        if (summary.habits.isNotEmpty) ...[
          const SizedBox(height: 12),
          _TodayHabitsCard(items: summary.habits),
        ],
        const SizedBox(height: 12),
        const _TodayHealthCard(),
        if (capabilities.wardrobe) ...[
          const SizedBox(height: 12),
          const _TodayWardrobeCard(),
        ],
      ],
    );
  }
}

/// Honest production stand-in — no fabricated Life Score.
class _TodayBuildDayCard extends StatelessWidget {
  const _TodayBuildDayCard();

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('today_build_day'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.buildYourDayTitle,
            style: AppTextStyles.bodyMedium().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.faintText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.buildYourDayMessage,
            style: AppTextStyles.titleMedium().copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeScoreCard extends StatelessWidget {
  const _LifeScoreCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('today_life_score'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lifeScore,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.faintText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.samplePreviewCaption,
                  style: AppTextStyles.kicker(),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$score',
                        style: AppTextStyles.mono(fontSize: 42).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          height: 1.05,
                        ),
                      ),
                      TextSpan(
                        text: '%',
                        style: AppTextStyles.titleMedium(
                          color: AppColors.secondaryText,
                        ).copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  score >= 70
                      ? "You're doing great!"
                      : 'Keep a steady pace today.',
                  style: AppTextStyles.bodySmall().copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.faintText,
                  ),
                ),
              ],
            ),
          ),
          LifeScoreRing(score: score),
        ],
      ),
    );
  }
}

class _TodayGoalsCard extends StatelessWidget {
  const _TodayGoalsCard({required this.goals});

  final List<GoalSummary> goals;

  @override
  Widget build(BuildContext context) {
    final visible = goals.take(3).toList();

    return MemyCard(
      key: const Key('today_goals_card'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => context.push(RoutePaths.goals),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Goals',
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'See all',
                style: AppTextStyles.bodySmall(
                  color: AppColors.ember,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.ember,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _TodayGoalRow(goal: visible[i]),
          ],
        ],
      ),
    );
  }
}

class _TodayGoalRow extends StatelessWidget {
  const _TodayGoalRow({required this.goal});

  final GoalSummary goal;

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressPercent.clamp(0.0, 100.0) / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                goal.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${goal.progressPercent.round()}%',
              style: AppTextStyles.bodySmall().copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ember,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          goal.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall(color: AppColors.faintText),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.hairline,
            color: AppColors.ember,
          ),
        ),
      ],
    );
  }
}

class _TodayHabitsCard extends ConsumerWidget {
  const _TodayHabitsCard({required this.items});

  final List<HabitTodayItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = items.take(3).toList();

    return MemyCard(
      key: const Key('today_habits_card'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Habits',
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                key: const Key('today_habits_see_all'),
                onPressed: () => context.push(RoutePaths.habits),
                child: const Text('See all'),
              ),
            ],
          ),
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _TodayHabitRow(item: visible[i]),
          ],
        ],
      ),
    );
  }
}

class _TodayHabitRow extends ConsumerStatefulWidget {
  const _TodayHabitRow({required this.item});

  final HabitTodayItem item;

  @override
  ConsumerState<_TodayHabitRow> createState() => _TodayHabitRowState();
}

class _TodayHabitRowState extends ConsumerState<_TodayHabitRow> {
  var _busy = false;

  Future<void> _toggleBinary() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final date = widget.item.date;
      if (widget.item.isCompleted) {
        await repo.removeCheckIn(
          habitId: widget.item.habit.id,
          localDate: date,
        );
      } else {
        await repo.upsertCheckIn(
          HabitCheckInDraft(
            habitId: widget.item.habit.id,
            localDate: date,
            value: 1,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _bumpValue() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final next = widget.item.value + 1;
      await ref
          .read(habitRepositoryProvider)
          .upsertCheckIn(
            HabitCheckInDraft(
              habitId: widget.item.habit.id,
              localDate: widget.item.date,
              value: next,
            ),
          );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.item.habit;
    final label = habit.goalType == HabitGoalType.binary
        ? (widget.item.isCompleted ? 'Done' : 'Todo')
        : '${widget.item.value}/${widget.item.targetValue}'
              '${habit.unitLabel == null ? '' : ' ${habit.unitLabel}'}';

    return Semantics(
      label: '${habit.name}, $label, streak ${widget.item.currentStreak}',
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push(RoutePaths.habitDetailPath(habit.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall(color: AppColors.faintText),
                  ),
                ],
              ),
            ),
          ),
          if (habit.goalType == HabitGoalType.binary)
            IconButton(
              key: Key('today_habit_toggle_${habit.id}'),
              onPressed: _busy ? null : _toggleBinary,
              icon: Icon(
                widget.item.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: widget.item.isCompleted
                    ? AppColors.ember
                    : AppColors.faintText,
              ),
            )
          else
            IconButton(
              key: Key('today_habit_inc_${habit.id}'),
              onPressed: _busy ? null : _bumpValue,
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
        ],
      ),
    );
  }
}

class _TodayFinanceCard extends StatelessWidget {
  const _TodayFinanceCard({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('today_finance_card'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => context.push(RoutePaths.finance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.financePreview,
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                MoneyFormat.formatSignedMinor(
                  summary.currentBalanceMinor,
                  summary.currencyCode,
                ),
                key: const Key('today_finance_balance'),
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Spent today ${MoneyFormat.formatMinor(summary.spentTodayMinor, summary.currencyCode)}',
            key: const Key('today_finance_spent'),
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          ),
          const SizedBox(height: 4),
          Text(
            'This month · In ${MoneyFormat.formatMinor(summary.periodIncomeMinor, summary.currencyCode)}'
            ' · Out ${MoneyFormat.formatMinor(summary.periodExpenseMinor, summary.currencyCode)}',
            key: const Key('today_finance_period'),
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          ),
          const _TodayFinanceBudgetLine(),
        ],
      ),
    );
  }
}

class _TodayWardrobeCard extends ConsumerWidget {
  const _TodayWardrobeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(todayOutfitPlanProvider);
    final itemsAsync = ref.watch(wardrobeItemsProvider);
    final outfits = ref.watch(wardrobeOutfitsProvider).valueOrNull ?? const [];
    final plan = planAsync.valueOrNull;
    final itemCount = itemsAsync.valueOrNull?.length ?? 0;
    if (plan == null && itemCount < 2) {
      return const SizedBox.shrink();
    }
    Outfit? outfit;
    if (plan != null) {
      for (final candidate in outfits) {
        if (candidate.id == plan.outfitId) outfit = candidate;
      }
    }
    return MemyCard(
      key: const Key('today_wardrobe_card'),
      onTap: () => context.push(RoutePaths.wardrobe),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            outfit == null ? 'Plan an outfit' : 'Today’s outfit',
            style: AppTextStyles.titleSmall().copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            outfit?.name ?? 'Choose a look from items on this device.',
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (outfit != null)
                TextButton(
                  key: const Key('today_wardrobe_worn'),
                  onPressed: () async {
                    final selected = outfit;
                    if (selected == null) return;
                    final repo = ref.read(wardrobeRepositoryProvider);
                    final clock = ref.read(appClockProvider);
                    final now = clock.now();
                    await repo.recordWear(
                      WearRecord(
                        id: ref.read(uuidProvider).v4(),
                        localDate: LocalDate.fromDateTime(now),
                        outfitId: selected.id,
                        itemIds: selected.itemIds,
                        createdAt: now,
                        updatedAt: now,
                      ),
                    );
                    invalidateWardrobe(ref);
                  },
                  child: const Text('Mark as worn'),
                ),
              TextButton(
                key: const Key('today_wardrobe_change'),
                onPressed: () => context.push(RoutePaths.wardrobePlanner),
                child: Text(
                  outfit == null ? 'Plan an outfit' : 'Change outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayFinanceBudgetLine extends ConsumerWidget {
  const _TodayFinanceBudgetLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(todayFinanceBudgetProgressProvider);
    final progress = budgetAsync.valueOrNull;
    if (progress == null) return const SizedBox.shrink();
    final currency = progress.budget.currencyCode;
    final label = progress.isOverspent
        ? 'Budget overspent ${MoneyFormat.formatSignedMinor(progress.remainingSigned.abs(), currency)}'
        : 'Budget remaining ${MoneyFormat.formatSignedMinor(progress.remainingSigned, currency)}';
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        label,
        key: const Key('today_finance_budget'),
        style: AppTextStyles.bodySmall(color: AppColors.faintText),
      ),
    );
  }
}

/// Compact live Health readout — watches Health's own providers directly
/// (not folded into [todaySummaryProvider]) so a Health failure only empties
/// this one card, never the rest of Today. Never auto-requests permission;
/// the only action here is a link into the Connect flow for the user to
/// trigger explicitly.
class _TodayHealthCard extends ConsumerWidget {
  const _TodayHealthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(healthConnectionProvider);

    return connectionAsync.when(
      data: (connection) => _buildForConnection(context, ref, connection),
      loading: () => const _TodayHealthCardShell(
        child: SizedBox(
          height: 40,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      // A Health connection-stream failure must not blank Goals/Finance/
      // Habits/Calendar — just fall back to a "not connected" style card.
      error: (error, _) =>
          _buildForConnection(context, ref, const HealthConnectionConfig()),
    );
  }

  Widget _buildForConnection(
    BuildContext context,
    WidgetRef ref,
    HealthConnectionConfig connection,
  ) {
    if (connection.status != IntegrationConnectionStatus.connected) {
      return _TodayHealthCardShell(
        key: const Key('today_health_connect_cta'),
        onTap: () => context.push(RoutePaths.healthConnect),
        child: Row(
          children: [
            Icon(Icons.favorite_rounded, color: AppColors.ember, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Connect Health to see steps, heart rate & sleep here',
                style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.ember),
          ],
        ),
      );
    }

    final summaryAsync = ref.watch(todayHealthSummaryProvider);
    return summaryAsync.when(
      data: (summary) => _TodayHealthCardShell(
        key: const Key('today_health_card'),
        onTap: () => context.push(RoutePaths.health),
        child: summary.hasAnyData
            ? _TodayHealthMetrics(summary: summary)
            : Text(
                'No Health data yet for today.',
                style: AppTextStyles.bodySmall(color: AppColors.faintText),
              ),
      ),
      loading: () => const _TodayHealthCardShell(
        child: SizedBox(
          height: 40,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      // Isolated failure: show a small inline notice, never touch the rest
      // of the Today screen.
      error: (error, _) => _TodayHealthCardShell(
        key: const Key('today_health_error'),
        onTap: () => context.push(RoutePaths.health),
        child: Text(
          "Couldn't load Health data right now.",
          style: AppTextStyles.bodySmall(color: AppColors.faintText),
        ),
      ),
    );
  }
}

class _TodayHealthCardShell extends StatelessWidget {
  const _TodayHealthCardShell({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Health',
                  style: AppTextStyles.titleSmall().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.faintText,
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TodayHealthMetrics extends StatelessWidget {
  const _TodayHealthMetrics({required this.summary});

  final DailyHealthSummary summary;

  @override
  Widget build(BuildContext context) {
    final chips = <(IconData, String)>[
      if (summary.steps != null)
        (Icons.directions_walk_rounded, HealthFormat.steps(summary.steps!)),
      if (summary.latestHeartRateBpm != null)
        (
          Icons.favorite_rounded,
          '${HealthFormat.beatsPerMinute(summary.latestHeartRateBpm!)} bpm',
        ),
      if (summary.sleepDuration != null)
        (Icons.bedtime_rounded, HealthFormat.duration(summary.sleepDuration!)),
      if (summary.activeEnergyKcal != null)
        (
          Icons.local_fire_department_rounded,
          '${HealthFormat.kilocalories(summary.activeEnergyKcal!)} kcal',
        ),
    ];

    return Row(
      children: [
        for (var i = 0; i < chips.length && i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Icon(chips[i].$1, size: 16, color: AppColors.ember),
          const SizedBox(width: 4),
          Text(
            chips[i].$2,
            style: AppTextStyles.bodySmall(
              color: AppColors.primaryText,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        key: 'shortcut_goals',
        label: 'Goals',
        icon: Icons.gps_fixed_rounded,
        path: RoutePaths.goals,
      ),
      (
        key: 'shortcut_finance',
        label: 'Finance',
        icon: Icons.hexagon_outlined,
        path: RoutePaths.finance,
      ),
      (
        key: 'shortcut_health',
        label: 'Health',
        icon: Icons.favorite_border_rounded,
        path: RoutePaths.health,
      ),
      (
        key: 'shortcut_calendar',
        label: 'Calendar',
        icon: Icons.calendar_today_outlined,
        path: RoutePaths.calendar,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.panelRadius,
                boxShadow: AppColors.softShadow,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: Key(items[i].key),
                  borderRadius: AppRadii.panelRadius,
                  onTap: () => context.push(items[i].path),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 88),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 14, 6, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              items[i].icon,
                              size: 26,
                              color: AppColors.ember,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            items[i].label,
                            style:
                                AppTextStyles.labelSmall(
                                  color: AppColors.primaryText,
                                ).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FocusSection extends StatelessWidget {
  const _FocusSection({required this.focus});

  final DailyFocus focus;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dailyFocus,
            style: AppTextStyles.bodySmall().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.faintText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  focus.title,
                  style: AppTextStyles.titleMedium().copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Text(
                '${focus.progressPercent.round()}%',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.secondaryText,
                ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadii.pillRadius,
            child: LinearProgressIndicator(
              value: (focus.progressPercent.clamp(0, 100)) / 100,
              minHeight: 8,
              backgroundColor: AppColors.progressTrack,
              color: AppColors.ember,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlanceSection extends ConsumerWidget {
  const _GlanceSection({required this.items, this.showWeather = false});

  final List<ScheduleItem> items;
  final bool showWeather;

  static const _eventBlue = Color(0xFF2F80ED);

  static Color eventBlueSoft(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFF1A2740) : const Color(0xFFEAF1FC);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = _prototypeEvents(items);

    return MemyCard(
      key: const Key('today_glance'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dayAtAGlance,
            style: AppTextStyles.titleMedium().copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showWeather) ...[
                const Expanded(child: _GlanceWeatherColumn()),
                const SizedBox(width: 16),
              ],
              Flexible(
                fit: showWeather ? FlexFit.loose : FlexFit.tight,
                child: events.isEmpty
                    ? Text(
                        AppStrings.sectionEmptyMessage,
                        style: AppTextStyles.bodySmall(),
                        textAlign: showWeather
                            ? TextAlign.end
                            : TextAlign.start,
                      )
                    : Column(
                        crossAxisAlignment: showWeather
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < events.length; i++) ...[
                            if (i > 0) const SizedBox(height: 14),
                            _GlanceEventRow(
                              item: events[i],
                              icon: i == 0
                                  ? Icons.home_outlined
                                  : Icons.fitness_center_rounded,
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static List<ScheduleItem> _prototypeEvents(List<ScheduleItem> items) {
    ScheduleItem? byId(String id) {
      for (final item in items) {
        if (item.id == id) return item;
      }
      return null;
    }

    final team = byId('team');
    final gym = byId('gym');
    if (team != null && gym != null) return [team, gym];
    return items.take(2).toList(growable: false);
  }
}

class _GlanceWeatherColumn extends ConsumerWidget {
  const _GlanceWeatherColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(todayWeatherProvider);
    final metric =
        ref.watch(measurementUnitsProvider) == MeasurementUnits.metric;

    return Column(
      key: const Key('today_glance_weather'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.weather,
          style: AppTextStyles.bodySmall().copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.faintText,
          ),
        ),
        const SizedBox(height: 6),
        weatherAsync.when(
          loading: () => Text(
            '…',
            key: const Key('today_weather_loading'),
            style: AppTextStyles.displayMedium().copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          error: (error, _) {
            final weatherError = error is WeatherException
                ? error
                : WeatherException(
                    kind: WeatherFailureKind.unknown,
                    message: userFacingErrorMessage(error),
                  );
            return Column(
              key: const Key('today_weather_error'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherError.message,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      key: const Key('today_weather_retry'),
                      onPressed: () => ref.invalidate(todayWeatherProvider),
                      child: const Text('Retry'),
                    ),
                    if (weatherError.openSettings)
                      TextButton(
                        key: const Key('today_weather_open_settings'),
                        onPressed: () {
                          ref
                              .read(deviceLocationServiceProvider)
                              .openLocationSettings();
                        },
                        child: const Text('Settings'),
                      ),
                  ],
                ),
              ],
            );
          },
          data: (WeatherSnapshot snapshot) => Column(
            key: const Key('today_weather_data'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.temperatureLabel(metric: metric),
                style: AppTextStyles.displayMedium().copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                snapshot.conditionLabel,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.faintText,
                ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlanceEventRow extends StatelessWidget {
  const _GlanceEventRow({required this.item, required this.icon});

  final ScheduleItem item;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _GlanceSection.eventBlueSoft(context),
            borderRadius: AppRadii.thumbRadius,
          ),
          child: Icon(icon, size: 17, color: _GlanceSection._eventBlue),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.timeLabel,
                style: AppTextStyles.bodySmall().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                style: AppTextStyles.bodySmall().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.faintText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TasksSection extends ConsumerWidget {
  const _TasksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider);
    final done = tasks.where((t) => t.isDone).length;

    return MemyCard(
      key: const Key('today_tasks'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.todaysTasks,
                  style: AppTextStyles.titleMedium().copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                key: const Key('today_tasks_count'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orangeSoft,
                  borderRadius: AppRadii.pillRadius,
                ),
                child: Text(
                  '$done of ${tasks.length}',
                  style: AppTextStyles.labelSmall(
                    color: AppColors.ember,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 14),
              child: Text(
                'No tasks yet — add one from Quick Add.',
                style: AppTextStyles.bodySmall(color: AppColors.faintText),
              ),
            )
          else
            for (var i = 0; i < tasks.length; i++) ...[
              _TaskRow(
                task: tasks[i],
                isLast: i == tasks.length - 1,
                onToggle: () =>
                    ref.read(todayTasksProvider.notifier).toggle(tasks[i].id),
                onRemove: () =>
                    ref.read(todayTasksProvider.notifier).remove(tasks[i].id),
              ),
            ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.isLast,
    required this.onToggle,
    required this.onRemove,
  });

  final TodayTask task;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('today_task_dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: const Color(0x14FF3B30),
        child: Icon(
          Icons.delete_outline_rounded,
          color: AppColors.health,
          size: 22,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('today_task_${task.id}'),
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Color(0x0D000000), width: 1),
                    ),
            ),
            child: Row(
              children: [
                _TaskCheck(done: task.isDone, taskId: task.id),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyles.bodyMedium().copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.15,
                          color: task.isDone
                              ? AppColors.faintText
                              : AppColors.primaryText,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationThickness: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        task.meta,
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.faintText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: Key('today_task_remove_${task.id}'),
                  tooltip: 'Remove task',
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.navInactive.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCheck extends StatelessWidget {
  const _TaskCheck({required this.done, required this.taskId});

  final bool done;
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: Key('today_task_check_$taskId'),
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.ember : AppColors.surface,
        border: Border.all(
          color: done ? AppColors.ember : AppColors.navInactive,
          width: 1.5,
        ),
      ),
      child: done
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}
