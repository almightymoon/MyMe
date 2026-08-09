import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../user/application/providers/user_providers.dart';

/// Side drawer matching prototype `#drawer` (profile + module links + logout).
class MemyDrawer extends ConsumerWidget {
  const MemyDrawer({super.key, this.activeShellIndex = 0});

  final int activeShellIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).asData?.value;
    final name = profile?.fullName ?? 'Emma Chen';
    final width = math.min(300.0, MediaQuery.sizeOf(context).width * 0.82);

    return Drawer(
      key: const Key('memy_drawer'),
      width: width,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.drawerEndRadius,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 10, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Menu',
                    style: AppTextStyles.titleMedium().copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('drawer_close'),
                        customBorder: const CircleBorder(),
                        splashColor: AppColors.ember.withValues(alpha: 0.08),
                        highlightColor: AppColors.ember.withValues(alpha: 0.04),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Center(
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orangeSoft,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/branding/avatar.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.titleMedium().copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'emma@memy.app',
                          style: AppTextStyles.bodySmall().copyWith(
                            fontSize: 12,
                            color: AppColors.faintText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          key: const Key('drawer_view_profile'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push(RoutePaths.profile);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondaryText,
                            side: const BorderSide(color: AppColors.line),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const StadiumBorder(),
                            textStyle: AppTextStyles.bodySmall().copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('View Profile'),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerLink(
                      keyName: 'drawer_dashboard',
                      label: 'Dashboard',
                      icon: Icons.grid_view_rounded,
                      active: activeShellIndex == 1,
                      onTap: () => _goShell(context, 1),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_goals',
                      label: 'Goals',
                      icon: Icons.track_changes_outlined,
                      onTap: () => _push(context, RoutePaths.goals),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_finance',
                      label: 'Finance',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => _push(context, RoutePaths.finance),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_health',
                      label: 'Health',
                      icon: Icons.favorite_border_rounded,
                      onTap: () => _push(context, RoutePaths.health),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_calendar',
                      label: 'Calendar',
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _push(context, RoutePaths.calendar),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_nutrition',
                      label: 'Nutrition',
                      icon: Icons.water_drop_outlined,
                      onTap: () =>
                          _push(context, RoutePaths.nutritionComingSoon),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_wardrobe',
                      label: 'Wardrobe',
                      icon: Icons.checkroom_outlined,
                      onTap: () => _push(context, RoutePaths.wardrobe),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_body',
                      label: 'Body',
                      icon: Icons.accessibility_new_rounded,
                      onTap: () => _push(context, RoutePaths.body),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_insights',
                      label: 'Insights',
                      icon: Icons.bar_chart_rounded,
                      active: activeShellIndex == 3,
                      onTap: () => _goShell(context, 3),
                    ),
                    _DrawerLink(
                      keyName: 'drawer_coach',
                      label: 'AI Coach',
                      icon: Icons.shield_outlined,
                      active: activeShellIndex == 2,
                      onTap: () => _goShell(context, 2),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: AppColors.line),
              _DrawerLink(
                keyName: 'drawer_settings',
                label: 'Settings',
                icon: Icons.settings_outlined,
                onTap: () => _push(context, RoutePaths.settings),
              ),
              _DrawerLink(
                keyName: 'drawer_notifications',
                label: 'Notifications',
                icon: Icons.notifications_none_rounded,
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("You're all caught up")),
                  );
                },
              ),
              _DrawerLink(
                keyName: 'drawer_help',
                label: 'Help & Support',
                icon: Icons.help_outline_rounded,
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help center coming soon')),
                  );
                },
              ),
              const SizedBox(height: 10),
              Material(
                color: const Color(0xFFFFECEC),
                borderRadius: AppRadii.pillRadius,
                child: InkWell(
                  key: const Key('drawer_logout'),
                  borderRadius: AppRadii.pillRadius,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(RoutePaths.signIn);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Color(0xFFE5484D),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: AppTextStyles.titleMedium().copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE5484D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goShell(BuildContext context, int index) {
    Navigator.of(context).pop();
    memyGoShellTab(context, index);
  }

  void _push(BuildContext context, String path) {
    Navigator.of(context).pop();
    context.push(path);
  }
}

class _DrawerLink extends StatelessWidget {
  const _DrawerLink({
    required this.keyName,
    required this.label,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String keyName;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ember : AppColors.primaryText;
    return Material(
      color: active ? AppColors.orangeSoft : Colors.transparent,
      borderRadius: AppRadii.chipRadius,
      child: InkWell(
        key: Key(keyName),
        borderRadius: AppRadii.chipRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? AppColors.ember : AppColors.secondaryText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
