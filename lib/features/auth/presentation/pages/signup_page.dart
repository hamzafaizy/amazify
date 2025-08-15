import 'package:amazify/core/assets/assets.dart' as app_assets;
import 'package:amazify/core/theme/app_pallete.dart';
import 'package:amazify/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;

class SignInView extends StatefulWidget {
  const SignInView({super.key, this.closeModal});

  final Function? closeModal;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = true;
  bool _loading = false;

  late SMITrigger _successAnim;
  late SMITrigger _errorAnim;
  late SMITrigger _confettiAnim;

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onCheckRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    artboard.addController(controller!);
    _successAnim = controller.findInput<bool>("Check") as SMITrigger;
    _errorAnim = controller.findInput<bool>("Error") as SMITrigger;
  }

  void _onConfettiRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    artboard.addController(controller!);
    _confettiAnim =
        controller.findInput<bool>("Trigger explosion") as SMITrigger;
  }

  void login() {
    setState(() {
      _isLoading = true;
    });

    bool isEmailValid = _emailCtrl.text.trim().isNotEmpty;
    bool isPassValid = _passCtrl.text.trim().isNotEmpty;
    bool isValid = isEmailValid && isPassValid;

    Future.delayed(const Duration(seconds: 1), () {
      isValid ? _successAnim.fire() : _errorAnim.fire();
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
      if (isValid) _confettiAnim.fire();
    });

    if (isValid) {
      Future.delayed(const Duration(seconds: 4), () {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
        _emailCtrl.text = "";
        _passCtrl.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final spacing = 15.0;

    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor.withOpacity(0.7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    gradient:
                        Theme.of(context).colorScheme.brightness ==
                            Brightness.dark
                        ? AppPallete.darkGradient
                        : AppPallete.lightGradient,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(29),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // BoxShadow(
                        // color: AppPallete.shadow.withOpacity(0.3),
                        // offset: const Offset(0, 3),
                        // blurRadius: 5,
                        // ),
                        // BoxShadow(
                        //   color: AppPallete.shadow.withOpacity(0.3),
                        //   offset: const Offset(0, 30),
                        //   blurRadius: 30,
                        // ),
                      ],
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.2),
                      // This kind of give the background iOS style "Frosted Glass" effect,
                      // it works for this particular color, might not for other
                      // backgroundBlendMode: BlendMode.luminosity,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                                    alignment: Alignment.topLeft,
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .scale(
                                    begin: const Offset(0.95, 0.95),
                                    end: const Offset(1, 1),
                                    duration: 350.ms,
                                  ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to continue',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: _authDecoration(
                            context,
                            'Email',
                            Icons.email_outlined,
                          ),
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        // const SizedBox(height: 20),
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
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
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

                        SizedBox(height: spacing),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
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
                              if (!_isLoading) login();
                            },
                          ),
                        ),
                        // CREATE ACCOUNT
                        SizedBox(height: spacing + 10),
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Create account tapped'),
                                ),
                              );
                            },
                            child: Text(
                              'Create account',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),

                        // DIVIDER: Or sign in with
                        SizedBox(height: spacing + 15),
                        Row(
                          children: [
                            Expanded(child: Divider(color: cs.onSurface)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'Or sign in with',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: cs.onSurface),
                              ),
                            ),
                            Expanded(child: Divider(color: cs.onSurface)),
                          ],
                        ),
                        SizedBox(height: spacing + 2),

                        // SOCIAL BUTTONS
                        SizedBox(height: spacing),
                        Row(
                          children: [
                            Expanded(
                              child: _SocialRoundedButton(
                                icon: Image.asset(
                                  'assets/Images/google_logo.png',
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.contain,
                                ),
                                label: '',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Google sign-in tapped'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // const SizedBox(width: 20),
                            Expanded(
                              child: _SocialRoundedButton(
                                icon: Image.asset(
                                  'assets/Images/facebook_logo.png',
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.contain,
                                ),
                                label: '',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Facebook sign-in tapped'),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: spacing + 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: RiveAnimation.asset(
                              app_assets.checkRiv,
                              onInit: _onCheckRiveInit,
                            ),
                          ),
                        Positioned.fill(
                          child: SizedBox(
                            width: 500,
                            height: 500,
                            child: Transform.scale(
                              scale: 3,
                              child: RiveAnimation.asset(
                                app_assets.confettiRiv,
                                onInit: _onConfettiRiveInit,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(36 / 2),
                      onPressed: () {
                        widget.closeModal!();
                      },
                      minimumSize: Size(36, 36),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.7),
                          ),
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(36 / 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppPallete.shadow.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Common style for Auth Input fields email and password
  InputDecoration authInputStyle(BuildContext context, String iconName) {
    return InputDecoration(
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.2),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      contentPadding: const EdgeInsets.all(15),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Image.asset("assets/samples/ui/rive_app/images/$iconName.png"),
      ),
    );
  }
}

// ---------------Text Field Decoration for Auth Inputs----------------
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

//------social button widget for rounded buttons with icon and label
class _SocialRoundedButton extends StatelessWidget {
  const _SocialRoundedButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.diameter = 56, // tweak size here
    this.filled = false, // set true for filled circle
  });

  final Widget icon;
  final String label; // used for semantics/tooltip
  final VoidCallback onPressed;
  final double diameter;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            fixedSize: Size.square(diameter), // exact width & height
            padding: EdgeInsets.zero, // center the icon
            side: BorderSide(color: cs.onSurface.withOpacity(0.25)),
            foregroundColor: filled ? cs.onPrimary : cs.onSurface,
            backgroundColor: filled ? cs.primary : null,
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}
