// lib/features/auth/presentation/pages/verify_email.dart
import 'package:amazify/features/auth/presentation/pages/verify_success.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({
    super.key,
    this.supportEmail = 'support@amazify.com',
    this.animationAsset = 'assets/lottie/verify_email.json',
    this.onContinue,
    this.onResend,
  });

  /// Shown under the title
  final String supportEmail;

  /// Lottie asset path. Put your .json file here and add to pubspec.yaml
  final String animationAsset;

  /// Optional action when "Continue" is pressed
  final VoidCallback? onContinue;

  /// Optional action when "Resend email" is pressed
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lottie animation
                  Semantics(
                    label: 'Email verification animation',
                    child: Lottie.asset(
                      animationAsset,
                      height: 220,
                      repeat: true,
                      frameRate: FrameRate.max,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'verify your email address!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle (support email)
                  Text(
                    supportEmail,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sub-subtitle
                  Text(
                    // If you prefer the exact wording you provided, replace the string below with:
                    // 'Conngratulations! YOur account awaits: verify you email .......'
                    'Congratulations! Your account awaits — verify your email to continue.',
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
                            // Default action: pop if possible
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const SuccessPage(),
                              ),
                            );
                          },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        // Uses theme's primary by default; keep it "blue" via theme
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Resend button
                  TextButton(
                    onPressed:
                        onResend ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification email re-sent.'),
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
