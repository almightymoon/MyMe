import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class AddGoalPlaceholderScreen extends StatelessWidget {
  const AddGoalPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Add Goal',
          explanation:
              'Creating goals will be available once the goals feature is built.',
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
