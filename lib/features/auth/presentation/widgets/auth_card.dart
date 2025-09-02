// lib/features/auth/presentation/widgets/auth_card.dart
import 'package:amazify/app/presentation/widgets/bottom_nav_bar.dart';
import 'package:amazify/app/theme/app_pallete.dart';
import 'package:amazify/core/constants/assets.dart' as app_assets;
import 'package:amazify/features/auth/presentation/pages/verify_email.dart';
import 'package:amazify/features/auth/presentation/widgets/loading_confetti_overlay.dart';
import 'package:amazify/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:amazify/features/auth/presentation/widgets/sign_up_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;

/// Public start mode to choose the initial card.
enum AuthStart { signIn, signUp }

// Internal mode enum (kept private)
enum _AuthMode { signIn, signUp }

class AuthCard extends StatefulWidget {
  const AuthCard({
    super.key,
    this.onClose,
    this.start = AuthStart.signIn, // Choose which card shows first
  });

  final VoidCallback? onClose;
  final AuthStart start;

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _formKey = GlobalKey<FormState>();

  // Shared controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = true;
  bool _agreed = false;
  bool _isLoading = false;

  _AuthMode _mode = _AuthMode.signIn;

  late SMITrigger _successAnim;
  late SMITrigger _errorAnim;
  late SMITrigger _confettiAnim;

  @override
  void initState() {
    super.initState();
    // Map public start → internal mode
    _mode = (widget.start == AuthStart.signUp)
        ? _AuthMode.signUp
        : _AuthMode.signIn;
  }

  // Rive: check tick/init
  void _onCheckRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    if (controller != null) {
      artboard.addController(controller);
      _successAnim = controller.findInput<bool>("Check") as SMITrigger;
      _errorAnim = controller.findInput<bool>("Error") as SMITrigger;
    }
  }

  // Rive: confetti init
  void _onConfettiRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    if (controller != null) {
      artboard.addController(controller);
      _confettiAnim =
          controller.findInput<bool>("Trigger explosion") as SMITrigger;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _goVerifyAndSimulateLogin() {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Navigate to verify-email page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
    );

    // Fake validation for demo UX
    final isValid =
        _emailCtrl.text.trim().isNotEmpty && _passCtrl.text.trim().isNotEmpty;

    // Trigger check/error after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        isValid ? _successAnim.fire() : _errorAnim.fire();
      }
    });

    // Stop loading + confetti
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (isValid) _confettiAnim.fire();
    });

    // Complete to app root if valid
    if (isValid) {
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const RootNav()));
        _emailCtrl.clear();
        _passCtrl.clear();
      });
    }
  }

  Widget _cardShell({required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: cs.onSurface.withOpacity(0.1), width: 3),
            borderRadius: BorderRadius.circular(20),
            gradient: isDark
                ? AppPallete.darkGradient
                : AppPallete.lightGradient,
          ),
          child: Container(
            padding: const EdgeInsets.all(29),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: cs.surface.withOpacity(0.2),
            ),
            child: child,
          ),
        ),

        // Loading overlay + Rive hooks
        LoadingConfettiOverlay(
          isLoading: _isLoading,
          checkAsset: app_assets.checkRiv,
          confettiAsset: app_assets.confettiRiv,
          onCheckInit: _onCheckRiveInit,
          onConfettiInit: _onConfettiRiveInit,
        ),

        // Close (X) button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(18),
              onPressed: widget.onClose,
              minSize: 36,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: cs.primary.withOpacity(0.7),
                  ),
                  color: cs.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(Icons.close, color: cs.onSurface, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final header = Hero(
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
    );

    return _cardShell(
      child: Form(
        key: _formKey,
        child: AnimatedSwitcher(
          duration: 250.ms,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _mode == _AuthMode.signIn
              ? SignInForm(
                  key: const ValueKey('signIn'),
                  header: header,
                  emailCtrl: _emailCtrl,
                  passCtrl: _passCtrl,
                  obscure: _obscure,
                  rememberMe: _rememberMe,
                  isLoading: _isLoading,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onRememberChanged: (v) =>
                      setState(() => _rememberMe = v ?? true),
                  onForgotPressed: () {
                    // You may navigate to forgot page here if needed.
                  },
                  onSubmit: _goVerifyAndSimulateLogin,
                  onCreateAccountPressed: () =>
                      setState(() => _mode = _AuthMode.signUp),
                )
              : SignUpForm(
                  key: const ValueKey('signUp'),
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                  usernameCtrl: _usernameCtrl,
                  emailCtrl: _emailCtrl,
                  phoneCtrl: _phoneCtrl,
                  passCtrl: _passCtrl,
                  obscure: _obscure,
                  agreed: _agreed,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onAgreeChanged: (v) => setState(() => _agreed = v),
                  onBackToSignIn: () =>
                      setState(() => _mode = _AuthMode.signIn),
                  onSubmit: _goVerifyAndSimulateLogin,
                ),
        ),
      ),
    );
  }
}
