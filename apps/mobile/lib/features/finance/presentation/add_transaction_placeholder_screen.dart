import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

import '../../../../core/widgets/coming_soon_view.dart';

class AddTransactionPlaceholderScreen extends StatelessWidget {
  const AddTransactionPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComingSoonView(
          featureName: 'Add Transaction',
          explanation:
              'Transaction entry will ship with the finance milestone.',
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
