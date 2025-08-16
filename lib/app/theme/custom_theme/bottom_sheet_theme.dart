// lib/core/theme/custom_themes/bottom_sheet_theme.dart
import 'package:flutter/material.dart';

class BottomSheetThemes {
  BottomSheetThemes._();

  static BottomSheetThemeData light(ColorScheme c) => BottomSheetThemeData(
    backgroundColor: c.surface,
    modalBackgroundColor: c.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );

  static BottomSheetThemeData dark(ColorScheme c) => BottomSheetThemeData(
    backgroundColor: c.surface,
    modalBackgroundColor: c.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}
