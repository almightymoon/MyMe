import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          explanation: 'New habits can be created here in a later milestone.',
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
