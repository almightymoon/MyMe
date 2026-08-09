import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import 'memy_bottom_navigation.dart';
import 'memy_drawer.dart';
import 'quick_add_sheet.dart';

class MemyAppShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      extendBody: true,
      endDrawer: MemyDrawer(activeShellIndex: navigationShell.currentIndex),
      body: ColoredBox(color: AppColors.canvas, child: navigationShell),
      bottomNavigationBar: MemyBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        onQuickAddPressed: () => _openQuickAdd(context),
      ),
    );
  }
}
