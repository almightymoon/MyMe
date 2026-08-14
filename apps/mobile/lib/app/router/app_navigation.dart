import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// Pop when possible; otherwise land on a safe shell tab.
void memyBack(BuildContext context, {String fallback = RoutePaths.today}) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(fallback);
}

/// Switch to a primary shell tab (Home / Dashboard / Coach / Insights).
void memyGoShellTab(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go(RoutePaths.today);
    case 1:
      context.go(RoutePaths.plan);
    case 2:
      context.go(RoutePaths.coach);
    case 3:
      context.go(RoutePaths.more);
    default:
      context.go(RoutePaths.today);
  }
}

/// Opens the shell side drawer from the right (prototype menu / ⋮).
void openMemyDrawer(BuildContext context) {
  // Prefer the nearest scaffold that owns an end drawer (shell or module).
  ScaffoldState? withEndDrawer;
  context.visitAncestorElements((element) {
    if (element is StatefulElement && element.state is ScaffoldState) {
      final scaffold = element.state as ScaffoldState;
      if (scaffold.hasEndDrawer) {
        withEndDrawer = scaffold;
        return false;
      }
    }
    return true;
  });
  if (withEndDrawer != null) {
    withEndDrawer!.openEndDrawer();
    return;
  }

  final scaffold = Scaffold.maybeOf(context);
  if (scaffold?.hasEndDrawer ?? false) {
    scaffold!.openEndDrawer();
    return;
  }
  if (scaffold?.hasDrawer ?? false) {
    scaffold!.openDrawer();
    return;
  }
  // Fallback when called outside a scaffold that has a drawer.
  context.go(RoutePaths.more);
}

/// Opens the profile screen (prototype `data-go="profile"`).
void openMemyProfile(BuildContext context) {
  context.push(RoutePaths.profile);
}
