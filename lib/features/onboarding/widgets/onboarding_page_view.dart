import 'dart:ui';
import 'package:amazify/features/onboarding/widgets/onboarding_slide.dart';
import 'package:flutter/material.dart';
import 'package:amazify/core/constants/assets.dart' as app_assets;
import 'package:amazify/core/constants/text_strings.dart';

class OnboardingPageView extends StatelessWidget {
  final PageController pageCtrl;
  final ValueChanged<int> onPageChanged;

  const OnboardingPageView({
    super.key,
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
              OnboardingSlide(
                title: AppTexts.onboardTitle1,
                subtitle: AppTexts.onboardSubtitle1,
                lottieAsset: app_assets.onboard1Lottie,
              ),
              OnboardingSlide(
                title: AppTexts.onboardTitle2,
                subtitle: AppTexts.onboardSubtitle2,
                lottieAsset: app_assets.onboard2Lottie,
              ),
              OnboardingSlide(
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
