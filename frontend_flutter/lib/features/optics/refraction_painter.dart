import 'dart:math';
import 'package:flutter/material.dart';

class RefractionPainter extends CustomPainter {
  final double n1;
  final double n2;
  final double theta1; // Incident angle in degrees
  final double? theta2; // Refracted angle in degrees

  RefractionPainter({
    required this.n1,
    required this.n2,
    required this.theta1,
    this.theta2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rayLength = min(size.width, size.height) * 0.4;

    final normalPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final incidentPaint = Paint()
      ..color = Colors.yellowAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final refractedPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw Interface (Horizontal Line)
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      Paint()..color = Colors.white54..strokeWidth = 2,
    );

    // Draw Normal (Vertical Line)
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      normalPaint,
    );

    // Incident Ray
    double theta1Rad = (90 - theta1) * pi / 180; // Angle from interface to normal
    double x1 = center.dx - rayLength * cos(theta1Rad);
    double y1 = center.dy - rayLength * sin(theta1Rad);
    canvas.drawLine(Offset(x1, y1), center, incidentPaint);

    // Refracted Ray
    if (theta2 != null) {
      double theta2Rad = (90 - theta2!) * pi / 180;
      double x2 = center.dx + rayLength * cos(theta2Rad);
      double y2 = center.dy + rayLength * sin(theta2Rad);
      canvas.drawLine(center, Offset(x2, y2), refractedPaint);
    } else {
      // Total Internal Reflection
      double x2 = center.dx + rayLength * cos(theta1Rad);
      double y2 = center.dy - rayLength * sin(theta1Rad);
      canvas.drawLine(center, Offset(x2, y2), incidentPaint..color = Colors.redAccent);
    }
    
    // Labels for Mediums
    const textStyle = TextStyle(color: Colors.white70, fontSize: 14);
    final tp1 = TextPainter(text: TextSpan(text: "n1 = $n1", style: textStyle), textDirection: TextDirection.ltr);
    tp1.layout();
    tp1.paint(canvas, Offset(20, center.dy - 30));

    final tp2 = TextPainter(text: TextSpan(text: "n2 = $n2", style: textStyle), textDirection: TextDirection.ltr);
    tp2.layout();
    tp2.paint(canvas, Offset(20, center.dy + 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
