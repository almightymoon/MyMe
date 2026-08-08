import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const double card = 24;
  static const double control = 14;
  static const double pill = 999;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(control),
  );
}
