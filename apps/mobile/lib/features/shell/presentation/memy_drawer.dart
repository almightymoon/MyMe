import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/application/providers/app_info_providers.dart';
import '../../trust/domain/entities/sidebar_destination.dart';
import '../../user/application/providers/user_providers.dart';
import 'sidebar/sidebar_account_header.dart';
import 'sidebar/sidebar_destinations.dart';
import 'sidebar/sidebar_footer.dart';
import 'sidebar/sidebar_section.dart';

/// Side drawer matching the trust/support IA (profile + sections + logout).
class MemyDrawer extends ConsumerWidget {
  const MemyDrawer({super.key, this.activeShellIndex = 0});

  final int activeShellIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).asData?.value;
    final name = profile?.fullName ?? 'Friend';
    final profileEmail = profile?.email?.trim();
    final emailLabel = (profileEmail != null && profileEmail.isNotEmpty)
        ? profileEmail
        : 'Demo account';
    final version = ref.watch(appVersionProvider).asData?.value ?? '1.0.0';
    final width = math.min(300.0, MediaQuery.sizeOf(context).width * 0.82);
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      key: const Key('memy_drawer'),
      width: width,
      backgroundColor: AppColors.surface,
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
                    width: AppSpacing.minTouch,
                    height: AppSpacing.minTouch,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('drawer_close'),
                        customBorder: const CircleBorder(),
                        splashColor: AppColors.ember.withValues(alpha: 0.08),
                        highlightColor: AppColors.ember.withValues(alpha: 0.04),
                        onTap: () => Navigator.of(context).pop(),
                        child: Center(
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
              SidebarAccountHeader(
                displayName: name,
                emailLabel: emailLabel,
                onViewProfile: () {
                  Navigator.of(context).pop();
                  context.push(RoutePaths.profile);
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final sectionId in const [
                        SidebarSectionId.primary,
                        SidebarSectionId.lifeAreas,
                        SidebarSectionId.connections,
                        SidebarSectionId.trustHelp,
                      ])
                        SidebarSection(
                          sectionId: sectionId,
                          destinations: SidebarDestinations.forSection(
                            sectionId,
                          ),
                          isActive: (destination) =>
                              _isActive(destination, currentPath),
                          onDestinationSelected: (destination) =>
                              _onSelect(context, destination),
                        ),
                    ],
                  ),
                ),
              ),
              Divider(height: 16, color: AppColors.line),
              SidebarFooter(
                versionLabel: version,
                onLogout: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isActive(SidebarDestination destination, String currentPath) {
    if (destination.shellTabIndex != null) {
      return activeShellIndex == destination.shellTabIndex;
    }
    final path = destination.routePath;
    if (path == null) return false;
    if (currentPath == path) return true;
    // Highlight parent routes for nested settings paths carefully.
    if (path == RoutePaths.settings) {
      return currentPath == RoutePaths.settings;
    }
    return currentPath.startsWith('$path/');
  }

  void _onSelect(BuildContext context, SidebarDestination destination) {
    Navigator.of(context).pop();
    final tab = destination.shellTabIndex;
    if (tab != null) {
      memyGoShellTab(context, tab);
      return;
    }
    final path = destination.routePath;
    if (path == null) return;
    context.push(path);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const Key('drawer_logout_confirm'),
          title: const Text('Log out?'),
          content: const Text(
            'Sign out returns to Sign In and does not delete local MeMy data. '
            'Use Privacy & Data to delete data.',
          ),
          actions: [
            TextButton(
              key: const Key('drawer_logout_cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('drawer_logout_confirm_button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;
    Navigator.of(context).pop();
    context.go(RoutePaths.signIn);
  }
}
