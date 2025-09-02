import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
  });

  final String title;
  final String subtitle;
  final String lottieAsset;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final subColor = onSurface.withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Lottie.asset(
                lottieAsset,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: subColor,
              fontFamily: "Inter",
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
