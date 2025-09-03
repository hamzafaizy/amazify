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

// 🔽 Add Firebase
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _checkReady = false;
  bool _confettiReady = false;

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
      _checkReady = true;
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
      _confettiReady = true;
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

  // ───────────────────────── Firebase Helpers ─────────────────────────

  void _setLoading(bool v) => setState(() => _isLoading = v);

  void _playSuccess() {
    if (_checkReady) {
      try {
        _successAnim.fire();
      } catch (_) {}
    }
    if (_confettiReady) {
      try {
        _confettiAnim.fire();
      } catch (_) {}
    }
  }

  void _playError() {
    if (_checkReady) {
      try {
        _errorAnim.fire();
      } catch (_) {}
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'That email is already in use.';
      case 'weak-password':
        return 'Password is too weak (min 6 chars).';
      case 'operation-not-allowed':
        return 'This sign-in method is disabled.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validateSignInFields() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _toast('Enter email & password');
      return false;
    }
    return true;
  }

  bool _validateSignUpFields() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (!_agreed) {
      _toast('Please agree to the terms to continue');
      return false;
    }
    if (email.isEmpty || pass.isEmpty) {
      _toast('Email & password are required');
      return false;
    }
    if (pass.length < 6) {
      _toast('Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  Future<void> _onSignIn() async {
    if (_isLoading) return;
    if (!_validateSignInFields()) {
      _playError();
      return;
    }

    _setLoading(true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      _playSuccess();
      // small delay to let animation feel good
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const RootNav()));

      _emailCtrl.clear();
      _passCtrl.clear();
    } on FirebaseAuthException catch (e) {
      _playError();
      _toast(_mapFirebaseError(e));
    } catch (_) {
      _playError();
      _toast('Something went wrong. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _onSignUp() async {
    if (_isLoading) return;
    if (!_validateSignUpFields()) {
      _playError();
      return;
    }

    _setLoading(true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // Optional profile display name (first + last or username)
      final displayName =
          (_firstNameCtrl.text.trim().isNotEmpty ||
              _lastNameCtrl.text.trim().isNotEmpty)
          ? '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim()
          : _usernameCtrl.text.trim();
      if (displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }

      // Send verification email
      await cred.user?.sendEmailVerification();

      _playSuccess();
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailPage()),
      );
    } on FirebaseAuthException catch (e) {
      _playError();
      _toast(_mapFirebaseError(e));
    } catch (_) {
      _playError();
      _toast('Could not create account. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  // ───────────────────────── UI Shell (unchanged visuals) ─────────────────────────

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
                  onForgotPressed: () async {
                    // Optional: send reset link if email valid
                    final email = _emailCtrl.text.trim();
                    if (email.isEmpty) {
                      _toast('Enter your email to reset password');
                      return;
                    }
                    try {
                      _setLoading(true);
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: email,
                      );
                      _toast('Password reset email sent');
                    } on FirebaseAuthException catch (e) {
                      _toast(_mapFirebaseError(e));
                    } finally {
                      _setLoading(false);
                    }
                  },
                  onSubmit: _onSignIn, // ✅ Firebase Sign-In
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
                  onSubmit: _onSignUp, // ✅ Firebase Sign-Up
                ),
        ),
      ),
    );
  }
}
