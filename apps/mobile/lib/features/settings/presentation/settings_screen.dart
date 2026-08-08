import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Settings',
          explanation:
              'Settings preferences will expand in a later milestone. No real account controls here.',
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/today');
            }
          },
        ),
      ),
    );
  }
}
