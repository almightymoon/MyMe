import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color canvas = Color(0xFFEDEAE2);
  static const Color canvasDeep = Color(0xFFE4E0D6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1A1712);
  static const Color secondaryText = Color(0xFF726B60);
  static const Color faintText = Color(0xFFA69F92);
  static const Color ember = Color(0xFFFF4E2E);
  static const Color emberDark = Color(0xFFC93113);
  static const Color depth = Color(0xFF211D3B);
  static const Color health = Color(0xFFFF6F59);
  static const Color finance = Color(0xFF1F9D6D);
  static const Color career = Color(0xFF3E7BFA);
  static const Color learning = Color(0xFF8B5CF6);
  static const Color habits = Color(0xFFF2A93B);
  static const Color line = Color(0x141A1712);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0A1A1712), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x121A1712), blurRadius: 28, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> liftShadow = [
    BoxShadow(color: Color(0x0F1A1712), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x1F1A1712), blurRadius: 48, offset: Offset(0, 24)),
  ];
}
