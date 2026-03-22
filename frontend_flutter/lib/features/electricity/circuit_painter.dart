import 'package:flutter/material.dart';

class CircuitPainter extends CustomPainter {
  final double animationValue;
  final double current;

  CircuitPainter(this.animationValue, this.current);

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;

    final currentPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 4;

    final batteryPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4;

    final resistorPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4;

    double left = size.width * 0.2;
    double right = size.width * 0.8;
    double top = size.height * 0.3;
    double bottom = size.height * 0.7;

    // 🔲 Circuit rectangle
    canvas.drawLine(Offset(left, top), Offset(right, top), wirePaint);
    canvas.drawLine(Offset(right, top), Offset(right, bottom), wirePaint);
    canvas.drawLine(Offset(right, bottom), Offset(left, bottom), wirePaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, top), wirePaint);

    // 🔋 Battery (left side)
    canvas.drawLine(
        Offset(left, top + 40), Offset(left, bottom - 40), batteryPaint);

    // 🔶 Resistor (top)
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset((left + right) / 2, top),
            width: 80,
            height: 20),
        resistorPaint);

    // 🔄 Current animation dots
    double progress = animationValue;

    List<Offset> path = [
      Offset(left, top),
      Offset(right, top),
      Offset(right, bottom),
      Offset(left, bottom),
    ];

    for (int i = 0; i < path.length - 1; i++) {
      final start = path[i];
      final end = path[i + 1];

      final pos = Offset.lerp(start, end, progress)!;

      canvas.drawCircle(pos, 6 + current, currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
