import 'package:flutter/material.dart';
import 'package:amazify/app/theme/custom_theme/glass_backdrop.dart';
import 'package:amazify/app/theme/custom_theme/theme_controller.dart';
import 'package:amazify/app/theme/theme.dart';
import 'package:amazify/core/splash_screen/splash_screen.dart';
import 'package:amazify/features/onboarding/pages/onboarding.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ThemeController _controller = ThemeController();

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          Widget home = const SplashPage(
            lightLogo: 'assets/icons/app_icon3.png',
            darkLogo: 'assets/icons/app_icon3_dark.png',
            audioAsset: 'audio/Netflix-Intro-Sound-Effect.mp3',
            totalMs: 5000,
            next: OnBoardingView(),
          );

          if (_controller.kind == ThemeKind.glass) {
            home = GlassBackdrop(child: home);
          }

          return MaterialApp(
            title: 'E-Commerce',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            home: home,
          );
        },
      ),
    );
  }
}
