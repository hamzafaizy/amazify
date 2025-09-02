import 'package:flutter/material.dart';

class OnboardingTopRow extends StatelessWidget {
  final bool isLast;
  final VoidCallback onSkip;
  final Color onSurface;

  const OnboardingTopRow({
    super.key,
    required this.isLast,
    required this.onSkip,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        if (isLast)
          TextButton(
            onPressed: onSkip,
            child: Text(
              "Skip",
              style: TextStyle(
                color: onSurface.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
