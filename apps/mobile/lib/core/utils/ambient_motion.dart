import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Whether decorative looping animations should run.
///
/// Disabled under [TestWidgetsFlutterBinding] so `pumpAndSettle` can finish.
bool ambientMotionEnabled([BuildContext? context]) {
  if (context != null && !TickerMode.valuesOf(context).enabled) return false;
  final binding = SchedulerBinding.instance;
  return !binding.runtimeType.toString().contains('TestWidgetsFlutterBinding');
}
