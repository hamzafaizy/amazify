import 'package:flutter/material.dart';

class SocialRoundedButton extends StatelessWidget {
  const SocialRoundedButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.label = '',
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String label;

  factory SocialRoundedButton.google() => SocialRoundedButton(
    icon: Image.asset(
      'assets/Images/google_logo.png',
      height: 24,
      width: 24,
      fit: BoxFit.contain,
    ),
  );

  factory SocialRoundedButton.facebook() => SocialRoundedButton(
    icon: Image.asset(
      'assets/Images/facebook_logo.png',
      height: 24,
      width: 24,
      fit: BoxFit.contain,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.onSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed:
            onPressed ??
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Social sign-in tapped')),
            ),
        child: icon,
      ),
    );
  }
}
