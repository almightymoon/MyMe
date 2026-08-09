import 'package:flutter/material.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/coming_soon_view.dart';

class AddHabitPlaceholderScreen extends StatelessWidget {
  const AddHabitPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Add Habit',
          explanation: 'Habit creation will arrive with the habits feature.',
          fallbackPath: RoutePaths.habits,
        ),
      ),
    );
  }
}
