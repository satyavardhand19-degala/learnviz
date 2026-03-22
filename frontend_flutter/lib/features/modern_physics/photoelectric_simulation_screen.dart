import 'package:flutter/material.dart';
import 'photoelectric_painter.dart';

class PhotoelectricSimulationScreen extends StatefulWidget {
  const PhotoelectricSimulationScreen({super.key});

  @override
  State<PhotoelectricSimulationScreen> createState() =>
      _PhotoelectricSimulationScreenState();
}

class _PhotoelectricSimulationScreenState
    extends State<PhotoelectricSimulationScreen>
    with SingleTickerProviderStateMixin {
  double frequency = 5; // in arbitrary units
  final double threshold = 4; // threshold frequency

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double get kineticEnergy =>
      frequency > threshold ? (frequency - threshold) : 0;

  bool get isEmission => frequency > threshold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Photoelectric Effect"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: PhotoelectricPainter(
                    frequency,
                    threshold,
                    controller.value,
                  ),
                  child: Container(),
                );
              },
            ),
          ),

          // 🎛️ Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Frequency: ${frequency.toStringAsFixed(1)}",
                  style: const TextStyle(color: Colors.white),
                ),

                Slider(
                  value: frequency,
                  min: 1,
                  max: 10,
                  onChanged: (v) {
                    setState(() {
                      frequency = v;
                    });
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  isEmission
                      ? "Electrons Emitted ✅"
                      : "No Emission ❌",
                  style: TextStyle(
                    color: isEmission ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Kinetic Energy: ${kineticEnergy.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.cyan),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Einstein Equation: KE = hf − φ",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
