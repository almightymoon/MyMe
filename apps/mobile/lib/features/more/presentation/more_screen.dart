import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/inline_error_card.dart';
import '../../../core/widgets/loading_card_skeleton.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_page_header.dart';
import '../../user/application/providers/user_providers.dart';
import '../../user/domain/entities/user_profile.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    final items = <_MoreItem>[
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

    return SafeArea(
      child: ListView(
        key: const PageStorageKey('more_scroll'),
        children: [
          const MemyPageHeader(
            title: 'More',
            subtitle: 'Modules and preferences',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: profileAsync.when(
              loading: () => const LoadingCardSkeleton(
                key: Key('more_profile_loading'),
                height: 88,
                lines: 2,
              ),
              error: (error, _) => InlineErrorCard(
                key: const Key('more_profile_error'),
                title: 'Profile',
                message: error.toString(),
                onRetry: () => ref.invalidate(userProfileProvider),
              ),
              data: (profile) => _ProfileCard(profile: profile),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map(
            (item) => ListTile(
              key: Key(item.keyName),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: 4,
              ),
              minVerticalPadding: 12,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              title: Text(item.title, style: AppTextStyles.titleSmall()),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(item.path),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return MemyCard(
      key: const Key('more_profile'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.depth,
            child: Text(
              profile.initials,
              style: AppTextStyles.titleMedium(color: Colors.white),
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
