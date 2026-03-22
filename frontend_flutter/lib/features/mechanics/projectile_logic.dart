import 'dart:math';
import 'package:flutter/material.dart';

class ProjectileLogic {
  static const double g = 9.8;

  static Offset getPosition(double t, double velocity, double angleDegree) {
    double angleRad = angleDegree * pi / 180;
    double x = velocity * cos(angleRad) * t;
    double y = velocity * sin(angleRad) * t - 0.5 * g * t * t;
    return Offset(x, y);
  }

  static List<Offset> getTrajectory(double velocity, double angleDegree, double maxTime) {
    List<Offset> points = [];
    for (double t = 0; t <= maxTime; t += 0.1) {
      Offset pos = getPosition(t, velocity, angleDegree);
      if (pos.dy < -10) break; // Stop below ground
      points.add(pos);
    }
    return points;
  }

  static double getMaxTime(double velocity, double angleDegree) {
    double angleRad = angleDegree * pi / 180;
    return (2 * velocity * sin(angleRad)) / g;
  }
}
