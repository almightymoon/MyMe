import 'package:flutter/material.dart';

import 'app_colors.dart';

/// SF Pro–like system typography matching the app prototype.
///
/// Uses the platform UI font (San Francisco on Apple, Roboto elsewhere)
/// instead of the cream-landing Fraunces / Inter stack.
abstract final class AppTextStyles {
  static const List<String> _fallbacks = [
    '.SF Pro Text',
    'SF Pro Text',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double height = 1.25,
    double letterSpacing = -0.2,
  }) {
    return TextStyle(
      fontFamilyFallback: _fallbacks,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.primaryText,
    );
  }

  static TextStyle displayLarge({Color? color}) => _style(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -0.8,
    color: color,
  );

  static TextStyle displayMedium({Color? color}) => _style(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.6,
    color: color,
  );

  static TextStyle titleLarge({Color? color}) => _style(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
    color: color,
  );

  static TextStyle titleMedium({Color? color}) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle titleSmall({Color? color}) => _style(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
    color: color,
  );

  static TextStyle bodyLarge({Color? color}) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: -0.1,
    color: color,
  );

  static TextStyle bodyMedium({Color? color}) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: -0.1,
    color: color ?? AppColors.secondaryText,
  );

  static TextStyle bodySmall({Color? color}) => _style(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.05,
    color: color ?? AppColors.faintText,
  );

  static TextStyle labelLarge({Color? color}) => _style(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle labelMedium({Color? color}) => _style(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.1,
    color: color ?? AppColors.secondaryText,
  );

  static TextStyle labelSmall({Color? color}) => _style(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.05,
    color: color ?? AppColors.faintText,
  );

  static TextStyle navLabel({Color? color}) => _style(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.2,
    color: color ?? AppColors.navInactive,
  );

  /// Numeric / metric style — same family, heavier weight (prototype score).
  static TextStyle mono({Color? color, double fontSize = 18}) => _style(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.6,
    color: color,
  );

  /// Prototype `.hi` / life-score `.label` — 14 / 500 / ink-3.
  static TextStyle kicker({Color? color}) => _style(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.1,
    color: color ?? AppColors.faintText,
  );
}
