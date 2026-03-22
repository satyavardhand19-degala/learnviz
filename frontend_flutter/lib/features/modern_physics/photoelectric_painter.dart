import 'package:flutter/material.dart';
import 'dart:math';

class PhotoelectricPainter extends CustomPainter {
  final double frequency;
  final double threshold;
  final double time;

  PhotoelectricPainter(this.frequency, this.threshold, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final platePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4;

    final lightPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3;

    final electronPaint = Paint()
      ..color = Colors.cyan;

    double plateX = size.width * 0.3;

    // Metal plate
    canvas.drawLine(
      Offset(plateX, size.height * 0.2),
      Offset(plateX, size.height * 0.8),
      platePaint,
    );

    // Incoming light rays
    for (int i = 0; i < 5; i++) {
      double y = size.height * (0.2 + i * 0.15);

      canvas.drawLine(
        Offset(0, y),
        Offset(plateX, y),
        lightPaint,
      );
    }

    // Electron emission
    if (frequency > threshold) {
      for (int i = 0; i < 5; i++) {
        double y = size.height * (0.2 + i * 0.15);

        double x = plateX + (time * 200);

        canvas.drawCircle(
          Offset(x, y),
          5,
          electronPaint,
        );
      }
    }

    // Labels
    _drawText(canvas, "Metal Plate", Offset(plateX - 40, 20));
    _drawText(canvas, "Light", const Offset(10, 20));
    _drawText(canvas, "Electrons", Offset(size.width * 0.6, 20));
  }

  void _drawText(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
