import 'package:flutter/material.dart';
import 'dart:math';

class WavePainter extends CustomPainter {
  final double amplitude;
  final double frequency;
  final double time;

  WavePainter(this.amplitude, this.frequency, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    double midY = size.height / 2;

    for (double x = 0; x < size.width; x++) {
      double y = amplitude *
          sin((x * 0.02 * frequency) - (time * 2 * pi));

      if (x == 0) {
        path.moveTo(x, midY + y);
      } else {
        path.lineTo(x, midY + y);
      }
    }

    canvas.drawPath(path, paint);

    // Center line
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
