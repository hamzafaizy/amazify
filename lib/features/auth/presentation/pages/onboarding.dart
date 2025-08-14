// lib/features/auth/presentation/pages/onboarding.dart
import 'dart:ui';
import 'package:amazify/core/assets/assets.dart' as app_assets;
import 'package:amazify/core/constants/text_strings.dart';
import 'package:amazify/core/theme/app_pallete.dart';
import 'package:amazify/core/utils/device_utils.dart';
import 'package:amazify/features/auth/presentation/pages/signup_page.dart';
import 'package:amazify/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart' hide Image;

// ───────────────────────── Main OnBoardingView ─────────────────────────

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key, this.closeModal});
  final Function? closeModal;

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _index = 0;
  AnimationController? _signInAnimController;
  late RiveAnimationController _btnController;
  bool showSignInView = false;

  @override
  void initState() {
    super.initState();
    _signInAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1,
      vsync: this,
    );
    _btnController = OneShotAnimation("active", autoplay: false);
    const springDesc = SpringDescription(mass: 0.1, stiffness: 40, damping: 5);
    _btnController.isActiveChanged.addListener(() {
      if (!_btnController.isActive) {
        final springAnim = SpringSimulation(springDesc, 0, 1, 0);
        _signInAnimController?.animateWith(springAnim);
      }
    });
  }

  @override
  void dispose() {
    _signInAnimController?.dispose();
    _btnController.dispose();
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
      setState(() {
        showSignInView = true;
      });
      _signInAnimController?.forward();
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _TopRow(isLast: isLast, onSkip: _skip, onSurface: onSurface),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _OnboardingPageView(
                      pageCtrl: _pageCtrl,
                      onPageChanged: (i) => setState(() => _index = i),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _BottomControls(
                    index: _index,
                    onSurface: onSurface,
                    isLast: isLast,
                    onNext: _goNext,
                  ),
                ],
              ),
            ),
          ),
          if (showSignInView)
            Container(
              color: theme.colorScheme.surface.withOpacity(0.9),
              child: SignInView(
                closeModal: () {
                  setState(() {
                    showSignInView = false;
                  });
                  _signInAnimController?.reverse();
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Background Widget ─────────────────────────

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Center(
            child: Image.asset(
              app_assets.spline,
              fit: BoxFit.none,
              width: DeviceUtils.getScreenWidth(context) * 0.7,
              height: DeviceUtils.getScreenHeight(context) * 0.7,
            ),
          ),
        ),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: const RiveAnimation.asset(app_assets.shapesRiv),
        ),
      ],
    );
  }
}

// ───────────────────────── Top Row Widget ─────────────────────────

class _TopRow extends StatelessWidget {
  final bool isLast;
  final VoidCallback onSkip;
  final Color onSurface;

  const _TopRow({
    required this.isLast,
    required this.onSkip,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        if (isLast)
          TextButton(
            onPressed: onSkip,
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
    );
  }
}

// ───────────────────────── PageView Widget ─────────────────────────

class _OnboardingPageView extends StatelessWidget {
  final PageController pageCtrl;
  final ValueChanged<int> onPageChanged;

  const _OnboardingPageView({
    required this.pageCtrl,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayColor = theme.brightness == Brightness.light
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.25);
    final borderColor = theme.brightness == Brightness.light
        ? Colors.black.withOpacity(0.16)
        : Colors.white.withOpacity(0.25);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: PageView(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            children: const [
              _OnboardSlide(
                title: AppTexts.onboardTitle1,
                subtitle: AppTexts.onboardSubtitle1,
                lottieAsset: app_assets.onboard1Lottie,
              ),
              _OnboardSlide(
                title: AppTexts.onboardTitle2,
                subtitle: AppTexts.onboardSubtitle2,
                lottieAsset: app_assets.onboard2Lottie,
              ),
              _OnboardSlide(
                title: AppTexts.onboardTitle3,
                subtitle: AppTexts.onboardSubtitle3,
                lottieAsset: app_assets.onboard3Lottie,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Bottom Controls Widget ─────────────────────────

class _BottomControls extends StatelessWidget {
  final int index;
  final Color onSurface;
  final bool isLast;
  final VoidCallback onNext;

  const _BottomControls({
    required this.index,
    required this.onSurface,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.light
        ? Colors.black.withOpacity(0.16)
        : Colors.white.withOpacity(0.25);

    return Row(
      children: [
        _Dots(current: index, count: 3),
        const Spacer(),
        GestureDetector(
          onTap: onNext,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    );
  }
}

// ───────────────────────── Slide Widget ─────────────────────────

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

// ───────────────────────── Dots Widget ─────────────────────────

class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.count});
  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
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
