import 'package:flutter/material.dart';
import 'dart:math';

class RayPainter extends CustomPainter {
  final double angle;

  RayPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rayPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 3;

    final normalPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;

    final mirrorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    // Mirror
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      mirrorPaint,
    );

    // Normal
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      normalPaint,
    );

    double rad = angle * pi / 180;

    // Incident Ray
    final incident = Offset(
      center.dx - 200 * sin(rad),
      center.dy - 200 * cos(rad),
    );

    canvas.drawLine(incident, center, rayPaint);

    // Reflected Ray
    final reflected = Offset(
      center.dx + 200 * sin(rad),
      center.dy - 200 * cos(rad),
    );

    canvas.drawLine(center, reflected, rayPaint);

    // 🔥 Draw Angle Arc (visual learning)
    final arcRect = Rect.fromCircle(center: center, radius: 60);

    canvas.drawArc(
      arcRect,
      -pi / 2,
      rad,
      false,
      Paint()
        ..color = Colors.orange
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // 🔥 Draw Text Labels
    _drawText(canvas, "i = ${angle.toStringAsFixed(1)}°",
        center + const Offset(-120, -40));

    _drawText(canvas, "r = ${angle.toStringAsFixed(1)}°",
        center + const Offset(60, -40));

    _drawText(canvas, "Normal", center + const Offset(10, -120));
    _drawText(canvas, "Mirror", center + const Offset(-50, 10));
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
