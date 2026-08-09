import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../goals/application/providers/goal_providers.dart';
import '../../goals/domain/entities/goal.dart';
import '../../goals/domain/entities/goal_enums.dart';
import '../../shell/presentation/memy_bottom_navigation.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        keyName: 'dashboard_module_finance',
        title: 'Finance',
        imageAsset: 'assets/images/modules/mod-finance.png',
        path: RoutePaths.finance,
        builder: (context) => const _StaticModuleCopy(
          stat: 'Balance',
          big: 'PKR 245K',
          sub: '↑ 12% this month',
          subColor: AppColors.finance,
        ),
      ),
      _DashModule(
        keyName: 'dashboard_module_health',
        title: 'Health',
        imageAsset: 'assets/images/modules/heart.png',
        path: RoutePaths.health,
        builder: (context) => const _StaticModuleCopy(
          stat: 'Heart rate',
          big: '95 bpm',
          sub: '◆ Stable',
          subColor: AppColors.finance,
        ),
      ),
      _DashModule(
        keyName: 'dashboard_module_calendar',
        title: 'Calendar',
        imageAsset: 'assets/images/modules/mod-calendar.png',
        path: RoutePaths.calendar,
        builder: (context) => const _StaticModuleCopy(
          stat: 'Next up',
          big: 'Team Meeting',
          sub: '10:00 AM · Today',
          bigSmall: true,
        ),
      ),
      _DashModule(
        keyName: 'dashboard_module_wardrobe',
        title: 'Wardrobe',
        imageAsset: 'assets/images/modules/mod-wardrobe.png',
        path: RoutePaths.wardrobe,
        builder: (context) => const _StaticModuleCopy(
          stat: 'Today',
          big: 'Business Casual',
          sub: '● Recommended',
          subColor: AppColors.ember,
          bigSmall: true,
        ),
      ),
      _DashModule(
        keyName: 'dashboard_module_nutrition',
        title: 'Nutrition',
        imageAsset: 'assets/images/modules/mod-nutrition.png',
        path: RoutePaths.nutritionComingSoon,
        builder: (context) => const _StaticModuleCopy(
          stat: 'Today',
          big: '1,650',
          sub: 'kcal · 60% of goal',
          subColor: AppColors.ember,
        ),
      ),
      _DashModule(
        keyName: 'dashboard_module_body',
        title: 'Body',
        imageAsset: 'assets/images/modules/body.png',
        path: RoutePaths.body,
        builder: (context) => const _StaticModuleCopy(
          stat: 'BMI',
          big: '22.4',
          sub: 'Normal',
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
            const SizedBox(height: AppSpacing.md),
            const _CoachStrip(),
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
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('dashboard_avatar'),
            customBorder: const CircleBorder(),
            onTap: () => openMemyProfile(context),
            child: Container(
              width: 44,
              height: 44,
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
                  image: AssetImage('assets/images/branding/avatar.png'),
                  fit: BoxFit.cover,
                ),
                color: AppColors.orangeSoft,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        MemyIconPlain(
          key: const Key('dashboard_open_drawer'),
          icon: Icons.menu_rounded,
          onPressed: () => openMemyDrawer(context),
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
      decoration: const BoxDecoration(
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
                  "You're 8% ahead of your monthly savings goal. Great job!",
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
