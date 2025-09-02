import 'package:flutter/material.dart';

class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.current, required this.count});
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: active ? 50 : 8,
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.blue.withOpacity(0.35),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
