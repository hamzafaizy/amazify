import 'package:flutter/material.dart';

/// Puts a nice gradient/photo behind translucent surfaces when in glass mode.
class GlassBackdrop extends StatelessWidget {
  final Widget child;
  const GlassBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient (swap for an image if you like)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E5EFF), Color(0xFF3C31DD), Color(0xFF0C1027)],
            ),
          ),
        ),
        // Liquid glass pipeline:
        // This doesn't make everything glassy by itself; it prepares the scene
        // so widgets with translucent fills look natural.
        // const LiquidGlassRenderer(),
        child,
      ],
    );
  }
}
