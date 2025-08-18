// lib/core/theme/theme.dart
import 'package:amazify/app/theme/custom_theme/appbar_theme.dart';
import 'package:amazify/app/theme/custom_theme/bottom_sheet_theme.dart';
import 'package:amazify/app/theme/custom_theme/checkbox_theme.dart';
import 'package:amazify/app/theme/custom_theme/chip_theme.dart';
import 'package:amazify/app/theme/custom_theme/elevated_button_theme.dart';
import 'package:amazify/app/theme/custom_theme/outlined_button_theme.dart';
import 'package:amazify/app/theme/custom_theme/text_field_theme.dart';
import 'package:amazify/app/theme/custom_theme/text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// Change this to rebrand the whole app from a single place
  static const Color _seed = Color(0xFF0E5EFF);

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
    primary: Colors.blueAccent,
    secondary: Colors.amber,
    tertiary: Colors.blueGrey,
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: Colors.black87,
    onError: Colors.white,
    primaryContainer: const Color.fromARGB(255, 161, 197, 255),
    secondaryContainer: Colors.amber.shade100,
    tertiaryContainer: Colors.blueGrey.shade100,
    surfaceContainerLow: Colors.white70,
    surfaceContainerHigh: Colors.white,
    surfaceContainerHighest: Colors.white,
    outline: Colors.grey.shade400,
    shadow: Colors.black26,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
    primary: Colors.blueAccent.shade700,
    secondary: Colors.amber,
    tertiary: Colors.blueGrey,
    surface: Colors.black87,
    error: Colors.red,
    onPrimary: Colors.black87,
    onSecondary: Colors.black87,
    onTertiary: Colors.black87,
    onSurface: Colors.white70,
    onError: Colors.white,
    primaryContainer: Colors.blueAccent.shade100,
    secondaryContainer: Colors.amber.shade700,
    tertiaryContainer: Colors.blueGrey.shade700,
    surfaceContainerLow: Colors.black54,
    surfaceContainerHigh: Colors.black87,
    surfaceContainerHighest: Colors.black87,
    outline: Colors.grey.shade600,
    shadow: Colors.black54,
  );

  // ───────────────────────────────── Light ─────────────────────────────────
  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    colorScheme: _lightScheme,
    textTheme: AppTextTheme.light,
    appBarTheme: AppBarThemes.light(_lightScheme),
    bottomSheetTheme: BottomSheetThemes.light(_lightScheme),
    checkboxTheme: CheckboxThemes.light(_lightScheme),
    chipTheme: ChipThemes.light(_lightScheme),
    elevatedButtonTheme: ElevatedButtonThemes.light(_lightScheme),
    outlinedButtonTheme: OutlinedButtonThemes.light(_lightScheme),
    inputDecorationTheme: TextFieldThemes.light(_lightScheme),
  );

  // ───────────────────────────────── Dark ──────────────────────────────────
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: _darkScheme,
    textTheme: AppTextTheme.dark,
    appBarTheme: AppBarThemes.dark(_darkScheme),
    bottomSheetTheme: BottomSheetThemes.dark(_darkScheme),
    checkboxTheme: CheckboxThemes.dark(_darkScheme),
    chipTheme: ChipThemes.dark(_darkScheme),
    elevatedButtonTheme: ElevatedButtonThemes.dark(_darkScheme),
    outlinedButtonTheme: OutlinedButtonThemes.dark(_darkScheme),
    inputDecorationTheme: TextFieldThemes.dark(_darkScheme),
  );

  // ─────────────────────────────── Liquid Glass ─────────────────────────────
  //
  // This theme uses translucent surfaces/backgrounds so your `Glass*` widgets
  // (LiquidGlass wrappers) blend beautifully. Use together with:
  // InheritedThemeMode(mode: ThemeModeType.liquidGlass, child: MaterialApp(...))
  static ThemeData liquidGlass = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    colorScheme: _lightScheme.copyWith(
      surface: Colors.white.withOpacity(0.08),
      surfaceContainer: Colors.white.withOpacity(0.06),
      surfaceContainerHighest: Colors.white.withOpacity(0.12),
      surfaceTint: Colors.transparent,
    ),
    scaffoldBackgroundColor: Colors.transparent,

    // Typography stays the same but with lighter foregrounds by default
    textTheme: AppTextTheme.light.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),

    // AppBar kept transparent; the actual glass is provided by GlassAppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      titleTextStyle: AppTextTheme.light.titleLarge?.copyWith(
        color: Colors.white,
      ),
    ),

    // Buttons: subtle translucent fills and light outlines
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.14),
        foregroundColor: Colors.white,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.30)),
      ),
    ),

    // Inputs: translucent fills with soft borders
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      hintStyle: const TextStyle(color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _seed.withOpacity(0.7)),
      ),
    ),

    chipTheme: ChipThemeData(
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: Colors.white.withOpacity(0.10),
      selectedColor: _seed.withOpacity(0.22),
      side: BorderSide(color: Colors.white.withOpacity(0.25)),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(Colors.white.withOpacity(0.55)),
      checkColor: WidgetStateProperty.all(Colors.black87),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white.withOpacity(0.06),
      modalBackgroundColor: Colors.white.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    // Extra polish for glass mode
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.18),
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTextTheme.light.titleLarge?.copyWith(
        color: Colors.white,
      ),
      contentTextStyle: AppTextTheme.light.bodyMedium?.copyWith(
        color: Colors.white,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black.withOpacity(0.7),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white.withOpacity(0.10),
      textStyle: const TextStyle(color: Colors.white),
      surfaceTintColor: Colors.transparent,
    ),
  );
}
