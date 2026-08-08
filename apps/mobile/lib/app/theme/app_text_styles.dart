import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle displayLarge({Color? color}) => GoogleFonts.fraunces(
    fontSize: 36,
    fontWeight: FontWeight.w500,
    height: 1.05,
    letterSpacing: -0.4,
    color: color ?? AppColors.primaryText,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.3,
    color: color ?? AppColors.primaryText,
  );

  static TextStyle titleLarge({Color? color}) => GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.2,
    color: color ?? AppColors.primaryText,
  );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: color ?? AppColors.primaryText,
  );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
    color: color ?? AppColors.primaryText,
  );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: -0.1,
    color: color ?? AppColors.primaryText,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: color ?? AppColors.secondaryText,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color ?? AppColors.secondaryText,
  );

  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: color ?? AppColors.primaryText,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: color ?? AppColors.secondaryText,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.2,
    color: color ?? AppColors.faintText,
  );

  static TextStyle navLabel({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.1,
    color: color ?? AppColors.secondaryText,
  );

  static TextStyle mono({Color? color, double fontSize = 18}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: color ?? AppColors.primaryText,
      );

  static TextStyle kicker({Color? color}) => GoogleFonts.ibmPlexMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.4,
    height: 1.2,
    color: color ?? AppColors.emberDark,
  );
}
