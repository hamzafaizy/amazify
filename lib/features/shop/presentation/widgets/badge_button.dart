// lib/widgets/badge_icon_button.dart
import 'package:flutter/material.dart';

class BadgeIconButton extends StatelessWidget {
  const BadgeIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.count = 0,
    this.iconColor,
    this.iconSize,
    this.badgeColor = Colors.red,
    this.badgeTextColor = Colors.white,
    this.showZero = false,
    this.outlined = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final int count;

  final Color? iconColor;
  final double? iconSize;

  final Color badgeColor;
  final Color badgeTextColor;
  final bool showZero;

  /// Puts a thin border around the badge (helps on transparent app bars).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showBadge = showZero || count > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, size: iconSize, color: iconColor),
          onPressed: onPressed,
        ),
        if (showBadge)
          Positioned(
            // tweak these to nudge position
            right: 4,
            top: 4,
            child: Semantics(
              label: 'Notifications: $count',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(9),
                  border: outlined
                      ? Border.all(
                          color: theme.scaffoldBackgroundColor.withValues(
                            alpha: 0.5,
                          ),
                          width: 0.5,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
