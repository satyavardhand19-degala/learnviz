import 'package:flutter/material.dart';

import '../simulations/simulation_engine.dart';

class SimulationControlsWidget extends StatelessWidget {
  const SimulationControlsWidget({
    super.key,
    required this.engine,
    required this.onParameterChanged,
    required this.onPlayPause,
    required this.onReset,
  });

  final SimulationEngine engine;
  final void Function(String key, double value) onParameterChanged;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            FilledButton.icon(
              onPressed: onPlayPause,
              icon: Icon(engine.isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(engine.isPlaying ? 'Pause' : 'Play'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...engine.controls.map(
          (SimulationParameter control) {
            final currentValue = engine.parameters[control.key] ?? control.min;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${control.label}: ${_formatValue(currentValue, control.unit)}',
                    style: theme.textTheme.titleSmall,
                  ),
                  Slider(
                    value: currentValue.clamp(control.min, control.max).toDouble(),
                    min: control.min,
                    max: control.max,
                    divisions: control.divisions,
                    label: _formatValue(currentValue, control.unit),
                    onChanged: (double nextValue) => onParameterChanged(control.key, nextValue),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatValue(double value, String unit) {
    final formatted = value.abs() >= 10000 ? value.toStringAsExponential(2) : value.toStringAsFixed(2);
    return '$formatted $unit';
  }
}
