import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/release_capabilities.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../onboarding/application/onboarding_providers.dart';
import '../../onboarding/data/onboarding_preferences.dart';
import '../../user/application/providers/user_providers.dart';
import '../../../core/application/providers/core_providers.dart';

/// Profile screen matching prototype `data-screen="profile"`.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(releaseCapabilitiesProvider);
    final profile = ref.watch(userProfileProvider).asData?.value;
    final prefs = ref.watch(sharedPreferencesProvider);
    final displayName =
        OnboardingPreferences.readDisplayName(prefs) ??
        profile?.fullName ??
        'MeMy';
    final subtitle = OnboardingPreferences.readDisplayName(prefs) != null
        ? 'On this device · ${OnboardingPreferences.readBaseCurrency(prefs)}'
        : 'Local profile on this device';

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
                  Text(displayName, style: AppTextStyles.titleLarge()),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
                    value: 'Open',
                    mutedValue: true,
                    onTap: () => context.push(RoutePaths.goals),
                  ),
                  Divider(height: 1, color: AppColors.line),
                  _ProfileRow(
                    keyName: 'profile_row_finance',
                    label: 'Finance',
                    value: 'Open',
                    mutedValue: true,
                    onTap: () => context.push(RoutePaths.finance),
                  ),
                  if (capabilities.showSignOut) ...[
                    Divider(height: 1, color: AppColors.line),
                    _ProfileRow(
                      keyName: 'profile_row_signout',
                      label: 'Sign out',
                      value: 'Demo session',
                      valueColor: AppColors.health,
                      isLast: true,
                      onTap: () => context.go(RoutePaths.signIn),
                    ),
                  ] else ...[
                    Divider(height: 1, color: AppColors.line),
                    _ProfileRow(
                      keyName: 'profile_row_reset_onboarding',
                      label: 'Reset onboarding',
                      value: 'Keeps your data',
                      mutedValue: true,
                      isLast: true,
                      onTap: () => _confirmResetOnboarding(context, ref),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResetOnboarding(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('profile_reset_onboarding_dialog'),
        title: const Text('Reset onboarding?'),
        content: const Text(
          'Setup will run again the next time you open MeMy. Your goals, '
          'transactions, habits and preferences are not deleted. '
          'Use Privacy & Data if you want to delete local data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('profile_reset_onboarding_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(onboardingCompletionProvider.notifier).reset();
    if (!context.mounted) return;
    context.go(RoutePaths.onboarding);
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
