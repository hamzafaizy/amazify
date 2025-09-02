import 'package:amazify/features/onboarding/widgets/onboarding_dots.dart';
import 'package:flutter/material.dart';

class OnboardingBottomControls extends StatelessWidget {
  final int index;
  final Color onSurface;
  final bool isLast;
  final VoidCallback onNext;

  const OnboardingBottomControls({
    super.key,
    required this.index,
    required this.onSurface,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.light
        ? Colors.black.withOpacity(0.16)
        : Colors.white.withOpacity(0.25);

    return Row(
      children: [
        OnboardingDots(current: index, count: 3),
        const Spacer(),
        GestureDetector(
          onTap: onNext,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLast ? "Sign Up" : "Next",
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLast
                      ? Icons.person_add_alt_1_rounded
                      : Icons.arrow_forward_rounded,
                  color: onSurface,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
