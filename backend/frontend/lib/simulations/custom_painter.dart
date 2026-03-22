import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'simulation_engine.dart';

class SimulationScenePainter extends CustomPainter {
  const SimulationScenePainter({required this.engine, required this.colorScheme});

  final SimulationEngine engine;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = colorScheme.surface.withOpacity(0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)),
      background,
    );

    if (engine is ProjectileSimulationEngine) {
      _paintProjectile(canvas, size, engine as ProjectileSimulationEngine);
    } else if (engine is RayOpticsSimulationEngine) {
      _paintRayOptics(canvas, size, engine as RayOpticsSimulationEngine);
    } else if (engine is CircuitSimulationEngine) {
      _paintCircuit(canvas, size, engine as CircuitSimulationEngine);
    } else if (engine is WaveSimulationEngine) {
      _paintWave(canvas, size, engine as WaveSimulationEngine);
    } else if (engine is PhotoelectricSimulationEngine) {
      _paintPhotoelectric(canvas, size, engine as PhotoelectricSimulationEngine);
    }
  }

  void _paintProjectile(Canvas canvas, Size size, ProjectileSimulationEngine engine) {
    final gridPaint = Paint()
      ..color = colorScheme.outline.withOpacity(0.35)
      ..strokeWidth = 1;
    final groundPaint = Paint()
      ..color = colorScheme.onSurface
      ..strokeWidth = 2.5;
    final trajectoryPaint = Paint()
      ..color = Colors.orange.withOpacity(0.35)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final ballPaint = Paint()..color = Colors.deepOrange;

    final groundY = size.height - 28;
    final maxX = math.max(engine.range, 1.0);
    final maxY = math.max(engine.maxHeight, 1.0);
    final scaleX = (size.width - 44) / maxX;
    final scaleY = (groundY - 26) / maxY;
    final scale = math.min(scaleX, scaleY);

    for (double x = 24; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 16), Offset(x, groundY), gridPaint);
    }
    for (double y = 24; y < groundY; y += 28) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), gridPaint);
    }

    final path = Path();
    final flightTime = math.max(engine.totalFlightTime, 0.1);
    for (int step = 0; step <= 80; step++) {
      final sampleTime = flightTime * step / 80;
      final x = engine.velocity * math.cos(engine.angleRadians) * sampleTime;
      final y = math.max(
        0.0,
        engine.velocity * math.sin(engine.angleRadians) * sampleTime -
            0.5 * engine.gravity * sampleTime * sampleTime,
      );
      final point = Offset(22 + (x * scale), groundY - (y * scale));
      if (step == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, trajectoryPaint);

    final ballCenter = Offset(22 + (engine.positionX * scale), groundY - (engine.positionY * scale));
    canvas.drawCircle(ballCenter, 9, ballPaint);
    canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: ballCenter, radius: 9)), Colors.black54, 4, false);
    canvas.drawLine(Offset(16, groundY), Offset(size.width - 16, groundY), groundPaint);
  }

  void _paintRayOptics(Canvas canvas, Size size, RayOpticsSimulationEngine engine) {
    final center = Offset(size.width / 2, size.height / 2);
    final topMediumPaint = Paint()..color = Colors.blue.withOpacity(0.08);
    final bottomMediumPaint = Paint()..color = Colors.indigo.withOpacity(0.18);
    final axisPaint = Paint()
      ..color = colorScheme.onSurface.withOpacity(0.7)
      ..strokeWidth = 1.5;
    final incidentPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    final reflectedPaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    final refractedPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, center.dy), topMediumPaint);
    canvas.drawRect(Rect.fromLTWH(0, center.dy, size.width, size.height - center.dy), bottomMediumPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, 20), Offset(center.dx, size.height - 20), axisPaint);

    const double pathLength = 130;
    final incidentRadians = engine.incidentAngle * math.pi / 180;
    final refractedRadians = engine.refractedAngle * math.pi / 180;

    final incidentStart = Offset(
      center.dx - (pathLength * math.sin(incidentRadians)),
      center.dy - (pathLength * math.cos(incidentRadians)),
    );
    final reflectedEnd = Offset(
      center.dx + (pathLength * math.sin(incidentRadians)),
      center.dy - (pathLength * math.cos(incidentRadians)),
    );
    final refractedEnd = Offset(
      center.dx + (pathLength * math.sin(refractedRadians)),
      center.dy + (pathLength * math.cos(refractedRadians)),
    );

    canvas.drawLine(incidentStart, center, incidentPaint);
    canvas.drawLine(center, reflectedEnd, reflectedPaint..color = reflectedPaint.color.withOpacity(0.45));
    canvas.drawLine(center, refractedEnd, refractedPaint..color = refractedPaint.color.withOpacity(engine.isTotalInternalReflection ? 0.18 : 0.95));
    if (engine.isTotalInternalReflection) {
      canvas.drawLine(center, reflectedEnd, reflectedPaint..color = Colors.deepOrange);
    }

    final incomingT = (engine.incomingPulseDistance / 100).clamp(0.0, 1.0);
    final incomingPulse = Offset.lerp(incidentStart, center, incomingT)!;
    final outgoingT = (engine.outgoingPulseDistance / 100).clamp(0.0, 1.0);
    final outgoingPulse = Offset.lerp(
      center,
      engine.isTotalInternalReflection ? reflectedEnd : refractedEnd,
      outgoingT,
    )!;

    final glowPaint = Paint()..color = Colors.white.withOpacity(0.65);
    canvas.drawCircle(incomingPulse, 7, Paint()..color = Colors.amberAccent);
    canvas.drawCircle(incomingPulse, 13, glowPaint);
    if (engine.outgoingPulseDistance > 0) {
      canvas.drawCircle(
        outgoingPulse,
        7,
        Paint()..color = engine.isTotalInternalReflection ? Colors.deepOrangeAccent : Colors.lightBlueAccent,
      );
      canvas.drawCircle(outgoingPulse, 13, glowPaint);
    }
  }

  void _paintCircuit(Canvas canvas, Size size, CircuitSimulationEngine engine) {
    final wirePaint = Paint()
      ..color = colorScheme.onSurface
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final resistorPaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final batteryPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4;
    final electronPaint = Paint()..color = Colors.tealAccent.shade400;

    final left = 48.0;
    final top = 44.0;
    final right = size.width - 48.0;
    final bottom = size.height - 44.0;
    final midY = size.height / 2;

    final path = Path()
      ..moveTo(left, top)
      ..lineTo(right, top)
      ..lineTo(right, bottom)
      ..lineTo(left, bottom)
      ..close();
    canvas.drawPath(path, wirePaint);

    final resistorY = top;
    final resistorStartX = size.width / 2 - 54;
    final resistorStep = 18.0;
    final resistorPath = Path()..moveTo(resistorStartX, resistorY);
    for (int index = 0; index < 6; index++) {
      final x1 = resistorStartX + (index * resistorStep);
      resistorPath.lineTo(x1 + (resistorStep / 2), resistorY - 18);
      resistorPath.lineTo(x1 + resistorStep, resistorY);
    }
    canvas.drawPath(resistorPath, resistorPaint);

    canvas.drawLine(Offset(left, midY - 18), Offset(left, midY + 18), batteryPaint..strokeWidth = 5);
    canvas.drawLine(Offset(left - 14, midY - 10), Offset(left - 14, midY + 10), batteryPaint..strokeWidth = 3);

    final glowStrength = (engine.current / 2).clamp(0.15, 1.0);
    final bulbCenter = Offset(right, midY);
    canvas.drawCircle(
      bulbCenter,
      24,
      Paint()
        ..color = Colors.yellow.withOpacity(glowStrength)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(bulbCenter, 24, wirePaint..strokeWidth = 2);

    const int electrons = 14;
    for (int index = 0; index < electrons; index++) {
      final t = ((index / electrons) + engine.electronPhase) % 1.0;
      final point = _pointAlongRect(left, top, right, bottom, t);
      canvas.drawCircle(point, 4.5, electronPaint);
    }
  }

  Offset _pointAlongRect(double left, double top, double right, double bottom, double t) {
    final width = right - left;
    final height = bottom - top;
    final perimeter = (2 * width) + (2 * height);
    final distance = t * perimeter;

    if (distance <= width) {
      return Offset(left + distance, top);
    }
    if (distance <= width + height) {
      return Offset(right, top + (distance - width));
    }
    if (distance <= (2 * width) + height) {
      return Offset(right - (distance - width - height), bottom);
    }
    return Offset(left, bottom - (distance - ((2 * width) + height)));
  }

  void _paintWave(Canvas canvas, Size size, WaveSimulationEngine engine) {
    final axisPaint = Paint()
      ..color = colorScheme.outline
      ..strokeWidth = 1.5;
    final wavePaint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final probePaint = Paint()..color = Colors.pinkAccent;

    final midY = size.height / 2;
    canvas.drawLine(Offset(20, midY), Offset(size.width - 20, midY), axisPaint);

    final path = Path();
    const double length = 10;
    final scaleX = (size.width - 40) / length;
    final scaleY = 34.0;

    for (double x = 0; x <= length; x += 0.05) {
      final displacement = engine.amplitude * math.sin((engine.waveNumber * x) - (engine.angularFrequency * engine.time) + engine.phaseRadians);
      final point = Offset(20 + (x * scaleX), midY - (displacement * scaleY));
      if (x == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, wavePaint);

    final probeX = 20 + (WaveSimulationEngine.probePosition * scaleX);
    final probeY = midY - (engine.probeDisplacement * scaleY);
    canvas.drawLine(Offset(probeX, 24), Offset(probeX, size.height - 24), axisPaint..color = axisPaint.color.withOpacity(0.4));
    canvas.drawCircle(Offset(probeX, probeY), 8, probePaint);
  }

  void _paintPhotoelectric(Canvas canvas, Size size, PhotoelectricSimulationEngine engine) {
    final plateRect = Rect.fromLTWH(size.width * 0.64, 36, 24, size.height - 72);
    final collectorRect = Rect.fromLTWH(size.width * 0.84, 36, 20, size.height - 72);
    final platePaint = Paint()..color = Colors.blueGrey.shade700;
    final collectorPaint = Paint()..color = Colors.blueGrey.shade400;
    final photonPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(plateRect, platePaint);
    canvas.drawRect(collectorRect, collectorPaint);

    final photonCount = math.max(1, (engine.intensity * 5).round()).toInt();
    for (int index = 0; index < photonCount; index++) {
      final baseY = 56.0 + (index * 34.0);
      final path = Path()..moveTo(24, baseY);
      for (double x = 24; x < size.width * 0.62; x += 8) {
        final y = baseY + (10 * math.sin((x * 0.08) - (engine.time * 7)));
        path.lineTo(x, y);
      }
      canvas.drawPath(path, photonPaint);
    }

    if (!engine.isEmission) {
      return;
    }

    final electronPaint = Paint()..color = Colors.cyanAccent;
    final electronCount = math.max(1, (engine.emittedCurrent * 2).round()).toInt();
    final progress = (engine.time * 0.65) % 1.0;
    for (int index = 0; index < electronCount; index++) {
      final y = 58.0 + ((index * 30.0) % (size.height - 116));
      final x = plateRect.right + ((collectorRect.left - plateRect.right) * ((progress + (index / electronCount)) % 1.0));
      canvas.drawCircle(Offset(x, y), 4.5, electronPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SimulationScenePainter oldDelegate) {
    return true;
  }
}

class ProjectilePainter extends SimulationScenePainter {
  const ProjectilePainter({required super.engine, required super.colorScheme});
}

class RayPainter extends SimulationScenePainter {
  const RayPainter({required super.engine, required super.colorScheme});
}

class RefractionPainter extends SimulationScenePainter {
  const RefractionPainter({required super.engine, required super.colorScheme});
}

class WavePainter extends SimulationScenePainter {
  const WavePainter({required super.engine, required super.colorScheme});
}

class CircuitPainter extends SimulationScenePainter {
  const CircuitPainter({required super.engine, required super.colorScheme});
}

class PhotoelectricPainter extends SimulationScenePainter {
  const PhotoelectricPainter({required super.engine, required super.colorScheme});
}
