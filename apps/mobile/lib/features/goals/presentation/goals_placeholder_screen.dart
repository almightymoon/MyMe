import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class GoalsPlaceholderScreen extends StatelessWidget {
  const GoalsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Goals',
          explanation:
              'Goals tracking will land in a later milestone. Demo navigation only.',
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
