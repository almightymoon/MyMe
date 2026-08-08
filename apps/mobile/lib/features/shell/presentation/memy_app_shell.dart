import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'memy_bottom_navigation.dart';
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
      body: navigationShell,
      bottomNavigationBar: MemyBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        onQuickAddPressed: () => _openQuickAdd(context),
      ),
    );
  }
}
