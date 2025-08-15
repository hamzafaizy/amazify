// ---------------Text Field Decoration for Auth Inputs----------------
import 'package:flutter/material.dart';

InputDecoration authDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  final cs = Theme.of(context).colorScheme;
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: cs.surfaceContainerHigh,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: cs.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cs.primary),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
