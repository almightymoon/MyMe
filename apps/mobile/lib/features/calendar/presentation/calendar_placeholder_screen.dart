import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class CalendarPlaceholderScreen extends StatelessWidget {
  const CalendarPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Calendar',
          explanation: 'Calendar views and scheduling tools are coming soon.',
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
