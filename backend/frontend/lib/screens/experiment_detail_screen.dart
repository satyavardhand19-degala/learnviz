import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../data/local_simulation_catalog.dart';
import '../models/models.dart';
import '../simulations/custom_painter.dart';
import '../simulations/simulation_engine.dart';
import '../widgets/controls_widget.dart';
import '../widgets/module_bottom_nav.dart';
import 'experiment_list_screen.dart';

class ExperimentDetailScreen extends StatefulWidget {
  const ExperimentDetailScreen({super.key, required this.experiment});

  final Experiment experiment;

  @override
  State<ExperimentDetailScreen> createState() => _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState extends State<ExperimentDetailScreen> {
  late final SimulationEngine _engine;
  Timer? _timer;
  DateTime _lastFrame = DateTime.now();

  @override
  void initState() {
    super.initState();
    _engine = SimulationEngineFactory.create(widget.experiment)..initialize();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_engine.isPlaying || !mounted) {
        return;
      }
      final now = DateTime.now();
      final dt = now.difference(_lastFrame).inMicroseconds / Duration.microsecondsPerSecond;
      _lastFrame = now;
      setState(() {
        _engine.advance(dt);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _engine.togglePlayback();
      _lastFrame = DateTime.now();
    });
  }

  void _resetSimulation() {
    setState(() {
      _engine.reset();
      _lastFrame = DateTime.now();
    });
  }

  void _updateParameter(String key, double value) {
    setState(() {
      _engine.updateParameter(key, value);
      _lastFrame = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartData = _engine.chartData;
    final currentModule = LocalSimulationCatalog.modules.firstWhere(
      (Module module) => module.id == widget.experiment.moduleId,
      orElse: () => LocalSimulationCatalog.modules.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.experiment.name)),
      bottomNavigationBar: ModuleBottomNav(
        currentModule: currentModule,
        onSelected: (Module module) {
          if (module.name == currentModule.name) {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => ExperimentListScreen(module: module),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 300,
              width: double.infinity,
              child: CustomPaint(
                painter: SimulationScenePainter(engine: _engine, colorScheme: theme.colorScheme),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Live Metrics',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _engine.metrics
                    .map(
                      (SimulationMetric metric) => _MetricTile(
                        label: metric.label,
                        value: metric.value,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Control Panel',
              child: SimulationControlsWidget(
                engine: _engine,
                onParameterChanged: _updateParameter,
                onPlayPause: _togglePlayback,
                onReset: _resetSimulation,
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Graph Panel',
              child: SizedBox(
                height: 260,
                child: _SimulationChart(chartData: chartData),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Physics Model',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Math.tex(widget.experiment.formulaTemplate ?? _engine.formula),
                  const SizedBox(height: 12),
                  Text(widget.experiment.description ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SimulationChart extends StatelessWidget {
  const _SimulationChart({required this.chartData});

  final SimulationChartData chartData;

  @override
  Widget build(BuildContext context) {
    final primarySpots = _ensurePlotable(chartData.primary.spots);
    final secondarySpots = _ensurePlotable(chartData.secondary.spots);
    final allSpots = <FlSpot>[...primarySpots, ...secondarySpots];
    final minX = allSpots.map((FlSpot spot) => spot.x).reduce(math.min);
    final maxX = allSpots.map((FlSpot spot) => spot.x).reduce(math.max);
    final minYRaw = allSpots.map((FlSpot spot) => spot.y).reduce(math.min);
    final maxYRaw = allSpots.map((FlSpot spot) => spot.y).reduce(math.max);
    final span = (maxYRaw - minYRaw).abs();
    final padding = span < 0.5 ? 0.5 : span * 0.15;
    final minY = minYRaw - padding;
    final maxY = maxYRaw + padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(chartData.title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: <Widget>[
            _LegendChip(label: chartData.primary.label, color: chartData.primary.color),
            _LegendChip(label: chartData.secondary.label, color: chartData.secondary.color),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX <= minX ? minX + 1 : maxX,
              minY: minY,
              maxY: maxY <= minY ? minY + 1 : maxY,
              lineTouchData: const LineTouchData(enabled: true),
              gridData: FlGridData(show: true, drawVerticalLine: true),
              borderData: FlBorderData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Time (s)'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _interval(minX, maxX),
                    getTitlesWidget: (double value, TitleMeta meta) => Text(value.toStringAsFixed(1)),
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(chartData.yAxisLabel),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: _interval(minY, maxY),
                    getTitlesWidget: (double value, TitleMeta meta) => Text(value.toStringAsFixed(1)),
                  ),
                ),
              ),
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: primarySpots,
                  isCurved: true,
                  barWidth: 3,
                  color: chartData.primary.color,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: secondarySpots,
                  isCurved: true,
                  barWidth: 3,
                  color: chartData.secondary.color,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _ensurePlotable(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return const <FlSpot>[FlSpot(0, 0), FlSpot(1, 0)];
    }
    if (spots.length == 1) {
      return <FlSpot>[spots.first, FlSpot(spots.first.x + 0.1, spots.first.y)];
    }
    return spots;
  }

  double _interval(double min, double max) {
    final span = (max - min).abs();
    if (span <= 0.5) {
      return 0.1;
    }
    return span / 4;
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
