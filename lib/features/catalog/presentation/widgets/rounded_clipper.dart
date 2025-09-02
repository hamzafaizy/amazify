import 'package:flutter/material.dart';

class RoundedShape extends CustomClipper<Path> {
  const RoundedShape();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    final firstCurve = Offset(0, size.height - 20);
    final secondCurve = Offset(30, size.height - 20);
    path.quadraticBezierTo(
      firstCurve.dx,
      firstCurve.dy,
      secondCurve.dx,
      secondCurve.dy,
    );

    final linefirstCurve = Offset(0, size.height - 20);
    final linesecondCurve = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(
      linefirstCurve.dx,
      linefirstCurve.dy,
      linesecondCurve.dx,
      linesecondCurve.dy,
    );

    final thirdCurve = Offset(size.width, size.height - 20);
    final lastthirdCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(
      thirdCurve.dx,
      thirdCurve.dy,
      lastthirdCurve.dx,
      lastthirdCurve.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
