import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900)); // simulate API
    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Signed in ✅ (mock)')));
  }

  InputDecoration _authDecoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: cs.surfaceContainerHigh,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final spacing = 15.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER: App Icon that switches with theme
                  Hero(
                    tag: 'app_icon',
                    child:
                        Image.asset(
                              isDark
                                  ? 'assets/icons/app_icon3_dark.png'
                                  : 'assets/icons/app_icon3.png',
                              height: 150,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                              duration: 350.ms,
                            ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CARD
                  Padding(
                        padding: const EdgeInsets.all(0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // EMAIL
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _authDecoration(
                                  context,
                                  'Email',
                                  Icons.email_outlined,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  final ok = RegExp(
                                    r'^\S+@\S+\.\S+$',
                                  ).hasMatch(v.trim());
                                  if (!ok) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              SizedBox(height: spacing),

                              // PASSWORD
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                decoration:
                                    _authDecoration(
                                      context,
                                      'Password',
                                      Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        tooltip: _obscure
                                            ? 'Show password'
                                            : 'Hide password',
                                      ),
                                    ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'Use at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              // REMEMBER + FORGOT
                              SizedBox(height: spacing),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v ?? true),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Remember me'),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Forgot password tapped',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),

                              // SIGN IN
                              SizedBox(height: spacing),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: CupertinoButton(
                                  padding: const EdgeInsets.all(20),
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_forward_rounded),
                                      SizedBox(width: 4),
                                      Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    // if (!_isLoading) login();
                                  },
                                ),
                              ),

                              // CREATE ACCOUNT
                              SizedBox(height: spacing),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Create account tapped'),
                                      ),
                                    );
                                  },
                                  child: const Text('Create account'),
                                ),
                              ),

                              // DIVIDER: Or sign in with
                              SizedBox(height: spacing + 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: cs.outlineVariant),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'Or sign in with',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: cs.outlineVariant),
                                  ),
                                ],
                              ),

                              // SOCIAL BUTTONS
                              SizedBox(height: spacing),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SocialRoundedButton(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.google,
                                        size: 18,
                                      ),
                                      label: 'Google',
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Google sign-in tapped',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SocialRoundedButton(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.facebookF,
                                        size: 18,
                                      ),
                                      label: 'Facebook',
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Facebook sign-in tapped',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .moveY(begin: 12, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 18),
                  // tiny footer
                  Text(
                    'By continuing you agree to our Terms & Privacy',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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

class _SocialRoundedButton extends StatelessWidget {
  const _SocialRoundedButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        icon: icon,
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outlineVariant),
          shape: const StadiumBorder(),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
