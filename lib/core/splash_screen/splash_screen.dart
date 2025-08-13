import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.lightLogo, // e.g. assets/icons/app_icon3.png
    required this.darkLogo, // e.g. assets/icons/app_icon3_dark.png
    required this.next, // your Home widget
    this.audioAsset = 'audio/whoosh.mp3', // assets/audio/whoosh.mp3
    this.totalMs = 10000, // total splash time (fade + hold + zoom)
    this.bgLight = Colors.white,
    this.bgDark = Colors.black,
    this.zoomScale = 50, // how big the final zoom gets
  });

  final String lightLogo;
  final String darkLogo;
  final Widget next;
  final String audioAsset;
  final int totalMs;
  final Color bgLight;
  final Color bgDark;
  final double zoomScale;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _c;

  // Phases (as fractions of totalMs)
  late final double _fadeEnd; // 0.0 -> fadeEnd
  late final double _zoomStart; // zoom & home fade start at zoomStart -> 1.0

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoZoom;
  late final Animation<double> _homeOpacity;

  @override
  void initState() {
    super.initState();

    // Split total duration into phases: 45% fade-in, 20% hold, 35% zoom+reveal
    _fadeEnd = 0.45;
    _zoomStart = 0.65;

    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.totalMs),
    );

    _logoOpacity = CurvedAnimation(
      parent: _c,
      curve: Interval(0.0, _fadeEnd, curve: Curves.easeIn),
    );

    _logoZoom = Tween<double>(begin: 1.0, end: widget.zoomScale).animate(
      CurvedAnimation(
        parent: _c,
        curve: Interval(_zoomStart, 1.0, curve: Curves.easeInQuad),
      ),
    );

    _homeOpacity = CurvedAnimation(
      parent: _c,
      curve: Interval(_zoomStart, 1.0, curve: Curves.easeOut),
    );

    _run();
  }

  Future<void> _run() async {
    // Start audio (don’t await to avoid blocking UI)
    _player.play(AssetSource(widget.audioAsset), mode: PlayerMode.lowLatency);

    // Drive the whole sequence
    await _c.forward().orCancel;

    if (!mounted) return;

    // After the visual is complete, switch the route (no visible transition)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.next,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logo = isDark ? widget.darkLogo : widget.lightLogo;
    final bg = isDark ? widget.bgDark : widget.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Home fades in underneath during the final phase
              IgnorePointer(
                child: Opacity(opacity: _homeOpacity.value, child: widget.next),
              ),

              // Logo: first fades in, then zooms toward the screen
              Center(
                child: Transform.scale(
                  scale: _logoZoom.value,
                  child: Opacity(
                    // stays at 1 after fade completes
                    opacity: _logoOpacity.value.clamp(0.0, 1.0),
                    child: Image.asset(
                      logo,
                      width: MediaQuery.of(context).size.width * 0.55,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
