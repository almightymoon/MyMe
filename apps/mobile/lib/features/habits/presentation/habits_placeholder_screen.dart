import 'package:flutter/material.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/coming_soon_view.dart';

class HabitsPlaceholderScreen extends StatelessWidget {
  const HabitsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonView(
      featureName: 'Habits',
      explanation: 'Habit tracking is planned for a future release.',
      showBottomNav: true,
      navIndex: 1,
      fallbackPath: RoutePaths.plan,
    );
  }
}
