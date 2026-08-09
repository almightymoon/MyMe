import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Shared auth atmosphere matching `app/css/app.css` `.auth` / `.auth-bg`.
class AuthAtmosphere extends StatelessWidget {
  const AuthAtmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF9F5), Color(0xFFFAFAFA), Color(0xFFF5F5F7)],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -50,
            child: _Orb(
              size: 180,
              colors: [
                const Color(0x8CFFB478),
                AppColors.ember.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.sizeOf(context).height * 0.12,
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.ember.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: -48,
            child: _Orb(
              size: 140,
              colors: [
                AppColors.ember.withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: colors,
          ),
        ),
      ),
    );
  }
}
