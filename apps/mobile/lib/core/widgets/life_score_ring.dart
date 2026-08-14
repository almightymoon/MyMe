import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Peach-track Life Score ring matching `app/css/app.css` (.ring-*).
class LifeScoreRing extends StatelessWidget {
  const LifeScoreRing({super.key, required this.score, this.size = 100});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LifeScoreRingPainter(progress: (score.clamp(0, 100)) / 100),
      ),
    );
  }
}

class _LifeScoreRingPainter extends CustomPainter {
  _LifeScoreRingPainter({required this.progress});

  final double progress;

  static Color get _track => AppColors.orangeSoft;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.width * 0.11; // ~11 in 100 viewBox
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = _track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = AppColors.ember
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    const start = -math.pi / 2; // 12 o'clock
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, start, sweep, false, valuePaint);

    // End-cap dot (prototype .ring-dot)
    final endAngle = start + sweep;
    final dotCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    final dotPaint = Paint()..color = AppColors.ember;
    canvas.drawCircle(dotCenter, stroke * 0.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LifeScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
