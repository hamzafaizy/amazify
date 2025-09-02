// lib/features/accounts/presentation/widgets/profile_avatar.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.loggedIn,
    required this.onEditTap,
  });

  final bool loggedIn;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: cs.onSurface.withOpacity(0.7), width: 1),
            color: cs.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: loggedIn
              ? const CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/icons/app_icon3.png'),
                )
              : CircleAvatar(
                  radius: 48,
                  backgroundColor: cs.onPrimary,
                  child: Icon(
                    Iconsax.user,
                    size: 48,
                    color: cs.onPrimaryContainer,
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: onEditTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.edit, size: 16, color: cs.onPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
