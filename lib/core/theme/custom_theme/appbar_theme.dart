// lib/core/theme/custom_themes/appbar_theme.dart
import 'package:flutter/material.dart';

class AppBarThemes {
  AppBarThemes._();

  static AppBarTheme light(ColorScheme c) => AppBarTheme(
    backgroundColor: c.surface,
    foregroundColor: c.onSurface,
    elevation: 0,
    centerTitle: true,
  );

  static AppBarTheme dark(ColorScheme c) => AppBarTheme(
    backgroundColor: c.surface,
    foregroundColor: c.onSurface,
    elevation: 0,
    centerTitle: true,
  );
}
