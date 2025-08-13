// lib/core/theme/custom_themes/text_theme.dart
import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme _base(TextTheme t) => t.copyWith(
    displayLarge: t.displayLarge?.copyWith(fontWeight: FontWeight.w600),
    headlineSmall: t.headlineSmall?.copyWith(letterSpacing: 0.1),
    titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    bodyMedium: t.bodyMedium?.copyWith(height: 1.3),
    labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );

  static TextTheme get light => _base(ThemeData.light().textTheme);
  static TextTheme get dark => _base(ThemeData.dark().textTheme);
}
