// lib/core/theme/custom_themes/chip_theme.dart
import 'package:flutter/material.dart';

class ChipThemes {
  ChipThemes._();

  static ChipThemeData light(ColorScheme c) => ChipThemeData(
    backgroundColor: c.surface,
    selectedColor: c.primaryContainer,
    labelStyle: TextStyle(color: c.onSurface),
    side: BorderSide(color: c.outlineVariant),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  );

  static ChipThemeData dark(ColorScheme c) => ChipThemeData(
    backgroundColor: c.surface,
    selectedColor: c.primaryContainer,
    labelStyle: TextStyle(color: c.onSurface),
    side: BorderSide(color: c.outlineVariant),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  );
}
