import 'package:flutter/material.dart';
import 'wave_painter.dart';

class WaveSimulationScreen extends StatefulWidget {
  const WaveSimulationScreen({super.key});

  @override
  State<WaveSimulationScreen> createState() =>
      _WaveSimulationScreenState();
}

class _WaveSimulationScreenState extends State<WaveSimulationScreen>
    with SingleTickerProviderStateMixin {
  double amplitude = 50;
  double frequency = 1;

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

  double get wavelength => 300 / frequency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Wave Simulation"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: WavePainter(
                    amplitude,
                    frequency,
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
                Text("Amplitude: ${amplitude.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.white)),

                Slider(
                  value: amplitude,
                  min: 10,
                  max: 100,
                  onChanged: (v) {
                    setState(() {
                      amplitude = v;
                    });
                  },
                ),

                Text("Frequency: ${frequency.toStringAsFixed(1)} Hz",
                    style: const TextStyle(color: Colors.white)),

                Slider(
                  value: frequency,
                  min: 0.5,
                  max: 5,
                  onChanged: (v) {
                    setState(() {
                      frequency = v;
                    });
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  "Wavelength ≈ ${wavelength.toStringAsFixed(1)} px",
                  style: const TextStyle(color: Colors.cyan),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Wave equation: y = A sin(kx - ωt)",
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
