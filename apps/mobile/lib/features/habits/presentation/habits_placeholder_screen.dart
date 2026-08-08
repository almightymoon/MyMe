import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class HabitsPlaceholderScreen extends StatelessWidget {
  const HabitsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Habits',
          explanation: 'Habit tracking is planned for a future release.',
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutePaths.today);
            }
          },
        ),
      ),
    );
  }
}
