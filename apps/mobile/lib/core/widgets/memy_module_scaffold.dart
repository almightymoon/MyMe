import 'package:flutter/material.dart';

import '../../app/router/app_navigation.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../features/shell/presentation/memy_bottom_navigation.dart';
import '../../features/shell/presentation/memy_drawer.dart';
import '../../features/shell/presentation/quick_add_sheet.dart';
import 'memy_chrome.dart';

/// Prototype `.icon-plain` — no tooltip pill, no grey filled circle.
class MemyIconPlain extends StatelessWidget {
  const MemyIconPlain({
    super.key,
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: AppColors.ember.withValues(alpha: 0.08),
                highlightColor: AppColors.ember.withValues(alpha: 0.04),
                onTap: onPressed,
                child: Center(
                  child: Icon(icon, size: 20, color: AppColors.primaryText),
                ),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              top: 6,
              right: 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.ember,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.canvas, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Module chrome matching prototype `.top-row` + optional bottom nav.
class MemyModuleScaffold extends StatelessWidget {
  const MemyModuleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.heroAsset,
    this.heroSize = 88,
    this.showBottomNav = true,
    this.navIndex = 1,
    this.fallbackPath = RoutePaths.plan,
    this.showDemoLabel = false,
    this.decoration,

    /// When true, child fills remaining viewport (for pinned bottom layouts).
    this.fillBody = false,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.sm,
      AppSpacing.page,
      AppSpacing.xxxl,
    ),
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final String? heroAsset;
  final double heroSize;
  final bool showBottomNav;
  final int navIndex;
  final String fallbackPath;
  final bool showDemoLabel;
  final Decoration? decoration;
  final bool fillBody;
  final EdgeInsetsGeometry padding;

  Widget _topRow(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          MemyIconPlain(
            key: const Key('module_back'),
            icon: Icons.chevron_left_rounded,
            onPressed: () => memyBack(context, fallback: fallbackPath),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium().copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            if (showBottomNav) const SizedBox(width: 6),
          ],
          if (showBottomNav)
            const MemyMenuButton(key: Key('module_open_drawer'))
          else if (trailing == null)
            const SizedBox(width: 36),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = showBottomNav
        ? MemyBottomNavigation.contentBottomInset(context)
        : 0.0;

    final contentPadding = padding.add(EdgeInsets.only(bottom: bottomInset));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      extendBody: showBottomNav,
      endDrawer: showBottomNav ? MemyDrawer(activeShellIndex: navIndex) : null,
      body: DecoratedBox(
        decoration: decoration ?? BoxDecoration(color: AppColors.canvas),
        child: SafeArea(
          bottom: !showBottomNav,
          child: fillBody
              ? Padding(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _topRow(context),
                      if (heroAsset != null) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            heroAsset!,
                            width: heroSize,
                            height: heroSize,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                      Expanded(child: child),
                      if (showDemoLabel) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Demo content',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.kicker(),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView(
                  padding: contentPadding,
                  children: [
                    _topRow(context),
                    if (heroAsset != null) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          heroAsset!,
                          width: heroSize,
                          height: heroSize,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                    child,
                    if (showDemoLabel) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Demo content',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.kicker(),
                      ),
                    ],
                  ],
                ),
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? MemyBottomNavigation(
              currentIndex: navIndex,
              onDestinationSelected: (index) => memyGoShellTab(context, index),
              onQuickAddPressed: () => showQuickAddSheet(context),
            )
          : null,
    );
  }
}
