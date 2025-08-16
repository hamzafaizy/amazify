// lib/core/theme/custom_themes/elevated_button_theme.dart
import 'package:flutter/material.dart';

class ElevatedButtonThemes {
  ElevatedButtonThemes._();

  static ElevatedButtonThemeData light(ColorScheme c) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
        ),
      );

  static ElevatedButtonThemeData dark(ColorScheme c) => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: const StadiumBorder(),
    ),
  );
}
