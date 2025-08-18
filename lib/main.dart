import 'package:flutter/material.dart';
import 'package:amazify/app/theme/custom_theme/glass_backdrop.dart';
import 'package:amazify/app/theme/custom_theme/theme_controller.dart';
import 'package:amazify/app/theme/theme.dart';
import 'package:amazify/features/onboarding/onboarding.dart';
import 'package:amazify/core/splash_screen/splash_screen.dart';

void main() => runApp(const App());

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
          // Pick the ThemeData for the current mode
          final ThemeData theme = _controller.themeData;

          // Build your app's home. We only wrap with GlassBackdrop in glass mode.
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
            // Single source of truth: we switch the full theme instead of using themeMode/darkTheme.
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
