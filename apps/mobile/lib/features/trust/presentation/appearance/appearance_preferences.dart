import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real appearance preferences backed by SharedPreferences.
abstract final class AppearancePreferences {
  static const String themeModeKey = 'memy_theme_mode_v1';
  static const String reduceMotionKey = 'memy_reduce_motion_v1';

  static const List<String> allKeys = [themeModeKey, reduceMotionKey];

  static ThemeMode readThemeMode(SharedPreferences prefs) {
    switch (prefs.getString(themeModeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> writeThemeMode(
    SharedPreferences prefs,
    ThemeMode mode,
  ) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(themeModeKey, value);
  }

  static bool readReduceMotion(SharedPreferences prefs) {
    return prefs.getBool(reduceMotionKey) ?? false;
  }

  static Future<void> writeReduceMotion(
    SharedPreferences prefs,
    bool value,
  ) async {
    await prefs.setBool(reduceMotionKey, value);
  }

  static Map<String, Object?> exportMap(SharedPreferences prefs) {
    return {
      'themeMode': prefs.getString(themeModeKey) ?? 'system',
      'reduceMotion': readReduceMotion(prefs),
    };
  }
}
