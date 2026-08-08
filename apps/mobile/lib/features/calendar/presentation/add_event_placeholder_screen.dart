import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class AddEventPlaceholderScreen extends StatelessWidget {
  const AddEventPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Add Event',
          explanation: 'Event creation will arrive with the calendar feature.',
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
