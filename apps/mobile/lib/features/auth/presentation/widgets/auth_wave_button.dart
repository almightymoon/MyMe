import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/ambient_motion.dart';

/// Orange wave CTA matching `.wave-btn.orange` in the HTML prototype.
///
/// Fill bleeds past the clip edges so press motion never flashes white.
/// Idle + press drive a multi-harmonic liquid surface (not a box scale).
class AuthWaveButton extends StatefulWidget {
  const AuthWaveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showChevron = true,
    this.color = AppColors.ember,
  });

  final String label;
  final VoidCallback onPressed;
  final bool showChevron;
  final Color color;

  @override
  State<AuthWaveButton> createState() => _AuthWaveButtonState();
}

class _AuthWaveButtonState extends State<AuthWaveButton>
    with TickerProviderStateMixin {
  static const double _glowPad = 36;
  static const double _waveHeight = 118;
  /// Extra paint below / beside so transform never reveals canvas white.
  static const double _bleed = 48;

  late final AnimationController _wave;
  late final AnimationController _press;
  late final AnimationController _ripple;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 680),
    );
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (ambientMotionEnabled()) {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    _press.dispose();
    _ripple.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    if (value) {
      _press.forward();
      _ripple
        ..value = 0
        ..forward();
      HapticFeedback.selectionClick();
    } else {
      _press.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pressT = CurvedAnimation(
      parent: _press,
      curve: const Cubic(0.22, 0.82, 0.28, 1),
      reverseCurve: const Cubic(0.2, 0.9, 0.3, 1),
    );
    final rippleT = CurvedAnimation(
      parent: _ripple,
      curve: const Cubic(0.15, 0.75, 0.25, 1),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_wave, pressT, rippleT]),
      builder: (context, _) {
        final t = _wave.value * 2 * math.pi;
        final press = pressT.value;
        final ripple = rippleT.value;

        // Traveling liquid surface (idle).
        final crestLift = math.sin(t) * 0.034 + math.sin(t * 1.65 + 0.4) * 0.018;
        final sideBreath = math.sin(t * 0.9 + 0.5) * 0.022;
        final skew = math.sin(t * 0.55) * 0.035;
        final rippleAmp = (1 - ripple) * math.sin(ripple * math.pi) * 0.055;

        // Press settles the crest like liquid compressing — no widget scale.
        final pressSettle = press * 0.07;
        final pressBulge = press * 0.045;

        final chevronPhase = math.sin(t * 1.15);
        final chevronY = chevronPhase * -3.2 - press * 2.5;
        final labelNudge = press * 3.0;

        return SizedBox(
          height: _waveHeight + _glowPad,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -_bleed,
                right: -_bleed,
                bottom: -_bleed,
                height: _waveHeight + _glowPad + _bleed,
                child: CustomPaint(
                  painter: _WavePainter(
                    color: widget.color,
                    crestLift: crestLift - pressSettle + rippleAmp * 0.35,
                    sideBreath: sideBreath + pressBulge,
                    skew: skew,
                    ripple: ripple,
                    rippleAmp: rippleAmp,
                    glowPad: _glowPad,
                    bleed: _bleed,
                    press: press,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _waveHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _setPressed(true),
                  onTapUp: (_) {
                    _setPressed(false);
                    widget.onPressed();
                  },
                  onTapCancel: () => _setPressed(false),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 34),
                      child: Transform.translate(
                        offset: Offset(0, labelNudge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.showChevron)
                              Transform.translate(
                                offset: Offset(0, chevronY),
                                child: Opacity(
                                  opacity:
                                      0.82 + 0.18 * (0.5 + 0.5 * chevronPhase),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            Text(
                              widget.label,
                              style: AppTextStyles.titleMedium(
                                color: Colors.white,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.color,
    required this.crestLift,
    required this.sideBreath,
    required this.skew,
    required this.ripple,
    required this.rippleAmp,
    required this.glowPad,
    required this.bleed,
    required this.press,
  });

  final Color color;
  final double crestLift;
  final double sideBreath;
  final double skew;
  final double ripple;
  final double rippleAmp;
  final double glowPad;
  final double bleed;
  final double press;

  Path _wavePath(Size size) {
    // Paint rect includes horizontal bleed; wave lives in the inner width.
    final left = 0.0;
    final right = size.width;
    final bottom = size.height;
    final top = glowPad;

    final h = size.height - glowPad - bleed;
    final shoulderY = top + h * (0.46 + sideBreath * 0.4);
    final crestY = top + h * (0.08 - crestLift);

    // Sampled surface for a real fluid crest (not a static cubic).
    final path = Path()..moveTo(left, bottom);
    path.lineTo(left, shoulderY);

    const samples = 48;
    for (var i = 0; i <= samples; i++) {
      final u = i / samples;
      final x = ui.lerpDouble(left, right, u)!;

      // Soft arch (SVG C60 55 → 195 10 → 330 55), gently skewed while idle.
      final uSkew = (u - skew * 0.06).clamp(0.0, 1.0);
      final arch = math.sin(uSkew * math.pi);
      final baseY = ui.lerpDouble(shoulderY, crestY, arch)!;

      // Traveling micro-waves along the surface.
      final micro = math.sin(u * math.pi * 3.2 + crestLift * 40) *
              2.4 *
              (1 - press * 0.35) +
          math.sin(u * math.pi * 5.6 + sideBreath * 55) * 1.2;

      // Press ripple expands from center like a liquid slap.
      final dist = (u - 0.5).abs() * 2;
      final ring = (dist - ripple * 1.15).abs();
      final slap = math.exp(-ring * ring * 28) *
          rippleAmp *
          h *
          1.8 *
          (1 - dist * 0.35);

      // Slight center pull toward press point.
      final pressDip = press * arch * 6.0;

      path.lineTo(x, baseY + micro - slap + pressDip);
    }

    path
      ..lineTo(right, bottom)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _wavePath(size);

    // Soft orange haze along the crest only (path-following, never a box).
    for (final layer in const [
      (dy: -12.0, blur: 22.0, alpha: 0.16),
      (dy: -7.0, blur: 12.0, alpha: 0.14),
      (dy: -3.0, blur: 6.0, alpha: 0.1),
    ]) {
      final glow = Paint()
        ..color = color.withValues(alpha: layer.alpha * (1 + press * 0.25))
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, layer.blur);
      canvas.drawPath(path.shift(Offset(0, layer.dy)), glow);
    }

    // Solid body — covers full bleed so press never flashes white.
    canvas.drawPath(path, Paint()..color = color);

    // Specular highlight riding the crest (reads more liquid).
    final highlight = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, glowPad),
        Offset(size.width * 0.5, glowPad + 36),
        [
          Colors.white.withValues(alpha: 0.22 + press * 0.06),
          Colors.white.withValues(alpha: 0.0),
        ],
      )
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8);
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(0, glowPad - 4, size.width, 44),
      highlight,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.crestLift != crestLift ||
        oldDelegate.sideBreath != sideBreath ||
        oldDelegate.skew != skew ||
        oldDelegate.ripple != ripple ||
        oldDelegate.rippleAmp != rippleAmp ||
        oldDelegate.glowPad != glowPad ||
        oldDelegate.bleed != bleed ||
        oldDelegate.press != press;
  }
}
