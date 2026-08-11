import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Whether decorative looping animations should run.
///
/// Disabled in `flutter test` so `pumpAndSettle` can finish.
bool ambientMotionEnabled([BuildContext? context]) {
  if (_inFlutterTest) return false;
  if (context != null && !TickerMode.valuesOf(context).enabled) return false;
  return true;
}

bool get _inFlutterTest {
  try {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return true;
  } on Object {
    // Platform.environment is unavailable on some embeds.
  }
  final name = SchedulerBinding.instance.runtimeType.toString();
  return name.contains('Test') || name.contains('test');
}
