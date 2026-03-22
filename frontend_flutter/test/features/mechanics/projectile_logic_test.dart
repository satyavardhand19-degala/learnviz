import 'package:flutter_test/flutter_test.dart';
import 'package:learnvis/features/mechanics/projectile_logic.dart';

void main() {
  group('ProjectileLogic Tests', () {
    test('Max time calculation at 45 degrees', () {
      double velocity = 20.0;
      double angle = 45.0;
      // sin(45) approx 0.70710678118
      double expectedMaxTime = (2 * velocity * 0.70710678118) / 9.8; 
      expect(ProjectileLogic.getMaxTime(velocity, angle), closeTo(expectedMaxTime, 0.01));
    });

    test('Position at t=0 is (0,0)', () {
      Offset pos = ProjectileLogic.getPosition(0, 20, 45);
      expect(pos.dx, 0.0);
      expect(pos.dy, 0.0);
    });

    test('Trajectory contains points', () {
      var points = ProjectileLogic.getTrajectory(20, 45, 2.0);
      expect(points.isNotEmpty, true);
      expect(points.first, Offset.zero);
    });
  });
}
