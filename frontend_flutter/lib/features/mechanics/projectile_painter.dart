import 'package:flutter/material.dart';

class ProjectilePainter extends CustomPainter {
  final double x;
  final double y;

  ProjectilePainter(this.x, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    final ballPaint = Paint()..color = Colors.cyan;

    final groundPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    // Ground
    canvas.drawLine(
      Offset(0, size.height - 20),
      Offset(size.width, size.height - 20),
      groundPaint,
    );

    // Scale (important for visibility)
    double scale = 4;

    double drawX = x * scale;
    double drawY = size.height - 20 - (y * scale);

    // Prevent going off-screen
    drawX = drawX.clamp(0, size.width);
    drawY = drawY.clamp(0, size.height);

    // Draw ball
    canvas.drawCircle(
      Offset(drawX, drawY),
      8,
      ballPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
