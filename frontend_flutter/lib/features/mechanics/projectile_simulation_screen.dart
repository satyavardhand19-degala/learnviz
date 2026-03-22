import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'projectile_painter.dart'; 

class ProjectileSimulationScreen extends StatefulWidget {
  const ProjectileSimulationScreen({super.key});

  @override
  State<ProjectileSimulationScreen> createState() =>
      _ProjectileSimulationScreenState();
}

class _ProjectileSimulationScreenState
    extends State<ProjectileSimulationScreen> {
  double angle = 45;
  double velocity = 50;

  double x = 0;
  double y = 0;
  double time = 0;

  Timer? timer;
  bool isRunning = false;

  final g = 9.8;

  void start() {
    timer?.cancel();
    isRunning = true;
    time = 0;

    timer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      setState(() {
        time += 0.1;

        double rad = angle * pi / 180;

        x = velocity * cos(rad) * time;
        y = velocity * sin(rad) * time -
            0.5 * g * time * time;

        if (y < 0) {
          stop();
        }
      });
    });
  }

  void stop() {
    timer?.cancel();
    isRunning = false;
  }

  void reset() {
    stop();
    setState(() {
      x = 0;
      y = 0;
      time = 0;
    });
  }

  double get maxHeight =>
      (pow(velocity * sin(angle * pi / 180), 2)) / (2 * g);

  double get range =>
      (pow(velocity, 2) * sin(2 * angle * pi / 180)) / g;

  double get flightTime =>
      (2 * velocity * sin(angle * pi / 180)) / g;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Projectile Motion"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: ProjectilePainter(x, y),
              child: Container(),
            ),
          ),

          // 🎛️ Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Angle: ${angle.toStringAsFixed(1)}°",
                    style: const TextStyle(color: Colors.white)),

                Slider(
                  value: angle,
                  min: 10,
                  max: 80,
                  onChanged: (v) {
                    setState(() => angle = v);
                  },
                ),

                Text("Velocity: ${velocity.toStringAsFixed(1)} m/s",
                    style: const TextStyle(color: Colors.white)),

                Slider(
                  value: velocity,
                  min: 10,
                  max: 100,
                  onChanged: (v) {
                    setState(() => velocity = v);
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: isRunning ? null : start,
                        child: const Text("Play")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: stop,
                        child: const Text("Pause")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: reset,
                        child: const Text("Reset")),
                  ],
                ),

                const SizedBox(height: 10),

                // 📊 Physics Info
                Text(
                  "Max Height: ${maxHeight.toStringAsFixed(2)} m",
                  style: const TextStyle(color: Colors.cyan),
                ),
                Text(
                  "Range: ${range.toStringAsFixed(2)} m",
                  style: const TextStyle(color: Colors.cyan),
                ),
                Text(
                  "Time: ${flightTime.toStringAsFixed(2)} s",
                  style: const TextStyle(color: Colors.cyan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
