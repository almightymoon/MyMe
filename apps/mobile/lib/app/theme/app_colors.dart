import 'package:flutter/material.dart';

/// Semantic MeMy palette (light + dark) registered as a [ThemeExtension].
@immutable
class MemyPalette extends ThemeExtension<MemyPalette> {
  const MemyPalette({
    required this.canvas,
    required this.canvasDeep,
    required this.surface,
    required this.glass,
    required this.primaryText,
    required this.secondaryText,
    required this.faintText,
    required this.navInactive,
    required this.ember,
    required this.emberDark,
    required this.orangeSoft,
    required this.depth,
    required this.health,
    required this.finance,
    required this.career,
    required this.learning,
    required this.habits,
    required this.line,
    required this.progressTrack,
    required this.hairline,
    required this.well,
    required this.sheetHandle,
    required this.dangerSoft,
    required this.softShadow,
    required this.liftShadow,
    required this.orangeGlow,
  });

  final Color canvas;
  final Color canvasDeep;
  final Color surface;
  final Color glass;
  final Color primaryText;
  final Color secondaryText;
  final Color faintText;
  final Color navInactive;
  final Color ember;
  final Color emberDark;
  final Color orangeSoft;
  final Color depth;
  final Color health;
  final Color finance;
  final Color career;
  final Color learning;
  final Color habits;
  final Color line;
  final Color progressTrack;
  final Color hairline;
  final Color well;
  final Color sheetHandle;
  final Color dangerSoft;
  final List<BoxShadow> softShadow;
  final List<BoxShadow> liftShadow;
  final List<BoxShadow> orangeGlow;

  static const MemyPalette light = MemyPalette(
    canvas: Color(0xFFF5F5F7),
    canvasDeep: Color(0xFFEEEFF1),
    surface: Color(0xFFFFFFFF),
    glass: Color(0xC7FFFFFF),
    primaryText: Color(0xFF1C1C1E),
    secondaryText: Color(0xFF3A3A3C),
    faintText: Color(0xFF8E8E93),
    navInactive: Color(0xFFAEAEB2),
    ember: Color(0xFFFF6A1A),
    emberDark: Color(0xFFE8501F),
    orangeSoft: Color(0xFFFFF0E8),
    depth: Color(0xFF1C1C1E),
    health: Color(0xFFFF3B30),
    finance: Color(0xFF34C759),
    career: Color(0xFF2F80ED),
    learning: Color(0xFF6366F1),
    habits: Color(0xFFF2A93B),
    line: Color(0x0F000000),
    progressTrack: Color(0xFFEEEFF1),
    hairline: Color(0xFFECECEE),
    well: Color(0xFFF3F4F6),
    sheetHandle: Color(0xFFE4E4E8),
    dangerSoft: Color(0xFFFFECEC),
    softShadow: [
      BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
    liftShadow: [
      BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4)),
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 48,
        offset: Offset(0, 20),
      ),
    ],
    orangeGlow: [
      BoxShadow(
        color: Color(0x6BFF6A1A),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );

  static const MemyPalette dark = MemyPalette(
    canvas: Color(0xFF0E0E10),
    canvasDeep: Color(0xFF161618),
    surface: Color(0xFF1C1C1E),
    glass: Color(0x292C2C2E),
    primaryText: Color(0xFFF5F5F7),
    secondaryText: Color(0xFFC7C7CC),
    faintText: Color(0xFF8E8E93),
    navInactive: Color(0xFF636366),
    ember: Color(0xFFFF6A1A),
    emberDark: Color(0xFFFF8A4C),
    orangeSoft: Color(0xFF3A2218),
    depth: Color(0xFF2C2C2E),
    health: Color(0xFFFF453A),
    finance: Color(0xFF30D158),
    career: Color(0xFF5B9CFF),
    learning: Color(0xFF7C7CFF),
    habits: Color(0xFFFFB340),
    line: Color(0x1AFFFFFF),
    progressTrack: Color(0xFF2C2C2E),
    hairline: Color(0xFF2C2C2E),
    well: Color(0xFF242426),
    sheetHandle: Color(0xFF3A3A3C),
    dangerSoft: Color(0xFF3A1C1C),
    softShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4)),
      BoxShadow(
        color: Color(0x80000000),
        blurRadius: 28,
        offset: Offset(0, 12),
      ),
    ],
    liftShadow: [
      BoxShadow(color: Color(0x73000000), blurRadius: 18, offset: Offset(0, 6)),
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 48,
        offset: Offset(0, 20),
      ),
    ],
    orangeGlow: [
      BoxShadow(
        color: Color(0x66FF6A1A),
        blurRadius: 28,
        offset: Offset(0, 12),
      ),
    ],
  );

  @override
  MemyPalette copyWith({
    Color? canvas,
    Color? canvasDeep,
    Color? surface,
    Color? glass,
    Color? primaryText,
    Color? secondaryText,
    Color? faintText,
    Color? navInactive,
    Color? ember,
    Color? emberDark,
    Color? orangeSoft,
    Color? depth,
    Color? health,
    Color? finance,
    Color? career,
    Color? learning,
    Color? habits,
    Color? line,
    Color? progressTrack,
    Color? hairline,
    Color? well,
    Color? sheetHandle,
    Color? dangerSoft,
    List<BoxShadow>? softShadow,
    List<BoxShadow>? liftShadow,
    List<BoxShadow>? orangeGlow,
  }) {
    return MemyPalette(
      canvas: canvas ?? this.canvas,
      canvasDeep: canvasDeep ?? this.canvasDeep,
      surface: surface ?? this.surface,
      glass: glass ?? this.glass,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      faintText: faintText ?? this.faintText,
      navInactive: navInactive ?? this.navInactive,
      ember: ember ?? this.ember,
      emberDark: emberDark ?? this.emberDark,
      orangeSoft: orangeSoft ?? this.orangeSoft,
      depth: depth ?? this.depth,
      health: health ?? this.health,
      finance: finance ?? this.finance,
      career: career ?? this.career,
      learning: learning ?? this.learning,
      habits: habits ?? this.habits,
      line: line ?? this.line,
      progressTrack: progressTrack ?? this.progressTrack,
      hairline: hairline ?? this.hairline,
      well: well ?? this.well,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      softShadow: softShadow ?? this.softShadow,
      liftShadow: liftShadow ?? this.liftShadow,
      orangeGlow: orangeGlow ?? this.orangeGlow,
    );
  }

  @override
  MemyPalette lerp(ThemeExtension<MemyPalette>? other, double t) {
    if (other is! MemyPalette) return this;
    if (t < 0.5) return this;
    return other;
  }
}

/// Brightness-aware MeMy tokens.
///
/// Call sites keep using `AppColors.canvas` etc. Active palette is bound from
/// [MaterialApp.builder] via [AppColors.bind] so every screen follows theme.
abstract final class AppColors {
  static MemyPalette _active = MemyPalette.light;

  static MemyPalette get active => _active;

  static void bind(MemyPalette palette) {
    _active = palette;
  }

  static void bindFromContext(BuildContext context) {
    final extension = Theme.of(context).extension<MemyPalette>();
    _active =
        extension ??
        (Theme.of(context).brightness == Brightness.dark
            ? MemyPalette.dark
            : MemyPalette.light);
  }

  static MemyPalette of(BuildContext context) {
    return Theme.of(context).extension<MemyPalette>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? MemyPalette.dark
            : MemyPalette.light);
  }

  static Color get canvas => _active.canvas;
  static Color get canvasDeep => _active.canvasDeep;
  static Color get surface => _active.surface;
  static Color get glass => _active.glass;
  static Color get primaryText => _active.primaryText;
  static Color get secondaryText => _active.secondaryText;
  static Color get faintText => _active.faintText;
  static Color get navInactive => _active.navInactive;

  /// Brand accents stay const so chip/module maps and icons can remain const.
  static const Color ember = Color(0xFFFF6A1A);
  static const Color emberDark = Color(0xFFE8501F);
  static Color get orangeSoft => _active.orangeSoft;
  static Color get depth => _active.depth;
  static const Color health = Color(0xFFFF3B30);
  static const Color finance = Color(0xFF34C759);
  static const Color career = Color(0xFF2F80ED);
  static const Color learning = Color(0xFF6366F1);
  static const Color habits = Color(0xFFF2A93B);

  static Color get line => _active.line;
  static Color get progressTrack => _active.progressTrack;
  static Color get hairline => _active.hairline;
  static Color get well => _active.well;
  static Color get sheetHandle => _active.sheetHandle;
  static Color get dangerSoft => _active.dangerSoft;
  static List<BoxShadow> get softShadow => _active.softShadow;
  static List<BoxShadow> get liftShadow => _active.liftShadow;
  static List<BoxShadow> get orangeGlow => _active.orangeGlow;
}
