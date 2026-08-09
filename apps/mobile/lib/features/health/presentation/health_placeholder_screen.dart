import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/ambient_motion.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../../app/theme/app_radii.dart';

/// Health Overview matching `data-screen="health"` sizes from `app/css/app.css`.
class HealthPlaceholderScreen extends StatelessWidget {
  const HealthPlaceholderScreen({super.key});

  static const _peachWash = BoxDecoration(
    color: AppColors.canvas,
    gradient: RadialGradient(
      center: Alignment(0.55, -0.15),
      radius: 0.95,
      colors: [Color(0x18FFAA82), AppColors.canvas],
      stops: [0.0, 0.62],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MemyModuleScaffold(
      key: const Key('health_overview'),
      title: 'Health Overview',
      decoration: _peachWash,
      fillBody: true,
      // Match prototype health-ov-scroll: nav clearance + small gap.
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      trailing: MemyIconPlain(
        icon: Icons.notifications_none_rounded,
        showBadge: true,
        onPressed: () {},
      ),
      child: const _HealthBody(),
    );
  }
}

class _HealthBody extends StatelessWidget {
  const _HealthBody();

  /// Keep phone proportions even in a wide macOS window.
  static const double _maxContent = 430;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, _maxContent);
        final bodyH = constraints.maxHeight;

        // Prototype `.ho-heart`: right: -8px, lower half behind cards.
        final heartW = math.min(340.0, width * 1.88);
        final heartH = math.min(390.0, heartW * 2.08);
        final cellW = (width - 14) / 2;
        final cardH = math.max(138.0, cellW / 1.32);
        final metricsH = cardH * 2 + 14;
        // Cards cover ~42% of heart; lift a bit so crest sits higher.
        final overlap = heartH * 0.42;

        // Keep a phone-tight cluster; pin it to the bottom above the nav.
        final clusterH = heartH + metricsH - overlap;
        final usedH = math.min(clusterH, bodyH - 4);

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: bodyH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Heart + cards cluster (design density).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: usedH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        // Design: crest higher beside greeting, flush right.
                        top: -100,
                        right: 0,
                        width: heartW,
                        height: heartH,
                        child: _FloatingHeart(width: heartW),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: metricsH,
                        child: const _HealthMetricsGrid(),
                      ),
                    ],
                  ),
                ),
                // Greeting above the heart (same z as design copy).
                Positioned(
                  left: 0,
                  top: 6,
                  width: width * 0.52,
                  child: const _GreetingCopy(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GreetingCopy extends StatelessWidget {
  const _GreetingCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, Emma!',
          style: AppTextStyles.bodyMedium().copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Let's measure your\nhealth today",
          style: AppTextStyles.displayMedium().copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
            height: 1.12,
          ),
        ),
      ],
    );
  }
}

class _FloatingHeart extends StatefulWidget {
  const _FloatingHeart({required this.width});

  final double width;

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5800),
    );
    if (ambientMotionEnabled()) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final dy = math.sin(_float.value * math.pi) * -6;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Image.asset(
        'assets/images/modules/heart.png',
        width: widget.width,
        fit: BoxFit.contain,
        alignment: Alignment.bottomRight,
        errorBuilder: (_, _, _) => Icon(
          Icons.favorite_rounded,
          size: widget.width * 0.55,
          color: AppColors.ember,
        ),
      ),
    );
  }
}

class _HealthMetricsGrid extends StatelessWidget {
  const _HealthMetricsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      // ~138px tall cards (prototype min-height).
      childAspectRatio: 1.32,
      children: const [
        _MetricCard(
          label: 'Heart Rate',
          value: '95',
          unit: 'bpm',
          footer: _HeartWave(),
          softHeartBleed: true,
        ),
        _MetricCard(
          label: 'Steps',
          value: '7,532',
          footer: _SparkBars(tone: _BarTone.orange),
          softHeartBleed: true,
        ),
        _MetricCard(
          label: 'Calories',
          value: '1,650',
          unit: 'kcal',
          footer: _SparkBars(tone: _BarTone.orange),
        ),
        _MetricCard(
          label: 'Sleep',
          value: '7h 45m',
          footer: _SparkBars(tone: _BarTone.purple),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.footer,
    this.unit,
    this.softHeartBleed = false,
  });

  final String label;
  final String value;
  final String? unit;
  final Widget footer;
  final bool softHeartBleed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadii.cardRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1414100C),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.cardRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: softHeartBleed
                  ? const Color(0xD6FFFFFF) // ~84% — heart still reads through
                  : const Color(0xE0FFFFFF), // ~88%
              borderRadius: AppRadii.cardRadius,
              border: Border.all(color: const Color(0xE6FFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall().copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9A9AA3),
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: AppTextStyles.mono(fontSize: 28).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.9,
                          height: 1.05,
                        ),
                      ),
                    if (unit != null)
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA8A8AE),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              footer,
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _HeartWave extends StatelessWidget {
  const _HeartWave();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ember
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.1, size.height * 0.55)
      ..lineTo(size.width * 0.14, size.height * 0.25)
      ..lineTo(size.width * 0.19, size.height * 0.85)
      ..lineTo(size.width * 0.23, size.height * 0.35)
      ..lineTo(size.width * 0.27, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.55)
      ..lineTo(size.width * 0.44, size.height * 0.25)
      ..lineTo(size.width * 0.49, size.height * 0.85)
      ..lineTo(size.width * 0.53, size.height * 0.35)
      ..lineTo(size.width * 0.57, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.55)
      ..lineTo(size.width * 0.73, size.height * 0.3)
      ..lineTo(size.width * 0.77, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.55);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _BarTone { orange, purple }

class _SparkBars extends StatelessWidget {
  const _SparkBars({required this.tone});

  final _BarTone tone;

  static const _heights = [
    0.35,
    0.55,
    0.42,
    0.78,
    0.5,
    0.92,
    0.48,
    0.68,
    0.4,
    0.72,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = tone == _BarTone.orange
        ? const [Color(0xFFFFC08A), AppColors.ember]
        : const [Color(0xFFC4B5FD), Color(0xFF6366F1)];

    return SizedBox(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _heights.length; i++) ...[
            if (i > 0) const SizedBox(width: 3.5),
            Expanded(
              child: Opacity(
                opacity: i.isOdd ? 0.55 : (i % 3 == 0 ? 0.78 : 1),
                child: Container(
                  height: 30 * _heights[i],
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.pillRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: colors,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
