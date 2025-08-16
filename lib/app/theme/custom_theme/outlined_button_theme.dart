// lib/core/theme/custom_themes/outlined_button_theme.dart
import 'package:flutter/material.dart';

class OutlinedButtonThemes {
  OutlinedButtonThemes._();

  static OutlinedButtonThemeData light(ColorScheme c) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: c.outline),
          foregroundColor: c.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
        ),
      );

  static OutlinedButtonThemeData dark(ColorScheme c) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: c.outline),
      foregroundColor: c.primary,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: const StadiumBorder(),
    ),
  );
}
