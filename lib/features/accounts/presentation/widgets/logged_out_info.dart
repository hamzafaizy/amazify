// lib/features/accounts/presentation/widgets/logged_out_info.dart
import 'package:amazify/features/accounts/presentation/widgets/top_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amazify/features/auth/presentation/widgets/auth_card.dart';

class LoggedOutInfo extends StatelessWidget {
  const LoggedOutInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              showTopCardDialog(
                context,
                AuthCard(
                  start: AuthStart.signUp, // Start on Sign Up
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            },
            icon: const Icon(Iconsax.user_edit),
            label: const Text('Sign Up'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              showTopCardDialog(
                context,
                AuthCard(
                  start: AuthStart.signIn, // Start on Sign In
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
            },
            icon: Icon(Iconsax.login, color: cs.surface),
            label: Text('Log in', style: TextStyle(color: cs.surface)),
          ),
        ),
      ],
    );
  }
}
