// CloseAccountButton.dart (or inside profile.dart)
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CloseAccountButton extends StatelessWidget {
  const CloseAccountButton({super.key, required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      icon: const Icon(Iconsax.close_circle),
      label: const Text('Close Account'),
      style:
          OutlinedButton.styleFrom(
            foregroundColor: cs.error,
            side: BorderSide(color: cs.error, width: 1.5),
            backgroundColor: cs.errorContainer.withOpacity(0.04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ).merge(
            ButtonStyle(
              overlayColor: WidgetStatePropertyAll(cs.error.withOpacity(0.08)),
            ),
          ),
      onPressed: () async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Close account?'),
              content: const Text(
                'This action is permanent and will remove your data. '
                'Are you sure you want to proceed?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.error,
                    foregroundColor: cs.onError,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Close Account'),
                ),
              ],
            );
          },
        );
        if (ok == true) onConfirm();
      },
    );
  }
}
