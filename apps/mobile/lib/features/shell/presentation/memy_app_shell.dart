import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/config/release_capabilities.dart';
import 'memy_bottom_navigation.dart';
import 'memy_drawer.dart';
import 'quick_add_sheet.dart';

class MemyAppShell extends ConsumerWidget {
  const MemyAppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _openQuickAdd(BuildContext context) {
    return showQuickAddSheet(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(releaseCapabilitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      extendBody: true,
      endDrawer: MemyDrawer(activeShellIndex: navigationShell.currentIndex),
      body: ColoredBox(color: AppColors.canvas, child: navigationShell),
      bottomNavigationBar: MemyBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        onQuickAddPressed: () => _openQuickAdd(context),
        showCoach: capabilities.coachPreview,
      ),
    );
  }
}
