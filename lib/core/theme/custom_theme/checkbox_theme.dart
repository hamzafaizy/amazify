// lib/core/theme/custom_themes/checkbox_theme.dart
import 'package:flutter/material.dart';

class CheckboxThemes {
  CheckboxThemes._();

  static CheckboxThemeData light(ColorScheme c) => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? c.primary : c.outline,
    ),
    checkColor: WidgetStateProperty.all(c.onPrimary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );

  static CheckboxThemeData dark(ColorScheme c) => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? c.primary : c.outline,
    ),
    checkColor: WidgetStateProperty.all(c.onPrimary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );
}
