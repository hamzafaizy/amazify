import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:amazify/core/constants/assets.dart' as app_assets;
import 'package:amazify/core/utils/device_utils.dart';

class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

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
