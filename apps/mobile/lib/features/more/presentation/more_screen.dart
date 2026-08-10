import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/inline_error_card.dart';
import '../../../core/widgets/life_score_ring.dart';
import '../../../core/widgets/loading_card_skeleton.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_chrome.dart';
import '../../shell/presentation/memy_bottom_navigation.dart';
import '../../user/application/providers/user_providers.dart';
import '../../user/domain/entities/user_profile.dart';
import '../../../app/theme/app_radii.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey('more_scroll'),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          MemyBottomNavigation.contentBottomInset(context) + 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This week',
                        style: AppTextStyles.bodySmall().copyWith(
                          color: AppColors.faintText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.insightsTitle,
                        style: AppTextStyles.displayMedium().copyWith(
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const MemyMenuButton(key: Key('insights_open_drawer')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            MemyCard(
              key: const Key('insights_life_trend'),
              padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Life Score trend', style: AppTextStyles.kicker()),
                        const SizedBox(height: 4),
                        Text(
                          '+6%',
                          style: AppTextStyles.mono(
                            fontSize: 32,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'vs last week',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.faintText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LifeScoreRing(score: 84, size: 84),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: MemyCard(
                    key: const Key('insights_saved'),
                    onTap: () => context.push(RoutePaths.finance),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.faintText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'PKR 12K',
                          style: AppTextStyles.titleLarge(
                            color: AppColors.finance,
                          ).copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MemyCard(
                    key: const Key('insights_goals_track'),
                    onTap: () => context.push(RoutePaths.goals),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goals on track',
                          style: AppTextStyles.bodySmall(
                            color: AppColors.faintText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '3 / 4',
                          style: AppTextStyles.titleLarge().copyWith(
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            MemyCard(
              key: const Key('insights_tip'),
              padding: const EdgeInsets.all(16),
              color: AppColors.orangeSoft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.ember,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'i',
                      style: AppTextStyles.labelSmall(
                        color: Colors.white,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Weekend spending is up 32%. Try a no-spend Saturday to stay on your emergency fund goal.',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Modules',
              style: AppTextStyles.titleMedium().copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            profileAsync.when(
              loading: () => const LoadingCardSkeleton(
                key: Key('more_profile_loading'),
                height: 88,
                lines: 2,
              ),
              error: (error, _) => InlineErrorCard(
                key: const Key('more_profile_error'),
                title: 'Profile',
                message: userFacingErrorMessage(error),
                onRetry: () => ref.invalidate(userProfileProvider),
              ),
              data: (profile) => _ProfileCard(profile: profile),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in _moduleItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MemyCard(
                  key: Key(item.keyName),
                  onTap: () => context.push(item.path),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: AppRadii.chipRadius,
                        ),
                        child: Icon(item.icon, color: item.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.titleSmall(),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _moduleItems = <_MoreItem>[
  _MoreItem(
    keyName: 'more_finance',
    title: 'Finance',
    icon: Icons.account_balance_wallet_outlined,
    color: AppColors.finance,
    path: RoutePaths.finance,
  ),
  _MoreItem(
    keyName: 'more_health',
    title: 'Health',
    icon: Icons.favorite_outline_rounded,
    color: AppColors.health,
    path: RoutePaths.health,
  ),
  _MoreItem(
    keyName: 'more_body',
    title: 'Body',
    icon: Icons.accessibility_new_rounded,
    color: AppColors.emberDark,
    path: RoutePaths.body,
  ),
  _MoreItem(
    keyName: 'more_exercise',
    title: 'Exercise',
    icon: Icons.fitness_center_rounded,
    color: AppColors.ember,
    path: RoutePaths.exercise,
  ),
  _MoreItem(
    keyName: 'more_wardrobe',
    title: 'Wardrobe',
    icon: Icons.checkroom_outlined,
    color: AppColors.learning,
    path: RoutePaths.wardrobe,
  ),
  _MoreItem(
    keyName: 'more_settings',
    title: 'Settings',
    icon: Icons.settings_outlined,
    color: AppColors.depth,
    path: RoutePaths.settings,
  ),
];

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('more_profile'),
      onTap: () => context.push(RoutePaths.profile),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orangeSoft,
              image: const DecorationImage(
                image: AssetImage('assets/images/branding/avatar.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName, style: AppTextStyles.titleMedium()),
                Text(
                  profile.tagline ?? AppStrings.demoContentLabel,
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: 4),
                Text(AppStrings.demoMode, style: AppTextStyles.kicker()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({
    required this.keyName,
    required this.title,
    required this.icon,
    required this.color,
    required this.path,
  });

  final String keyName;
  final String title;
  final IconData icon;
  final Color color;
  final String path;
}
