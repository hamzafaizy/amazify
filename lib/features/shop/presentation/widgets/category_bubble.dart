import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  const Category(this.name, this.icon);
}

class CategoryBubble extends StatelessWidget {
  const CategoryBubble({
    super.key,
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap; // <— added

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap, // <— use the callback
            child: SizedBox(
              width: 50,
              height: 50,
              child: Icon(icon, color: fg),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 62,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg),
          ),
        ),
      ],
    );
  }
}
