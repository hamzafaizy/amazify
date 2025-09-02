// lib/features/accounts/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:amazify/features/catalog/presentation/widgets/circular_fab_box.dart';

class ProfileHeaderBackground extends StatelessWidget {
  const ProfileHeaderBackground({super.key, required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withOpacity(0.85)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Stack(
        children: [
          Positioned(top: -110, right: -150, child: circular_fadbox(cs: cs)),
          Positioned(top: 120, right: -120, child: circular_fadbox(cs: cs)),
        ],
      ),
    );
  }
}
