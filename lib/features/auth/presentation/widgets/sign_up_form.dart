import 'package:amazify/features/auth/presentation/widgets/agree_checkbox.dart';
import 'package:amazify/features/auth/presentation/widgets/input_decor_box.dart';
import 'package:amazify/features/auth/presentation/widgets/social_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.usernameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.agreed,
    required this.onToggleObscure,
    required this.onAgreeChanged,
    required this.onBackToSignIn,
    required this.onSubmit,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController usernameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;

  final bool obscure;
  final bool agreed;

  final VoidCallback onToggleObscure;
  final ValueChanged<bool> onAgreeChanged;
  final VoidCallback onBackToSignIn;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const spacing = 15.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(50),
            ),
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(bottom: 0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: onBackToSignIn,
            ),
          ),
        ),

        Text(
          "Let's Create Your account",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: spacing),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: firstNameCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
                decoration: const InputDecoration(
                  labelText: 'First name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: lastNameCtrl,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.familyName],
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: spacing),
        TextFormField(
          controller: usernameCtrl,
          keyboardType: TextInputType.name,
          decoration: authDecoration(context, 'Username', Iconsax.user),
        ),

        const SizedBox(height: spacing),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: authDecoration(context, 'Email', Icons.email_outlined),
        ),

        const SizedBox(height: spacing),
        TextFormField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: authDecoration(context, 'Phone Number', Iconsax.call),
        ),

        const SizedBox(height: spacing),
        TextFormField(
          controller: passCtrl,
          obscureText: obscure,
          decoration: authDecoration(context, 'Password', Iconsax.lock)
              .copyWith(
                suffixIcon: IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(obscure ? Iconsax.eye_slash : Iconsax.eye),
                  tooltip: obscure ? 'Show password' : 'Hide password',
                ),
              ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Use at least 6 characters';
            return null;
          },
        ),

        AgreeToPolicies(
          initialValue: agreed,
          privacyUrl: 'https://example.com/privacy',
          termsUrl: 'https://example.com/terms',
          onChanged: onAgreeChanged,
        ),

        CupertinoButton.filled(
          padding: const EdgeInsets.all(20),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          onPressed: onSubmit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_forward_rounded,
                color: Theme.of(context).colorScheme.surface,
              ),
              SizedBox(width: 4),
              Text(
                'Create Account',
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

        const SizedBox(height: spacing),

        // Row(
        //   children: [
        //     Expanded(child: Divider(color: cs.onSurface)),
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //       child: Text(
        //         'Or sign in with',
        //         style: Theme.of(
        //           context,
        //         ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
        //       ),
        //     ),
        //     Expanded(child: Divider(color: cs.onSurface)),
        //   ],
        // ),
        // const SizedBox(height: spacing + 2),

        // Row(
        //   children: [
        //     Expanded(child: SocialRoundedButton.google()),
        //     const SizedBox(width: spacing),
        //     Expanded(child: SocialRoundedButton.facebook()),
        //   ],
        // ),
      ],
    );
  }
}
