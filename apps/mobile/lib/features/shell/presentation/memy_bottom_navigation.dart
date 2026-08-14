import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/ambient_motion.dart';
import '../../../app/theme/app_radii.dart';

/// Bottom nav matching prototype `.bottom-nav` / `.nav-fab`.
///
/// The FAB sits above the bar with a circular orange glow. Layout height
/// includes the FAB overhang so [Scaffold] never clips it into a square.
class MemyBottomNavigation extends StatelessWidget {
  const MemyBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onQuickAddPressed,
    this.showCoach = true,
  });

  /// Shell branch index (0 Today, 1 Plan, 2 Coach, 3 More). Indices stay
  /// stable when [showCoach] is false so the shell keeps all four branches.
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onQuickAddPressed;

  /// Coach is hidden in production; the More item still targets branch 3.
  final bool showCoach;

  /// How far the FAB rises above the bar (prototype `translateY(-22px)`).
  static const double fabRise = 22;
  static const double barContentHeight = 84;
  static const double fabSize = 56;

  /// Scroll/content inset so the last item clears the white bar. The FAB may
  /// overlap the content slightly — intentional with [Scaffold.extendBody].
  ///
  /// Uses [MediaQuery.viewPadding] (not [MediaQuery.padding]): with
  /// `extendBody: true`, Scaffold sets body `padding.bottom` to the full nav
  /// height, which would inflate this inset and reopen the grey middle gap.
  static double contentBottomInset(BuildContext context) {
    return barContentHeight + MediaQuery.viewPaddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    // Prefer viewPadding: Scaffold.extendBody rewrites padding.bottom to the
    // full bottom-nav height (including FAB rise).
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final barHeight = barContentHeight + bottomInset;

    return SizedBox(
      // Include fabRise so the elevated FAB/glow is not clipped into a square
      // by Scaffold (this Flutter version has no Scaffold.clipBehavior).
      height: barHeight + fabRise,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + 14,
            height: 54 + fabRise,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _NavItem(
                      key: const Key('nav_today'),
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: AppStrings.today,
                      selected: currentIndex == 0,
                      onTap: () => onDestinationSelected(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      key: const Key('nav_plan'),
                      icon: Icons.grid_view_rounded,
                      selectedIcon: Icons.grid_view_rounded,
                      label: AppStrings.plan,
                      selected: currentIndex == 1,
                      onTap: () => onDestinationSelected(1),
                    ),
                  ),
                  SizedBox(
                    width: fabSize,
                    height: 54 + fabRise,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _QuickAddButton(
                        key: const Key('nav_quick_add'),
                        onPressed: onQuickAddPressed,
                      ),
                    ),
                  ),
                  if (showCoach)
                    Expanded(
                      child: _NavItem(
                        key: const Key('nav_coach'),
                        icon: Icons.chat_bubble_outline_rounded,
                        selectedIcon: Icons.chat_bubble_rounded,
                        label: AppStrings.coach,
                        selected: currentIndex == 2,
                        onTap: () => onDestinationSelected(2),
                      ),
                    ),
                  Expanded(
                    child: _NavItem(
                      key: const Key('nav_more'),
                      icon: Icons.bar_chart_rounded,
                      selectedIcon: Icons.bar_chart_rounded,
                      label: AppStrings.more,
                      selected: currentIndex == 3,
                      onTap: () => onDestinationSelected(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ember : AppColors.navInactive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.thumbRadius,
        splashColor: AppColors.ember.withValues(alpha: 0.08),
        highlightColor: AppColors.ember.withValues(alpha: 0.04),
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.navLabel(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatefulWidget {
  const _QuickAddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ambientMotionEnabled(context)) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else if (_pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _press.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (value) {
      _press.forward();
      HapticFeedback.selectionClick();
    } else {
      _press.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppStrings.quickAdd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulse, _press]),
        child: const Center(
          child: SizedBox(
            width: MemyBottomNavigation.fabSize,
            height: MemyBottomNavigation.fabSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.ember,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
        builder: (context, child) {
          final t = _pulse.value * 2 * math.pi;
          final breath = 1 + math.sin(t) * 0.018;
          final glowPulse = 0.36 + math.sin(t) * 0.06;
          final pressScale = 1 - (_press.value * 0.08);

          return Transform.scale(
            scale: breath * pressScale,
            child: GestureDetector(
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) {
                _setPressed(false);
                widget.onPressed();
              },
              onTapCancel: () => _setPressed(false),
              child: SizedBox(
                width: MemyBottomNavigation.fabSize + 20,
                height: MemyBottomNavigation.fabSize + 20,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _FabGlowPainter(intensity: glowPulse),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Soft circular glow under the FAB — never a rectangular box shadow.
class _FabGlowPainter extends CustomPainter {
  const _FabGlowPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final radius = MemyBottomNavigation.fabSize / 2;

    // Prototype: box-shadow: 0 10px 24px rgba(255, 106, 26, 0.42)
    final glow = Paint()
      ..color = AppColors.ember.withValues(alpha: intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center + const Offset(0, 6), radius * 0.92, glow);

    final soft = Paint()
      ..color = AppColors.ember.withValues(alpha: intensity * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(center + const Offset(0, 8), radius * 1.05, soft);
  }

  @override
  bool shouldRepaint(covariant _FabGlowPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}
