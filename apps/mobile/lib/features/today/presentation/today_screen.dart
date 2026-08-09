import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/empty_feature_card.dart';
import '../../../core/widgets/inline_error_card.dart';
import '../../../core/widgets/life_score_ring.dart';
import '../../../core/widgets/loading_card_skeleton.dart';
import '../../../core/widgets/memy_card.dart';
import '../../calendar/domain/entities/schedule_item.dart';
import '../../goals/application/providers/goal_providers.dart';
import '../../shell/presentation/memy_bottom_navigation.dart';
import '../application/providers/today_providers.dart';
import '../application/providers/today_tasks_provider.dart';
import '../domain/entities/daily_focus.dart';
import '../domain/entities/today_summary.dart';
import '../domain/entities/today_task.dart';
import '../../../app/theme/app_radii.dart';

/// Home screen aligned to prototype `data-screen="home"`:
/// greeting → Life Score → Focus → shortcuts → Glance → Today's Tasks.
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
            },
          ),
        ),
        data: (summary) {
          if (!summary.hasDailyInformation) {
            return _TodayScaffold(
              greetingName: summary.greetingName,
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('home_open_drawer'),
                      borderRadius: AppRadii.thumbRadius,
                      onTap: () => openMemyDrawer(context),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 4),
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
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    key: const Key('home_avatar'),
                    customBorder: const CircleBorder(),
                    onTap: () => openMemyProfile(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/branding/avatar.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                        color: AppColors.orangeSoft,
                      ),
                    ),
                  ),
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

class _TodayPopulatedBody extends StatelessWidget {
  const _TodayPopulatedBody({super.key, required this.summary});

  final TodaySummary summary;

  /// Prototype home uses a fixed Life Score of 84.
  static const int demoLifeScore = 84;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _LifeScoreCard(score: demoLifeScore),
        const SizedBox(height: 12),
        if (summary.focus != null) ...[
          _FocusSection(focus: summary.focus!),
          const SizedBox(height: 12),
        ],
        const _ShortcutRow(),
        const SizedBox(height: 12),
        _GlanceSection(items: summary.schedule),
        const SizedBox(height: 12),
        const _TasksSection(),
      ],
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
              decoration: const BoxDecoration(
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
                            style: AppTextStyles.labelSmall(
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

class _GlanceSection extends StatelessWidget {
  const _GlanceSection({required this.items});

  final List<ScheduleItem> items;

  static const _eventBlue = Color(0xFF2F80ED);
  static const _eventBlueSoft = Color(0xFFEAF1FC);

  @override
  Widget build(BuildContext context) {
    // Prototype glance shows Team Meeting + Gym Workout.
    final events = _prototypeEvents(items);

    return MemyCard(
      key: const Key('today_glance'),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
              Expanded(
                flex: 10,
                child: Column(
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
                    Text(
                      '22°C',
                      style: AppTextStyles.displayMedium().copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cloudy',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.faintText,
                      ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 14,
                child: events.isEmpty
                    ? Text(
                        AppStrings.sectionEmptyMessage,
                        style: AppTextStyles.bodySmall(),
                      )
                    : Column(
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

class _GlanceEventRow extends StatelessWidget {
  const _GlanceEventRow({required this.item, required this.icon});

  final ScheduleItem item;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _GlanceSection._eventBlueSoft,
            borderRadius: AppRadii.thumbRadius,
          ),
          child: Icon(icon, size: 17, color: _GlanceSection._eventBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
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
        child: const Icon(
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
          color: done ? AppColors.ember : const Color(0xFFD1D1D6),
          width: 1.5,
        ),
      ),
      child: done
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}
