// lib/core/theme/custom_themes/text_field_theme.dart
import 'package:flutter/material.dart';

class TextFieldThemes {
  TextFieldThemes._();

  static InputDecorationTheme light(ColorScheme c) => InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: c.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.primary, width: 1.5),
    ),
  );

  static InputDecorationTheme dark(ColorScheme c) => InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: c.surfaceContainerHighest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c.primary, width: 1.5),
    ),
  );
}
