import 'package:flutter/material.dart';

/// Corner radii from the MeMy HTML/CSS prototype (`--radius`, `--radius-sm`).
abstract final class AppRadii {
  /// Prototype `--radius` — primary cards / sheets.
  static const double card = 28;

  /// Compact panels (metrics, nested tiles).
  static const double panel = 20;

  /// Prototype `--radius-sm` — inputs, controls.
  static const double control = 18;

  /// List rows, chips, drawer links.
  static const double chip = 14;

  /// Small thumbs / icon wells.
  static const double thumb = 12;

  /// Side drawer leading edge.
  static const double drawer = 32;

  static const double pill = 999;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius panelRadius = BorderRadius.all(
    Radius.circular(panel),
  );
  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(chip),
  );
  static const BorderRadius thumbRadius = BorderRadius.all(
    Radius.circular(thumb),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(pill),
  );

  /// Right-side end drawer (rounded on the open/left edge).
  static const BorderRadius drawerEndRadius = BorderRadius.horizontal(
    left: Radius.circular(drawer),
  );

  /// Bottom sheets.
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(card),
  );
}
