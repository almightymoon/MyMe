import 'package:flutter/material.dart';

import '../utils/ambient_motion.dart';

/// Indeterminate spinner that becomes determinate (static) under `flutter test`
/// so `pumpAndSettle` can complete.
class MemyBusyIndicator extends StatelessWidget {
  const MemyBusyIndicator({super.key, this.strokeWidth = 2.5, this.size});

  final double strokeWidth;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      value: ambientMotionEnabled(context) ? null : 0.7,
    );
    if (size == null) return indicator;
    return SizedBox(width: size, height: size, child: indicator);
  }
}
