// Replace your _InfoTile with this version
import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.title,
    required this.value,
    this.icon, // trailing icon (e.g., Iconsax.copy)
    this.onIconPressed, // action when trailing icon pressed
    this.iconTooltip, // tooltip for trailing icon
    this.onTap, // whole tile tap
  });

  final String title;
  final String value;
  final IconData? icon;
  final VoidCallback? onIconPressed;
  final String? iconTooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget? trailing;
    if (icon != null) {
      trailing = (onIconPressed != null)
          ? IconButton(
              tooltip: iconTooltip,
              icon: Icon(icon, size: 18, color: cs.onSurfaceVariant),
              onPressed: onIconPressed,
            )
          : Icon(icon, size: 18, color: cs.onSurfaceVariant);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),

          Text(
            value,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          Spacer(),
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
