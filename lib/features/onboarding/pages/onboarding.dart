import 'package:amazify/app/presentation/widgets/bottom_nav_bar.dart';
// REPLACED: import 'package:amazify/features/auth/presentation/pages/sign_in.dart';
import 'package:amazify/features/auth/presentation/pages/auth.dart'; // ⬅️ new
import 'package:amazify/features/onboarding/widgets/onboarding_background.dart';
import 'package:amazify/features/onboarding/widgets/onboarding_bottom_controls.dart';
import 'package:amazify/features/onboarding/widgets/onboarding_page_view.dart';
import 'package:amazify/features/onboarding/widgets/onboarding_top_row.dart';

import 'package:flutter/material.dart';

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
  bool showSignInView = false;

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
      setState(() => showSignInView = true);
    }
  }

  void _skip() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const RootNav()));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == 2;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onSurface = cs.onSurface;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          const OnboardingBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  OnboardingTopRow(
                    isLast: isLast,
                    onSkip: _skip,
                    onSurface: onSurface,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: OnboardingPageView(
                      pageCtrl: _pageCtrl,
                      onPageChanged: (i) => setState(() => _index = i),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OnboardingBottomControls(
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
            AuthPage(
              // ⬅️ replaced SignInView with AuthPage
              closeModal: () => setState(() => showSignInView = false),
            ),
        ],
      ),
    );
  }
}
