import 'package:amazify/features/auth/presentation/pages/forget_password.dart';
import 'package:amazify/features/auth/presentation/widgets/input_decor_box.dart';
import 'package:amazify/features/auth/presentation/widgets/social_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({
    super.key,
    required this.header,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.rememberMe,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onRememberChanged,
    required this.onForgotPressed,
    required this.onSubmit,
    required this.onCreateAccountPressed,
  });

  final Widget header;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool rememberMe;
  final bool isLoading;

  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgotPressed;
  final VoidCallback onSubmit;
  final VoidCallback onCreateAccountPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const spacing = 15.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        const SizedBox(height: 1),
        Text(
          'Welcome back',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 10),

        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: authDecoration(context, 'Email', Icons.email_outlined),
        ),
        const SizedBox(height: 18),

        TextFormField(
          controller: passCtrl,
          obscureText: obscure,
          decoration: authDecoration(context, 'Password', Icons.lock_outline)
              .copyWith(
                suffixIcon: IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  tooltip: obscure ? 'Show password' : 'Hide password',
                ),
              ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Use at least 6 characters';
            return null;
          },
        ),

        const SizedBox(height: 5),
        Row(
          children: [
            Checkbox(value: rememberMe, onChanged: onRememberChanged),
            const SizedBox(width: 6),
            const Text('Remember me'),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgetPasswordPage()),
              ),
              child: const Text('Forgot password?'),
            ),
          ],
        ),

        const SizedBox(height: 5),
        CupertinoButton.filled(
          padding: const EdgeInsets.all(20),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          onPressed: isLoading ? null : onSubmit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                color: Theme.of(context).colorScheme.surface,
              ),
              SizedBox(width: 4),
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: spacing + 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.onSurface,
              side: BorderSide(color: cs.onSurface),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onCreateAccountPressed,
            child: Text(
              'Create account',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),

        const SizedBox(height: spacing + 15),
        Row(
          children: [
            Expanded(child: Divider(color: cs.onSurface)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Or sign in with',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            ),
            Expanded(child: Divider(color: cs.onSurface)),
          ],
        ),
        const SizedBox(height: spacing + 2),

        Row(
          children: [
            Expanded(child: SocialRoundedButton.google()),
            const SizedBox(width: spacing),
            Expanded(child: SocialRoundedButton.facebook()),
          ],
        ),
      ],
    );
  }
}
