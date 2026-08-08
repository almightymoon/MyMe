import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.ember,
        onPrimary: Colors.white,
        primaryContainer: AppColors.ember.withValues(alpha: 0.12),
        onPrimaryContainer: AppColors.emberDark,
        secondary: AppColors.depth,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.primaryText,
        onSurfaceVariant: AppColors.secondaryText,
        outline: AppColors.line,
        error: AppColors.health,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,
      dividerColor: AppColors.line,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: AppTextStyles.displayLarge(),
        displayMedium: AppTextStyles.displayMedium(),
        headlineLarge: AppTextStyles.titleLarge(),
        titleLarge: AppTextStyles.titleMedium(),
        titleMedium: AppTextStyles.titleSmall(),
        bodyLarge: AppTextStyles.bodyLarge(),
        bodyMedium: AppTextStyles.bodyMedium(),
        bodySmall: AppTextStyles.bodySmall(),
        labelLarge: AppTextStyles.labelLarge(),
        labelMedium: AppTextStyles.labelMedium(),
        labelSmall: AppTextStyles.labelSmall(),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.primaryText,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleMedium(),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: const BorderSide(color: AppColors.ember, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.faintText),
        labelStyle: AppTextStyles.labelMedium(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.controlRadius,
          ),
          textStyle: AppTextStyles.labelLarge(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.controlRadius,
          ),
          textStyle: AppTextStyles.labelLarge(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.emberDark,
          minimumSize: const Size(44, 44),
          textStyle: AppTextStyles.labelMedium(color: AppColors.emberDark),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.depth,
        contentTextStyle: AppTextStyles.bodyMedium(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.controlRadius),
      ),
    );
  }
}
