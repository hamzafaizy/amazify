import 'package:flutter/material.dart';

/// Dashed indicator for carousels.
/// Each dash = one page. The active dash animates (wider + colored).
class DashedCarouselIndicator extends StatelessWidget {
  const DashedCarouselIndicator({
    super.key,
    required this.length,
    required this.currentIndex,
    this.onTap,
    this.dashWidth = 16,
    this.dashHeight = 4,
    this.spacing = 6,
    this.activeScale = 1.8,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
    this.activeColor,
    this.inactiveColor,
    this.radius = const BorderRadius.all(Radius.circular(999)),
    this.center = true,
  });

  final int length;
  final int currentIndex;

  /// Tap a dash to jump to that page (optional).
  final ValueChanged<int>? onTap;

  /// Look & feel
  final double dashWidth;
  final double dashHeight;
  final double spacing;
  final double activeScale; // width multiplier for the active dash
  final Duration duration;
  final Curve curve;
  final Color? activeColor;
  final Color? inactiveColor;
  final BorderRadiusGeometry radius;
  final bool center;

  @override
  Widget build(BuildContext context) {
    if (length <= 0) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final Color aColor = activeColor ?? cs.primary;
    final Color iColor = inactiveColor ?? cs.onSurface.withOpacity(0.22);

    final children = List.generate(length, (i) {
      final bool isActive = i == currentIndex;
      return GestureDetector(
        onTap: onTap == null ? null : () => onTap!(i),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: duration,
          curve: curve,
          width: isActive ? dashWidth * activeScale : dashWidth,
          height: dashHeight,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            color: isActive ? aColor : iColor,
            borderRadius: radius,
          ),
        ),
      );
    });

    return Row(
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: children,
    );
  }
}
