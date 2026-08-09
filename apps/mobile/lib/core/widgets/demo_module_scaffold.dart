import 'package:flutter/material.dart';

import '../../app/router/app_navigation.dart';
import '../../app/router/route_names.dart';
import 'memy_module_scaffold.dart';

/// Legacy alias — prefer [MemyModuleScaffold] directly.
@Deprecated('Use MemyModuleScaffold')
class DemoModuleScaffold extends StatelessWidget {
  const DemoModuleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.trailing,
    this.heroAsset,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final Widget? trailing;
  final String? heroAsset;

  @override
  Widget build(BuildContext context) {
    return MemyModuleScaffold(
      title: title,
      trailing: trailing,
      heroAsset: heroAsset,
      child: child,
    );
  }
}

void demoModuleBack(BuildContext context) {
  memyBack(context, fallback: RoutePaths.plan);
}
