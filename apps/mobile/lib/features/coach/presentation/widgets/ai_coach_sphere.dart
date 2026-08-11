import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/ambient_motion.dart';

/// Clean glass orb for Coach. Drawn as true circles — no stacked clips.
class AiCoachSphere extends StatefulWidget {
  const AiCoachSphere({super.key, this.size = 160, this.animate = true});

  final double size;
  final bool animate;

  @override
  State<AiCoachSphere> createState() => _AiCoachSphereState();
}

class _AiCoachSphereState extends State<AiCoachSphere>
    with SingleTickerProviderStateMixin {
  AnimationController? _idle;

  @override
  void initState() {
    super.initState();
    _ensureController();
  }

  @override
  void reassemble() {
    super.reassemble();
    _disposeController();
    _ensureController();
  }

  @override
  void didUpdateWidget(covariant AiCoachSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureController();
    if (oldWidget.animate != widget.animate) {
      _syncAnimation();
    }
  }

  void _ensureController() {
    _idle ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _syncAnimation();
  }

  void _disposeController() {
    _idle?.dispose();
    _idle = null;
  }

  bool get _shouldAnimate => widget.animate && ambientMotionEnabled();

  void _syncAnimation() {
    final idle = _idle;
    if (idle == null) return;
    if (_shouldAnimate) {
      idle.repeat();
    } else {
      idle
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureController();
    final idle = _idle!;
    final size = widget.size;

    return SizedBox(
      key: const Key('coach_ai_sphere'),
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: idle,
        builder: (context, _) {
          final live = _shouldAnimate;
          final t = idle.value * math.pi * 2;
          final floatY = live ? math.sin(t) * -5.0 : 0.0;
          final pulse = live ? 0.5 + 0.5 * math.sin(t) : 0.55;
          return Transform.translate(
            offset: Offset(0, floatY),
            child: CustomPaint(
              size: Size.square(size),
              painter: _OrbPainter(pulse: pulse),
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  const _OrbPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final coreR = size.shortestSide * 0.34;
    final glowR = size.shortestSide * 0.5;

    final glow = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.radial(
        center,
        glowR,
        [
          AppColors.ember.withValues(alpha: 0.22 + pulse * 0.08),
          AppColors.ember.withValues(alpha: 0.08),
          const Color(0x00FF6A1A),
        ],
        const [0.0, 0.42, 1.0],
      );
    canvas.drawCircle(center, glowR, glow);

    final core = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.radial(
        center.translate(-coreR * 0.28, -coreR * 0.34),
        coreR * 1.35,
        const [
          Color(0xFFFFF6EE),
          Color(0xFFFFC49A),
          Color(0xFFFF8A4C),
          Color(0xFFFF6A1A),
          Color(0xFFE24A12),
        ],
        const [0.0, 0.22, 0.48, 0.78, 1.0],
      );
    canvas.drawCircle(center, coreR, core);

    final depth = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.radial(
        center.translate(0, coreR * 0.42),
        coreR * 0.95,
        [AppColors.emberDark.withValues(alpha: 0.22), const Color(0x00D94816)],
      );
    canvas.drawCircle(center, coreR, depth);

    final highlightCenter = center.translate(-coreR * 0.28, -coreR * 0.32);
    final highlightR = coreR * 0.28;
    final highlight = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.radial(highlightCenter, highlightR, [
        Colors.white.withValues(alpha: 0.72),
        Colors.white.withValues(alpha: 0.0),
      ]);
    canvas.drawCircle(highlightCenter, highlightR, highlight);

    final rim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawCircle(center, coreR - 0.75, rim);

    final ring = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = AppColors.ember.withValues(alpha: 0.22);
    canvas.drawCircle(center, coreR + 8, ring);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
