import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// `flutter test` sets the OS env var `FLUTTER_TEST` (not a dart-define).
bool get _runningUnderFlutterTest =>
    Platform.environment.containsKey('FLUTTER_TEST');

/// Flutter recreation of the HTML `AICoachSphere` glass orb
/// (`app/js/ai-coach-sphere.js` + `.ai-sphere*` in `app/css/system.css`).
class AiCoachSphere extends StatefulWidget {
  const AiCoachSphere({super.key, this.size = 160, this.animate = true});

  final double size;
  final bool animate;

  @override
  State<AiCoachSphere> createState() => _AiCoachSphereState();
}

class _AiCoachSphereState extends State<AiCoachSphere>
    with TickerProviderStateMixin {
  AnimationController? _idle;
  AnimationController? _light;
  AnimationController? _refract;

  @override
  void initState() {
    super.initState();
    _ensureControllers();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload can leave newly-added controllers uninitialized.
    _disposeControllers();
    _ensureControllers();
  }

  @override
  void didUpdateWidget(covariant AiCoachSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureControllers();
    if (oldWidget.animate != widget.animate) {
      _syncAnimation();
    }
  }

  void _ensureControllers() {
    _idle ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _light ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );
    _refract ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _syncAnimation();
  }

  void _disposeControllers() {
    _idle?.dispose();
    _light?.dispose();
    _refract?.dispose();
    _idle = null;
    _light = null;
    _refract = null;
  }

  bool get _shouldAnimate => widget.animate && !_runningUnderFlutterTest;

  void _syncAnimation() {
    final idle = _idle;
    final light = _light;
    final refract = _refract;
    if (idle == null || light == null || refract == null) return;

    if (_shouldAnimate) {
      idle.repeat();
      light.repeat();
      refract.repeat();
    } else {
      idle
        ..stop()
        ..value = 0;
      light
        ..stop()
        ..value = 0;
      refract
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureControllers();
    final idle = _idle!;
    final light = _light!;
    final refract = _refract!;
    final size = widget.size;
    return SizedBox(
      key: const Key('coach_ai_sphere'),
      width: size,
      height: size * 1.18,
      child: AnimatedBuilder(
        animation: Listenable.merge([idle, light, refract]),
        builder: (context, _) {
          final live = _shouldAnimate;
          final idleT = idle.value * math.pi * 2;
          final lightT = light.value * math.pi * 2;
          final floatY = live ? math.sin(idleT) * -6.0 : 0.0;
          final breathe = live ? 1.0 + math.sin(idleT) * 0.0125 : 1.0;
          final bloomOpacity = live
              ? 0.72 + (math.sin(idleT) + 1) * 0.115
              : 0.85;
          final bloomScale = live ? 1.0 + math.sin(idleT) * 0.02 : 1.0;
          final shadowOpacity = live
              ? 0.5 - math.sin(idleT).abs() * 0.15
              : 0.55;
          final shadowScaleX = live ? 1.0 - math.sin(idleT).abs() * 0.08 : 1.0;
          final glowOpacity = live ? 0.75 + (math.sin(idleT) + 1) * 0.125 : 0.9;
          final lightDx = live ? math.sin(lightT) * size * 0.03 : 0.0;
          final lightDy = live ? math.sin(lightT * 0.7) * size * 0.02 : 0.0;
          final lightOpacity = live ? 0.7 + (math.sin(lightT) + 1) * 0.1 : 0.75;
          final refractAngle = live ? refract.value * math.pi * 2 : 0.0;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Soft orange bloom behind the orb.
              Positioned(
                left: -size * 0.18,
                right: -size * 0.18,
                top: -size * 0.18,
                bottom: size * 0.02,
                child: Opacity(
                  opacity: bloomOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: bloomScale,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(0, -0.04),
                          colors: [
                            Color(0x47FF6A1A),
                            Color(0x1AFF6A1A),
                            Color(0x00FF6A1A),
                          ],
                          stops: [0.0, 0.42, 0.7],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Ground shadow.
              Positioned(
                left: size * 0.18,
                right: size * 0.18,
                bottom: -size * 0.02,
                height: size * 0.18,
                child: Opacity(
                  opacity: shadowOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scaleX: shadowScaleX,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: RadialGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Floating glass body.
              Transform.translate(
                offset: Offset(0, floatY),
                child: Transform.scale(
                  scale: breathe,
                  alignment: const Alignment(0, 0.1),
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: _GlassBody(
                      size: size,
                      glowOpacity: glowOpacity.clamp(0.0, 1.0),
                      lightOffset: Offset(lightDx, lightDy),
                      lightOpacity: lightOpacity.clamp(0.0, 1.0),
                      refractAngle: refractAngle,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlassBody extends StatelessWidget {
  const _GlassBody({
    required this.size,
    required this.glowOpacity,
    required this.lightOffset,
    required this.lightOpacity,
    required this.refractAngle,
  });

  final double size;
  final double glowOpacity;
  final Offset lightOffset;
  final double lightOpacity;
  final double refractAngle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.02),
            Colors.white.withValues(alpha: 0.12),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.55),
            blurRadius: 1,
            spreadRadius: -0.5,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: AppColors.ember.withValues(alpha: 0.2),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Warm rim wash inside the glass shell.
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0, 0.85),
                  radius: 0.95,
                  colors: [
                    AppColors.emberDark.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Core.
            Padding(
              padding: EdgeInsets.all(size * 0.14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.28, -0.4),
                    radius: 1.05,
                    colors: [
                      Color(0xFFFFF1E6),
                      Color(0xFFFFC49A),
                      Color(0xFFFF8A4C),
                      Color(0xFFFF6A1A),
                      Color(0xFFD94816),
                    ],
                    stops: [0.0, 0.18, 0.42, 0.68, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emberDark.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fake inset depth on core.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(0, 0.55),
                          radius: 0.9,
                          colors: [
                            AppColors.emberDark.withValues(alpha: 0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.55),
                          radius: 0.7,
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Soft inner glow.
            Padding(
              padding: EdgeInsets.all(size * 0.06),
              child: Opacity(
                opacity: glowOpacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.1),
                      colors: [
                        const Color(0xFFFFC896).withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.58],
                    ),
                  ),
                ),
              ),
            ),
            // Drifting soft light.
            Align(
              alignment: const Alignment(-0.45, -0.5),
              child: Transform.translate(
                offset: lightOffset,
                child: Opacity(
                  opacity: lightOpacity,
                  child: SizedBox(
                    width: size * 0.42,
                    height: size * 0.42,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.68],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Glass wash.
            const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment(-0.55, -1),
                  end: Alignment(0.75, 1),
                  colors: [
                    Color(0x8CFFFFFF),
                    Color(0x24FFFFFF),
                    Color(0x05FFFFFF),
                    Color(0x0FFFFFFF),
                    Color(0x38FFFFFF),
                  ],
                  stops: [0.0, 0.22, 0.45, 0.7, 1.0],
                ),
              ),
            ),
            // Slow refractive sheen.
            Transform.rotate(
              angle: refractAngle,
              child: Opacity(
                opacity: 0.55,
                child: CustomPaint(painter: _RefractPainter()),
              ),
            ),
            // Rim ring + outer halo.
            CustomPaint(painter: _RimPainter()),
            // Sharp specular crescent.
            Align(
              alignment: const Alignment(-0.42, -0.55),
              child: Transform.rotate(
                angle: -22 * math.pi / 180,
                child: Opacity(
                  opacity: 0.92,
                  child: Container(
                    width: size * 0.34,
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefractPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.42;
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 200 * math.pi / 180,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.white.withValues(alpha: 0.14),
          Colors.transparent,
          const Color(0xFFFFB478).withValues(alpha: 0.1),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.48, 0.58, 0.72, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.softLight;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RefractPainter oldDelegate) => false;
}

class _RimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.72);
    canvas.drawCircle(center, radius - 0.75, rim);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawCircle(center, radius - 2.5, inner);

    final halo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawCircle(center, radius + 3, halo);

    final emberHalo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.ember.withValues(alpha: 0.06);
    canvas.drawCircle(center, radius + 6.5, emberHalo);
  }

  @override
  bool shouldRepaint(covariant _RimPainter oldDelegate) => false;
}
