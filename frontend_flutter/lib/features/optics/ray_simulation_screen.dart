import 'package:flutter/material.dart';
import 'dart:math';
import 'ray_painter.dart';

class RaySimulationScreen extends StatefulWidget {
  const RaySimulationScreen({super.key});

  @override
  State<RaySimulationScreen> createState() => _RaySimulationScreenState();
}

class _RaySimulationScreenState extends State<RaySimulationScreen> {
  double angle = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Ray Diagram"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: RayPainter(angle),
              child: Container(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Angle of Incidence = ${angle.toStringAsFixed(1)}°",
                  style: const TextStyle(color: Colors.white),
                ),
          
                Slider(
                  value: angle,
                  min: 0,
                  max: 80,
                  onChanged: (v) {
                    setState(() {
                      angle = v;
                    });
                  },
                ),
          
                const SizedBox(height: 10),
          
                const Text(
                  "Law of Reflection:\nAngle of Incidence = Angle of Reflection",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
