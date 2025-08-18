//------social button widget for rounded buttons with icon and label
import 'package:flutter/material.dart';

class SocialRoundedButton extends StatelessWidget {
  const SocialRoundedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.diameter = 56, // tweak size here
    this.filled = false, // set true for filled circle
  });

  final Widget icon;
  final String label; // used for semantics/tooltip
  final VoidCallback onPressed;
  final double diameter;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            fixedSize: Size.square(diameter), // exact width & height
            padding: EdgeInsets.zero, // center the icon
            side: BorderSide(color: cs.onSurface.withOpacity(0.25)),
            foregroundColor: filled ? cs.onPrimary : cs.onSurface,
            backgroundColor: filled ? cs.primary : null,
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
