import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class customSearchBar extends StatelessWidget {
  const customSearchBar({
    super.key,
    required this.hint,
    required this.fillColor,
    required this.textColor,
    required this.iconColor,
    required this.borderColor,
  });

  final String hint;
  final Color fillColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: textColor),
      cursorColor: textColor.withOpacity(0.9),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.85)),
        prefixIcon: Icon(Iconsax.search_normal_1, color: iconColor),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onPrimary,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
