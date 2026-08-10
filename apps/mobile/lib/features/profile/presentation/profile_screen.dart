import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../user/application/providers/user_providers.dart';

/// Profile screen matching prototype `data-screen="profile"`.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).asData?.value;
    final name = profile?.fullName ?? 'Emma Chen';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          key: const Key('profile_scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: [
            Row(
              children: [
                MemyIconPlain(
                  key: const Key('profile_back'),
                  icon: Icons.chevron_left_rounded,
                  onPressed: () =>
                      memyBack(context, fallback: RoutePaths.today),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Account',
                        style: AppTextStyles.bodySmall().copyWith(
                          color: AppColors.faintText,
                        ),
                      ),
                      Text(
                        'Profile',
                        style: AppTextStyles.displayMedium().copyWith(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                MemyIconPlain(
                  key: const Key('profile_settings'),
                  icon: Icons.settings_outlined,
                  onPressed: () => context.push(RoutePaths.settings),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            MemyCard(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orangeSoft,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/branding/avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: AppTextStyles.titleLarge()),
                  const SizedBox(height: 4),
                  Text(
                    'emma@memy.app · Life Score 84',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.faintText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MemyCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileRow(
                    keyName: 'profile_row_settings',
                    label: 'Settings',
                    value: 'Manage',
                    mutedValue: true,
                    isFirst: true,
                    onTap: () => context.push(RoutePaths.settings),
                  ),
                  Divider(height: 1, color: AppColors.line),
                  _ProfileRow(
                    keyName: 'profile_row_goals',
                    label: 'Goals',
                    value: '4 active',
                    onTap: () => context.push(RoutePaths.goals),
                  ),
                  Divider(height: 1, color: AppColors.line),
                  _ProfileRow(
                    keyName: 'profile_row_finance',
                    label: 'Finance',
                    value: 'PKR 245,000',
                    onTap: () => context.push(RoutePaths.finance),
                  ),
                  Divider(height: 1, color: AppColors.line),
                  _ProfileRow(
                    keyName: 'profile_row_signout',
                    label: 'Sign out',
                    value: 'Log out',
                    valueColor: AppColors.health,
                    isLast: true,
                    onTap: () => context.go(RoutePaths.signIn),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.keyName,
    required this.label,
    required this.value,
    required this.onTap,
    this.mutedValue = false,
    this.valueColor,
    this.isFirst = false,
    this.isLast = false,
  });

  final String keyName;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool mutedValue;
  final Color? valueColor;
  final bool isFirst;
  final bool isLast;

  BorderRadius get _inkRadius {
    if (isFirst && isLast) return AppRadii.cardRadius;
    if (isFirst) {
      return const BorderRadius.vertical(top: Radius.circular(AppRadii.card));
    }
    if (isLast) {
      return const BorderRadius.vertical(
        bottom: Radius.circular(AppRadii.card),
      );
    }
    return BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(keyName),
        onTap: onTap,
        borderRadius: _inkRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.bodyMedium())),
              Text(
                value,
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      valueColor ??
                      (mutedValue
                          ? AppColors.faintText
                          : AppColors.primaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
