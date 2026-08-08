import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import 'memy_card.dart';

class LoadingCardSkeleton extends StatefulWidget {
  const LoadingCardSkeleton({super.key, this.height = 88, this.lines = 2});

  final double height;
  final int lines;

  @override
  State<LoadingCardSkeleton> createState() => _LoadingCardSkeletonState();
}

class _LoadingCardSkeletonState extends State<LoadingCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = 0.45 + (_controller.value * 0.35);
        return MemyCard(
          child: SizedBox(
            height: widget.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 120, height: 12, opacity: t),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < widget.lines; i++) ...[
                  _Bone(
                    width: i.isEven ? double.infinity : 180,
                    height: 14,
                    opacity: t,
                  ),
                  if (i < widget.lines - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.opacity,
  });

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.canvasDeep.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}
