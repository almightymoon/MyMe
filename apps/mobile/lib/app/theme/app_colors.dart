import 'package:flutter/material.dart';

/// Visual tokens from the MeMy HTML/CSS app prototype (`app/css/app.css`).
abstract final class AppColors {
  /// Page background — soft cool grey so white cards lift off the canvas.
  /// Design home screens use this (stronger than pure `#FAFAFA`).
  static const Color canvas = Color(0xFFF5F5F7);

  /// Slightly deeper wash for nested wells / chips.
  static const Color canvasDeep = Color(0xFFEEEFF1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color glass = Color(0xC7FFFFFF); // ~78% white
  /// Prototype `--ink`
  static const Color primaryText = Color(0xFF1C1C1E);
  static const Color secondaryText = Color(0xFF3A3A3C);
  static const Color faintText = Color(0xFF8E8E93);
  static const Color navInactive = Color(0xFFAEAEB2);

  /// Prototype `--orange`
  static const Color ember = Color(0xFFFF6A1A);
  static const Color emberDark = Color(0xFFE8501F);
  static const Color orangeSoft = Color(0xFFFFF0E8);

  /// Soft insight surface (replaces purple depth card as default).
  static const Color depth = Color(0xFF1C1C1E);

  static const Color health = Color(0xFFFF3B30);
  static const Color finance = Color(0xFF34C759);
  static const Color career = Color(0xFF2F80ED);
  static const Color learning = Color(0xFF6366F1);
  static const Color habits = Color(0xFFF2A93B);
  static const Color line = Color(0x0F000000);
  static const Color progressTrack = Color(0xFFEEEFF1);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> liftShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x14000000), blurRadius: 48, offset: Offset(0, 20)),
  ];

  static const List<BoxShadow> orangeGlow = [
    BoxShadow(color: Color(0x6BFF6A1A), blurRadius: 24, offset: Offset(0, 10)),
  ];
}
