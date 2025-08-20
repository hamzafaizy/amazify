// Put this next to your other header widgets (e.g., rounded_clipper.dart)

// Class version (recommended)
import 'package:flutter/material.dart';

class CircularFadBox extends StatelessWidget {
  const CircularFadBox({
    super.key,
    required this.cs,
    this.size = 300,
    this.opacity = 0.20,
  });

  final ColorScheme cs;

  /// Circle diameter
  final double size;

  /// Background opacity (0..1)
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primaryContainer.withOpacity(opacity),
      ),
    );
  }
}

// Helper function for your existing calls like: circular_fadbox(cs: cs)
Widget circular_fadbox({
  required ColorScheme cs,
  double size = 300,
  double opacity = 0.20,
}) {
  return CircularFadBox(cs: cs, size: size, opacity: opacity);
}
