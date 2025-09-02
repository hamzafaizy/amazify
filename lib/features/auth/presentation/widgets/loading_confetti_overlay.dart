import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

class LoadingConfettiOverlay extends StatelessWidget {
  const LoadingConfettiOverlay({
    super.key,
    required this.isLoading,
    required this.checkAsset,
    required this.confettiAsset,
    this.onCheckInit,
    this.onConfettiInit,
  });

  final bool isLoading;
  final String checkAsset;
  final String confettiAsset;
  final void Function(Artboard)? onCheckInit;
  final void Function(Artboard)? onConfettiInit;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 100,
                height: 100,
                child: RiveAnimation.asset(checkAsset, onInit: onCheckInit),
              ),
            Positioned.fill(
              child: Transform.scale(
                scale: 3,
                child: RiveAnimation.asset(
                  confettiAsset,
                  onInit: onConfettiInit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
