import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class ExercisePlaceholderScreen extends StatelessWidget {
  const ExercisePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Exercise',
          explanation: 'Exercise logging and routines will be added later.',
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
