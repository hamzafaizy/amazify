// lib/features/auth/presentation/pages/success.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({
    super.key,
    this.animationAsset = 'assets/lottie/success.json',
    this.onContinue,
  });

  /// Path to your Lottie success animation
  final String animationAsset;

  /// Optional callback when user taps "Continue"
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Success Lottie
                  Semantics(
                    label: 'Account created successfully',
                    child: Lottie.asset(
                      animationAsset,
                      height: 220,
                      repeat: false,
                      frameRate: FrameRate.max,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Your account successfully created!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    // Exact text requested:
                    // "Welcome to Your Ultimate Shopping Destination Your Account is created Unleash the joy of seamless online shopping!"
                    'Welcome to Your Ultimate Shopping Destination — Your account is created. Unleash the joy of seamless online shopping!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          onContinue ??
                          () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
