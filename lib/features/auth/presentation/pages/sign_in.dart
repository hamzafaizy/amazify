import 'package:amazify/core/assets/assets.dart' as app_assets;
import 'package:amazify/app/theme/app_pallete.dart';
import 'package:amazify/features/auth/presentation/pages/sign_up.dart';
import 'package:amazify/features/auth/presentation/pages/verify_email.dart';
import 'package:amazify/features/auth/presentation/widgets/agree_checkbox.dart';
import 'package:amazify/features/auth/presentation/widgets/input_decor_box.dart';
import 'package:amazify/features/auth/presentation/widgets/rounded_button.dart';
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
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = true;
  final bool _loading = false;
  bool create_account = false;
  bool _agreed = false;

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
      );
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
            child: create_account
                ? signInPage(context, isDark, cs, spacing)
                : _signUpPage(context, isDark, cs, spacing),
          ),
        ),
      ),
    );
  }
  //----------Sign Up Page----------
  // This is the page that appears when the user clicks "Create account"
  // It allows the user to enter their details to create a new account.
  // It includes fields for first name, last name, username, email, phone number,

  Stack _signUpPage(
    BuildContext context,
    bool isDark,
    ColorScheme cs,
    double spacing,
  ) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
            gradient:
                Theme.of(context).colorScheme.brightness == Brightness.dark
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
              color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
                  decoration: authDecoration(
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
                      authDecoration(
                        context,
                        'Password',
                        Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          tooltip: _obscure ? 'Show password' : 'Hide password',
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
                const SizedBox(height: 5),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    ),
                    const SizedBox(width: 6),
                    const Text('Remember me'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Forgot password tapped'),
                          ),
                        );
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),

                SizedBox(height: 5),
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
                            color: Theme.of(context).colorScheme.onPrimary,
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
                      setState(() {
                        create_account = true;
                      });
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
                SizedBox(height: spacing + 2),

                // SOCIAL BUTTONS
                SizedBox(height: spacing),
                Row(
                  children: [
                    Expanded(
                      child: SocialRoundedButton(
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
                      child: SocialRoundedButton(
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
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
    );
  }

  //----------Sign Up Page----------
  // This is the page that appears when the user clicks "Create account"
  // It allows the user to enter their details to create a new account.
  // It includes fields for first name, last name, username, email, phone number,
  // and password, along with a button to submit the form.

  Stack signInPage(
    BuildContext context,
    bool isDark,
    ColorScheme cs,
    double spacing,
  ) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
            gradient:
                Theme.of(context).colorScheme.brightness == Brightness.dark
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
              color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
              // This kind of give the background iOS style "Frosted Glass" effect,
              // it works for this particular color, might not for other
              // backgroundBlendMode: BlendMode.luminosity,
            ),
            child: Column(
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
                    margin: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () {
                        setState(() {
                          create_account = false;
                        });
                      },
                    ),
                  ),
                ),
                // HEADER: App Icon that switches with theme
                // Hero(
                //   tag: 'app_icon',
                //   child:
                //       Image.asset(
                //             isDark
                //                 ? 'assets/icons/app_icon3_dark.png'
                //                 : 'assets/icons/app_icon3.png',
                //             height: 150,
                //             fit: BoxFit.contain,
                //             alignment: Alignment.topLeft,
                //           )
                //           .animate()
                //           .fadeIn(duration: 400.ms)
                //           .scale(
                //             begin: const Offset(0.95, 0.95),
                //             end: const Offset(1, 1),
                //             duration: 350.ms,
                //           ),
                // ),
                const SizedBox(height: 1),
                Text(
                  "Let's Create Your account",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: spacing * 3),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
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
                SizedBox(height: spacing),
                TextFormField(
                  decoration: authDecoration(
                    context,
                    'Username',
                    Icons.person_outline,
                  ),
                  controller: _usernameCtrl,
                  keyboardType: TextInputType.name,
                ),

                SizedBox(height: spacing),
                TextFormField(
                  decoration: authDecoration(
                    context,
                    'Email',
                    Icons.email_outlined,
                  ),
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: spacing),
                TextFormField(
                  decoration: authDecoration(
                    context,
                    'Phone Number',
                    Icons.phone,
                  ),
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: spacing),

                // const SizedBox(height: 20),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration:
                      authDecoration(
                        context,
                        'Password',
                        Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          tooltip: _obscure ? 'Show password' : 'Hide password',
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
                AgreeToPolicies(
                  initialValue: _agreed,
                  privacyUrl: 'https://example.com/privacy',
                  termsUrl: 'https://example.com/terms',
                  onChanged: (v) => setState(() => _agreed = v),
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
                          "Create Account",
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
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

                // DIVIDER: Or sign in with
                SizedBox(height: spacing + 15),
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
                SizedBox(height: spacing + 2),

                // SOCIAL BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: SocialRoundedButton(
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
                      child: SocialRoundedButton(
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
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
    );
  }
}
