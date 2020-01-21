import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class RRectPainter extends CustomPainter {
  Color baseColor;
  double strokeWidth;
  Offset center;
  double radius;
  double cornerRadius;

  RRectPainter({@required this.baseColor, @required this.strokeWidth,@required this.cornerRadius});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = baseColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth;

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2);


    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromCircle(center: center, radius: radius),
            topRight: Radius.circular(cornerRadius),
            bottomRight: Radius.circular(cornerRadius),
            bottomLeft: Radius.circular(cornerRadius),
            topLeft: Radius.circular(cornerRadius)),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
