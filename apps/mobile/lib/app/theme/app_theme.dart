import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(MemyPalette.light, Brightness.light);

  static ThemeData dark() => _build(MemyPalette.dark, Brightness.dark);

  static SystemUiOverlayStyle systemOverlayFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? MemyPalette.dark.surface
          : MemyPalette.light.surface,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }

  static ThemeData _build(MemyPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[palette],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.ember,
        onPrimary: Colors.white,
        primaryContainer: palette.orangeSoft,
        onPrimaryContainer: palette.emberDark,
        secondary: palette.depth,
        onSecondary: isDark ? palette.primaryText : Colors.white,
        surface: palette.surface,
        onSurface: palette.primaryText,
        onSurfaceVariant: palette.secondaryText,
        outline: palette.line,
        error: palette.health,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      dividerColor: palette.line,
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyles.displayLarge(color: palette.primaryText),
        displayMedium: AppTextStyles.displayMedium(color: palette.primaryText),
        headlineLarge: AppTextStyles.titleLarge(color: palette.primaryText),
        titleLarge: AppTextStyles.titleMedium(color: palette.primaryText),
        titleMedium: AppTextStyles.titleSmall(color: palette.primaryText),
        bodyLarge: AppTextStyles.bodyLarge(color: palette.primaryText),
        bodyMedium: AppTextStyles.bodyMedium(color: palette.secondaryText),
        bodySmall: AppTextStyles.bodySmall(color: palette.secondaryText),
        labelLarge: AppTextStyles.labelLarge(color: palette.primaryText),
        labelMedium: AppTextStyles.labelMedium(color: palette.secondaryText),
        labelSmall: AppTextStyles.labelSmall(color: palette.faintText),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.canvas,
        foregroundColor: palette.primaryText,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge(color: palette.primaryText),
        systemOverlayStyle: systemOverlayFor(brightness),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.canvasDeep,
        selectedColor: palette.ember,
        disabledColor: palette.canvasDeep,
        labelStyle: AppTextStyles.labelMedium(color: palette.primaryText),
        secondaryLabelStyle: AppTextStyles.labelMedium(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
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
          borderSide: BorderSide(color: palette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.controlRadius,
          borderSide: BorderSide(color: palette.ember, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium(color: palette.faintText),
        labelStyle: AppTextStyles.labelMedium(color: palette.secondaryText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.ember,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          elevation: 0,
          shadowColor: palette.ember.withValues(alpha: 0.42),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge(color: Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.ember,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.emberDark,
          minimumSize: const Size(44, 44),
          textStyle: AppTextStyles.labelMedium(color: palette.emberDark),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return palette.faintText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.ember;
          return palette.canvasDeep;
        }),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.secondaryText,
        textColor: palette.primaryText,
      ),
      dividerTheme: DividerThemeData(color: palette.line, thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetRadius),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? palette.surface : palette.depth,
        contentTextStyle: AppTextStyles.bodyMedium(
          color: isDark ? palette.primaryText : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        textStyle: AppTextStyles.bodyMedium(color: palette.primaryText),
      ),
      iconTheme: IconThemeData(color: palette.secondaryText),
      primaryIconTheme: IconThemeData(color: palette.primaryText),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return palette.secondaryText;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return palette.ember;
            return palette.canvasDeep;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: palette.line)),
        ),
      ),
    );
  }
}
