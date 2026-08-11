import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/release_capabilities.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/domain/services/money_format.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_chrome.dart';
import '../../calendar/domain/entities/schedule_item.dart';
import '../../finance/application/providers/finance_providers.dart';
import '../../goals/application/providers/goal_providers.dart';
import '../../goals/domain/entities/goal.dart';
import '../../goals/domain/entities/goal_enums.dart';
import '../../habits/application/providers/habit_providers.dart';
import '../../health/application/providers/health_providers.dart';
import '../../health/domain/entities/daily_health_summary.dart';
import '../../shell/presentation/memy_bottom_navigation.dart';
import '../../today/application/providers/today_providers.dart';
import '../../wardrobe/application/providers/wardrobe_providers.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(releaseCapabilitiesProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final goals = goalsAsync.asData?.value ?? const <Goal>[];
    final activeGoals = goals
        .where((g) => g.status == GoalStatus.active)
        .toList();
    final avgProgress = activeGoals.isEmpty
        ? 0
        : (activeGoals
                      .map((g) => g.progressPercent)
                      .fold<double>(0, (a, b) => a + b) /
                  activeGoals.length)
              .round();

    final financeAsync = ref.watch(todayFinanceSummaryProvider);
    final financeBudgetAsync = ref.watch(todayFinanceBudgetProgressProvider);
    final habitsOverview = ref.watch(habitsOverviewProvider).valueOrNull;
    final healthAsync = ref.watch(todayHealthSummaryProvider);
    final calendarAsync = ref.watch(todayCalendarEventsProvider);

    final modules = <_DashModule>[
      _DashModule(
        keyName: 'dashboard_module_goals',
        title: 'Goals',
        imageAsset: 'assets/images/modules/mod-goals.png',
        path: RoutePaths.goals,
        builder: (context) => _GoalsModuleCopy(
          activeCount: activeGoals.length,
          avgProgress: avgProgress,
        ),
      ),
      _DashModule(
        keyName: 'dashboard_module_habits',
        title: 'Habits',
        imageAsset: 'assets/images/modules/mod-habits.png',
        path: RoutePaths.habits,
        builder: (context) => _HabitsModuleCopy(
          activeCount: habitsOverview?.activeCount ?? 0,
          completedToday: habitsOverview?.completedToday ?? 0,
          scheduledToday: habitsOverview?.scheduledToday ?? 0,
          weekPercent: habitsOverview?.week.completionPercent ?? 0,
          bestStreak: habitsOverview?.bestCurrentStreak ?? 0,
        ),
      ),
      _DashModule(
        keyName: 'dashboard_module_finance',
        title: 'Finance',
        imageAsset: 'assets/images/modules/mod-finance.png',
        path: RoutePaths.finance,
        builder: (context) {
          final summary = financeAsync.valueOrNull;
          if (summary == null) {
            return const _StaticModuleCopy(
              stat: 'Balance',
              big: '—',
              sub: 'Open Finance',
              subColor: AppColors.finance,
            );
          }
          final budget = financeBudgetAsync.valueOrNull;
          final spentToday =
              'Today ${MoneyFormat.formatMinor(summary.spentTodayMinor, summary.currencyCode)}';
          final budgetLine = budget == null
              ? spentToday
              : budget.isOverspent
              ? 'Budget overspent'
              : 'Budget remaining ${MoneyFormat.formatSignedMinor(budget.remainingSigned, budget.budget.currencyCode)}';
          return _StaticModuleCopy(
            stat: 'Balance',
            big: MoneyFormat.formatSignedMinor(
              summary.currentBalanceMinor,
              summary.currencyCode,
            ),
            sub: budgetLine,
            subColor: AppColors.finance,
          );
        },
      ),
      _DashModule(
        keyName: 'dashboard_module_health',
        title: 'Health',
        imageAsset: 'assets/images/modules/heart.png',
        path: RoutePaths.health,
        builder: (context) =>
            _HealthModuleCopy(summary: healthAsync.valueOrNull),
      ),
      _DashModule(
        keyName: 'dashboard_module_calendar',
        title: 'Calendar',
        imageAsset: 'assets/images/modules/mod-calendar.png',
        path: RoutePaths.calendar,
        builder: (context) =>
            _CalendarModuleCopy(events: calendarAsync.valueOrNull),
      ),
      if (capabilities.wardrobe)
        _DashModule(
          keyName: 'dashboard_module_wardrobe',
          title: 'Wardrobe',
          imageAsset: 'assets/images/modules/mod-wardrobe.png',
          path: RoutePaths.wardrobe,
          builder: (context) {
            final plans =
                ref.watch(upcomingOutfitPlansProvider).valueOrNull ?? const [];
            if (plans.isEmpty) {
              return const _StaticModuleCopy(
                stat: 'Wardrobe',
                big: 'Plan',
                sub: 'Open wardrobe',
                subColor: AppColors.ember,
                bigSmall: true,
              );
            }
            return _StaticModuleCopy(
              stat: 'Next look',
              big: plans.first.localDate.toIso8601String(),
              sub: plans.first.occasion.label,
              subColor: AppColors.ember,
              bigSmall: true,
            );
          },
        ),
      if (capabilities.body)
        _DashModule(
          keyName: 'dashboard_module_body',
          title: 'Body',
          imageAsset: 'assets/images/modules/body.png',
          path: RoutePaths.body,
          builder: (context) => const _StaticModuleCopy(
            stat: 'Preview',
            big: 'Demo only',
            sub: 'Not in v1',
            subColor: AppColors.finance,
          ),
        ),
      _DashModule(
        keyName: 'dashboard_module_insights',
        title: 'Insights',
        imageAsset: 'assets/images/modules/mod-insights.png',
        path: RoutePaths.more,
        builder: (context) => const _StaticModuleCopy(
          stat: 'This week',
          big: 'Weekly Summary',
          sub: 'View report',
          bigSmall: true,
        ),
      ),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey('plan_scroll'),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          MemyBottomNavigation.contentBottomInset(context) + 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DashboardHeader(),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final cardWidth = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final module in modules)
                      SizedBox(
                        width: cardWidth,
                        child: _ModuleCard(module: module),
                      ),
                  ],
                );
              },
            ),
            if (capabilities.coachPreview) ...[
              const SizedBox(height: AppSpacing.md),
              const _CoachStrip(),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.modulesKicker,
                style: AppTextStyles.bodySmall().copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.faintText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.dashboardTitle,
                style: AppTextStyles.displayMedium().copyWith(fontSize: 28),
              ),
            ],
          ),
        ),
        const MemyHeaderActions(
          avatarKey: Key('dashboard_avatar'),
          menuKey: Key('dashboard_open_drawer'),
        ),
      ],
    );
  }
}

class _DashModule {
  const _DashModule({
    required this.keyName,
    required this.title,
    required this.imageAsset,
    required this.path,
    required this.builder,
  });

  final String keyName;
  final String title;
  final String imageAsset;
  final String path;
  final WidgetBuilder builder;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final _DashModule module;

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
          key: Key(module.keyName),
          borderRadius: AppRadii.cardRadius,
          onTap: () {
            if (module.path == RoutePaths.more) {
              context.go(module.path);
            } else {
              context.push(module.path);
            }
          },
          child: SizedBox(
            height: 168,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          module.title,
                          style: AppTextStyles.titleMedium().copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.navInactive,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: module.builder(context)),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Image.asset(
                            module.imageAsset,
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.apps_rounded,
                              size: 40,
                              color: AppColors.ember.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalsModuleCopy extends StatelessWidget {
  const _GoalsModuleCopy({
    required this.activeCount,
    required this.avgProgress,
  });

  final int activeCount;
  final int avgProgress;

  @override
  Widget build(BuildContext context) {
    final pct = avgProgress.clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$activeCount active',
          style: AppTextStyles.bodySmall().copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.faintText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$pct%',
          style: AppTextStyles.mono(
            fontSize: 28,
          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        Text(
          'avg progress',
          style: AppTextStyles.bodySmall().copyWith(
            fontSize: 12,
            color: AppColors.faintText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppRadii.pillRadius,
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 6,
            backgroundColor: AppColors.progressTrack,
            color: AppColors.ember,
          ),
        ),
      ],
    );
  }
}

class _HabitsModuleCopy extends StatelessWidget {
  const _HabitsModuleCopy({
    required this.activeCount,
    required this.completedToday,
    required this.scheduledToday,
    required this.weekPercent,
    required this.bestStreak,
  });

  final int activeCount;
  final int completedToday;
  final int scheduledToday;
  final int weekPercent;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$activeCount active',
          style: AppTextStyles.bodySmall().copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.faintText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$completedToday/$scheduledToday',
          style: AppTextStyles.mono(
            fontSize: 26,
          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        Text(
          'today · $weekPercent% week · streak $bestStreak',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall().copyWith(
            fontSize: 12,
            color: AppColors.habits,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HealthModuleCopy extends StatelessWidget {
  const _HealthModuleCopy({required this.summary});

  final DailyHealthSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const _StaticModuleCopy(stat: 'Health', big: '—', sub: 'Loading…');
    }
    if (summary!.steps != null) {
      return _StaticModuleCopy(
        stat: 'Steps',
        big: '${summary!.steps}',
        sub: 'Today',
        subColor: AppColors.finance,
      );
    }
    if (summary!.latestHeartRateBpm != null) {
      return _StaticModuleCopy(
        stat: 'Heart rate',
        big: '${summary!.latestHeartRateBpm!.round()} bpm',
        sub: 'Latest reading',
        subColor: AppColors.finance,
      );
    }
    if (summary!.hasAnyData) {
      return const _StaticModuleCopy(
        stat: 'Health',
        big: 'Available',
        sub: 'Open for details',
        subColor: AppColors.finance,
      );
    }
    return const _StaticModuleCopy(
      stat: 'Health',
      big: 'No data',
      sub: 'Connect or refresh',
      bigSmall: true,
    );
  }
}

class _CalendarModuleCopy extends StatelessWidget {
  const _CalendarModuleCopy({required this.events});

  final List<ScheduleItem>? events;

  @override
  Widget build(BuildContext context) {
    if (events == null) {
      return const _StaticModuleCopy(
        stat: 'Next up',
        big: '—',
        sub: 'Loading…',
        bigSmall: true,
      );
    }
    if (events!.isEmpty) {
      return const _StaticModuleCopy(
        stat: 'Next up',
        big: 'No events',
        sub: 'Today',
        bigSmall: true,
      );
    }
    final next = events!.first;
    return _StaticModuleCopy(
      stat: 'Next up',
      big: next.title,
      sub: '${next.timeLabel} · Today',
      bigSmall: true,
    );
  }
}

class _StaticModuleCopy extends StatelessWidget {
  const _StaticModuleCopy({
    required this.stat,
    required this.big,
    required this.sub,
    this.subColor,
    this.bigSmall = false,
  });

  final String stat;
  final String big;
  final String sub;
  final Color? subColor;
  final bool bigSmall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat,
          style: AppTextStyles.bodySmall().copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.faintText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          big,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style:
              (bigSmall
                      ? AppTextStyles.titleMedium().copyWith(fontSize: 16)
                      : AppTextStyles.mono(fontSize: 22))
                  .copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: subColor ?? AppColors.faintText,
          ),
        ),
      ],
    );
  }
}

class _CoachStrip extends StatelessWidget {
  const _CoachStrip();

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('dashboard_coach_strip'),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      onTap: () => context.go(RoutePaths.coach),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.coach,
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.liveAiNotConnected,
                  style: AppTextStyles.bodySmall().copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF8A4C),
                  AppColors.ember,
                  AppColors.emberDark,
                ],
              ),
              boxShadow: AppColors.orangeGlow,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
