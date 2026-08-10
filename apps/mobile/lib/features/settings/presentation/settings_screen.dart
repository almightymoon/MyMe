import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          key: const Key('settings_scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('settings_back'),
                  onPressed: () => memyBack(context, fallback: RoutePaths.more),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
                Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge().copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _Section(
              title: 'Account',
              rows: const [
                _SetRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile Information',
                  isFirst: true,
                ),
                _SetRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                ),
                _SetRow(icon: Icons.shield_outlined, label: 'Security'),
                _SetRow(
                  key: Key('settings_connected_apps'),
                  icon: Icons.link_rounded,
                  label: 'Connected Apps',
                  isLast: true,
                  routePath: RoutePaths.connectedApps,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'Preferences',
              rows: const [
                _SetRow(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Appearance',
                  value: 'Light',
                  isFirst: true,
                ),
                _SetRow(
                  icon: Icons.straighten_rounded,
                  label: 'Units',
                  value: 'Metric',
                ),
                _SetRow(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  value: 'English',
                ),
                _SetRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                ),
                _SetRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy',
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: 'More',
              rows: const [
                _SetRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  isFirst: true,
                ),
                _SetRow(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                ),
                _SetRow(icon: Icons.policy_outlined, label: 'Privacy Policy'),
                _SetRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About MeMy',
                  value: 'v1.2.0',
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            MemyCard(
              key: const Key('settings_logout'),
              onTap: () => context.go(RoutePaths.signIn),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.health),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: AppTextStyles.titleMedium(
                      color: AppColors.health,
                    ).copyWith(fontSize: 15),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_SetRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.bodySmall().copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.faintText,
            ),
          ),
        ),
        MemyCard(
          padding: EdgeInsets.zero,
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.isFirst = false,
    this.isLast = false,
    this.routePath,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isFirst;
  final bool isLast;

  /// When set, taps navigate here instead of showing the demo snackbar.
  final String? routePath;

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
        onTap: () {
          if (routePath != null) {
            context.push(routePath!);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label — demo only'),
              duration: const Duration(milliseconds: 900),
            ),
          );
        },
        borderRadius: _inkRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: Color(0x0D000000))),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.ember),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTextStyles.bodyMedium())),
              if (value != null)
                Text(
                  value!,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.navInactive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
