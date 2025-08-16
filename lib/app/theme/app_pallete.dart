import 'package:flutter/material.dart';

class AppPallete {
  static const Color accentColor = Color(0xFF5E9EFF);
  static const Color shadow = Color(0xFF4A5367);
  static const Color shadowDark = Color(0xFF000000);
  static const Color background = Color(0xFFF2F6FF);
  static const Color backgroundDark = Color(0xFF25254B);
  static const Color background2 = Color(0xFF17203A);
  static const Color background2Dark = Color(0xFF1A1A2E);
  static const Color transparent = Colors.transparent;
  static Gradient lightGradient = LinearGradient(
    colors: [
      Color(0xFFEAF2FF),
      Color(0xFFDCE8FF),
      // Color.fromARGB(255, 255, 255, 255),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static Gradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF0B1220),
      Color(0xFF0E1A35),
      // Color(0xFF000000),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
