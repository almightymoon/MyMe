import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class WardrobePlaceholderScreen extends StatelessWidget {
  const WardrobePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Wardrobe',
          explanation: 'Wardrobe and outfits are not connected yet.',
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
