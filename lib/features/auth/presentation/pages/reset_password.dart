// lib/features/auth/presentation/pages/password_rest.dart
import 'package:amazify/features/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({
    super.key,
    this.email,
    this.animationAsset = 'assets/lottie/success.json',
    this.onDone,
    this.onResend,
  });

  /// (Optional) Show which email received the link
  final String? email;

  /// Path to your success Lottie file
  final String animationAsset;

  /// Optional callback when Done is pressed
  final VoidCallback? onDone;

  /// Optional callback for Resend email
  final VoidCallback? onResend;

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
                  // Lottie success
                  Semantics(
                    label: 'Password reset email sent',
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
                    'Password reset email',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle (shows email if provided)
                  Text(
                    email == null
                        ? 'We’ve sent a password reset link to your email.'
                        : 'We’ve sent a password reset link to\n$email',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sub sub title
                  Text(
                    'Open the email and follow the instructions to create a new password. If you don’t see it, check your spam folder.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Done button (blue ElevatedButton)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          onDone ??
                          () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const OnBoardingView(),
                              ),
                            );
                          },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Resend text button
                  TextButton(
                    onPressed:
                        onResend ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password reset email re-sent.'),
                            ),
                          );
                        },
                    child: const Text('Resend email'),
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
