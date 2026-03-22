import 'package:flutter/material.dart';
import 'circuit_painter.dart';

class CircuitSimulationScreen extends StatefulWidget {
  const CircuitSimulationScreen({super.key});

  @override
  State<CircuitSimulationScreen> createState() =>
      _CircuitSimulationScreenState();
}

class _CircuitSimulationScreenState extends State<CircuitSimulationScreen>
    with SingleTickerProviderStateMixin {
  double voltage = 5;
  double resistance = 5;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  double get current => voltage / resistance;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Circuit Simulation"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: CircuitPainter(controller.value, current),
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
                Text("Voltage: ${voltage.toStringAsFixed(1)} V",
                    style: const TextStyle(color: Colors.white)),

                Slider(
                  value: voltage,
                  min: 1,
                  max: 20,
                  onChanged: (v) {
                    setState(() {
                      voltage = v;
                    });
                  },
                ),

                Text("Resistance: ${resistance.toStringAsFixed(1)} Ω",
                    style: const TextStyle(color: Colors.white)),

                Slider(
                  value: resistance,
                  min: 1,
                  max: 20,
                  onChanged: (v) {
                    setState(() {
                      resistance = v;
                    });
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  "Current = ${current.toStringAsFixed(2)} A",
                  style: const TextStyle(
                      color: Colors.cyan, fontSize: 18),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Ohm’s Law: I = V / R",
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
