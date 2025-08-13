// lib/features/auth/presentation/pages/onboarding.dart
import 'dart:ui';
import 'package:amazify/core/assets/assets.dart' as app_assets;
import 'package:amazify/features/auth/presentation/pages/signup_page.dart';
import 'package:amazify/home_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});
  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final _pageCtrl = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_index < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      // Last page -> Sign Up
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const SignInView()));
    }
  }

  void _skip() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == 2;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onSurface = cs.onSurface;

    // Theme-aware translucent surfaces (keeps any Rive background visible)
    final overlayColor = theme.brightness == Brightness.light
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.25);
    final borderColor = theme.brightness == Brightness.light
        ? Colors.black.withOpacity(0.06)
        : Colors.white.withOpacity(0.10);
    final pillColor = theme.brightness == Brightness.light
        ? Colors.black.withOpacity(0.45)
        : Colors.white.withOpacity(0.12);

    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Rive behind stays visible
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Top row — show Skip only on the last page
              Row(
                children: [
                  const Spacer(),
                  if (isLast)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: onSurface.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Glass card with PageView
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: overlayColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: PageView(
                        controller: _pageCtrl,
                        onPageChanged: (i) => setState(() => _index = i),
                        children: const [
                          _OnboardSlide(
                            title: "Discover New Items",
                            subtitle:
                                "Browse curated gadgets with real-time deals and a clean UI.",
                            lottieAsset: app_assets.onboard1Lottie,
                          ),
                          _OnboardSlide(
                            title: "Secure Checkout",
                            subtitle:
                                "Fast, safe payments with saved addresses and 1-tap buy.",
                            lottieAsset: app_assets.onboard2Lottie,
                          ),
                          _OnboardSlide(
                            title: "Track & Enjoy",
                            subtitle:
                                "Live order tracking and proactive delivery updates.",
                            lottieAsset: app_assets.onboard3Lottie,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom controls: dots (left) + Next/Sign Up (right)
              Row(
                children: [
                  _Dots(current: _index, count: 3),
                  const Spacer(),
                  GestureDetector(
                    onTap: _goNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLast ? "Sign Up" : "Next",
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? Icons.person_add_alt_1_rounded
                                : Icons.arrow_forward_rounded,
                            color: onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Slides ─────────────────────────

class _OnboardSlide extends StatelessWidget {
  const _OnboardSlide({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
  });

  final String title;
  final String subtitle;
  final String lottieAsset;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final subColor = onSurface.withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lottie illustration (centered, fills available space)
          Expanded(
            child: Center(
              child: Lottie.asset(
                lottieAsset,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: subColor,
              fontFamily: "Inter",
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Dots ─────────────────────────

class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.count});
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: active ? 50 : 8,
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.blue.withOpacity(0.35),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
