import 'package:amazify/core/theme/custom_theme/theme_controller.dart';
import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeControllerScope.of(context);
    final kind = controller.kind;

    const items = [
      _ToggleItem(
        icon: Icons.wb_sunny_rounded,
        label: 'Light',
        kind: ThemeKind.light,
      ),
      _ToggleItem(
        icon: Icons.dark_mode_rounded,
        label: 'Dark',
        kind: ThemeKind.dark,
      ),
      _ToggleItem(
        icon: Icons.water_drop_rounded,
        label: 'Glass',
        kind: ThemeKind.glass,
      ),
    ];

    final index = items.indexWhere((e) => e.kind == kind).clamp(0, 2);

    return Semantics(
      label: 'Theme toggle',
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Stack(
          children: [
            // Animated thumb
            AnimatedAlign(
              alignment: [
                Alignment.centerLeft,
                Alignment.center,
                Alignment.centerRight,
              ][index],
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 88,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      offset: Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
            ),
            // Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: items.map((e) {
                final selected = e.kind == kind;
                return SizedBox(
                  width: 88,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => controller.set(e.kind),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            e.icon,
                            size: 18,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            e.label,
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 12,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleItem {
  final IconData icon;
  final String label;
  final ThemeKind kind;
  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.kind,
  });
}
