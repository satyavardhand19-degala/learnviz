import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

class SimulationParameter {
  final String key;
  final String label;
  final String unit;
  final double min;
  final double max;
  final int divisions;

  const SimulationParameter({
    required this.key,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.divisions,
  });
}

class SimulationMetric {
  final String label;
  final String value;

  const SimulationMetric({required this.label, required this.value});
}

class SimulationSeries {
  final String label;
  final Color color;
  final List<FlSpot> spots;

  const SimulationSeries({
    required this.label,
    required this.color,
    required this.spots,
  });
}

class SimulationChartData {
  final String title;
  final String yAxisLabel;
  final SimulationSeries primary;
  final SimulationSeries secondary;

  const SimulationChartData({
    required this.title,
    required this.yAxisLabel,
    required this.primary,
    required this.secondary,
  });
}

abstract class SimulationEngine {
  SimulationEngine(this.experiment)
      : _initialParameters = _asDoubleMap(experiment.initialParams),
        _parameters = _asDoubleMap(experiment.initialParams);

  static const int maxHistoryPoints = 180;

  final Experiment experiment;
  final Map<String, double> _initialParameters;
  final Map<String, double> _parameters;
  final List<FlSpot> _primaryHistory = <FlSpot>[];
  final List<FlSpot> _secondaryHistory = <FlSpot>[];

  bool isPlaying = true;
  double time = 0;

  List<SimulationParameter> get controls;
  String get chartTitle;
  String get chartYAxisLabel;
  String get primarySeriesLabel;
  String get secondarySeriesLabel;
  Color get primarySeriesColor;
  Color get secondarySeriesColor;
  double get primaryChartValue;
  double get secondaryChartValue;
  List<SimulationMetric> get metrics;

  String get formula => experiment.formulaTemplate ?? '';
  Map<String, double> get parameters => Map<String, double>.unmodifiable(_parameters);

  void initialize() {
    reset();
  }

  void advance(double dt) {
    if (!isPlaying) {
      return;
    }
    final clampedDt = dt.clamp(0.0, 0.05);
    time += clampedDt;
    onAdvance(clampedDt);
    _recordHistory();
  }

  void reset() {
    time = 0;
    _parameters
      ..clear()
      ..addAll(_initialParameters);
    _primaryHistory.clear();
    _secondaryHistory.clear();
    onReset();
    _recordHistory();
  }

  void restartWithCurrentParameters() {
    time = 0;
    _primaryHistory.clear();
    _secondaryHistory.clear();
    onReset();
    _recordHistory();
  }

  void togglePlayback() {
    isPlaying = !isPlaying;
  }

  void updateParameter(String key, double value) {
    _parameters[key] = value;
    restartWithCurrentParameters();
  }

  double value(String key) => _parameters[key] ?? 0;

  SimulationChartData get chartData {
    return SimulationChartData(
      title: chartTitle,
      yAxisLabel: chartYAxisLabel,
      primary: SimulationSeries(
        label: primarySeriesLabel,
        color: primarySeriesColor,
        spots: List<FlSpot>.unmodifiable(_primaryHistory),
      ),
      secondary: SimulationSeries(
        label: secondarySeriesLabel,
        color: secondarySeriesColor,
        spots: List<FlSpot>.unmodifiable(_secondaryHistory),
      ),
    );
  }

  void onAdvance(double dt);

  void onReset();

  void _recordHistory() {
    _primaryHistory.add(FlSpot(time, primaryChartValue));
    _secondaryHistory.add(FlSpot(time, secondaryChartValue));
    if (_primaryHistory.length > maxHistoryPoints) {
      _primaryHistory.removeAt(0);
    }
    if (_secondaryHistory.length > maxHistoryPoints) {
      _secondaryHistory.removeAt(0);
    }
  }

  static Map<String, double> _asDoubleMap(Map<String, dynamic> values) {
    return values.map(
      (String key, dynamic value) => MapEntry<String, double>(key, (value as num).toDouble()),
    );
  }

  String formatNumber(double number, {int decimals = 2, bool scientific = false}) {
    if (scientific) {
      return number.toStringAsExponential(2);
    }
    return number.toStringAsFixed(decimals);
  }
}

class ProjectileSimulationEngine extends SimulationEngine {
  ProjectileSimulationEngine(super.experiment);

  double positionX = 0;
  double positionY = 0;
  double speed = 0;

  @override
  List<SimulationParameter> get controls => const <SimulationParameter>[
        SimulationParameter(
          key: 'velocity',
          label: 'Launch Speed',
          unit: 'm/s',
          min: 10,
          max: 60,
          divisions: 50,
        ),
        SimulationParameter(
          key: 'angle',
          label: 'Launch Angle',
          unit: 'deg',
          min: 15,
          max: 80,
          divisions: 65,
        ),
        SimulationParameter(
          key: 'gravity',
          label: 'Gravity',
          unit: 'm/s^2',
          min: 1,
          max: 20,
          divisions: 38,
        ),
      ];

  double get velocity => value('velocity');
  double get angleDegrees => value('angle');
  double get gravity => value('gravity');
  double get angleRadians => angleDegrees * math.pi / 180;
  double get totalFlightTime => gravity == 0 ? 0 : (2 * velocity * math.sin(angleRadians)) / gravity;
  double get range => velocity * math.cos(angleRadians) * totalFlightTime;
  double get maxHeight =>
      gravity == 0 ? 0 : (math.pow(velocity * math.sin(angleRadians), 2) / (2 * gravity)).toDouble();

  @override
  String get chartTitle => 'Projectile response over time';

  @override
  String get chartYAxisLabel => 'Height / Speed';

  @override
  String get primarySeriesLabel => 'Height';

  @override
  String get secondarySeriesLabel => 'Speed';

  @override
  Color get primarySeriesColor => Colors.orange;

  @override
  Color get secondarySeriesColor => Colors.blue;

  @override
  double get primaryChartValue => positionY;

  @override
  double get secondaryChartValue => speed;

  @override
  List<SimulationMetric> get metrics => <SimulationMetric>[
        SimulationMetric(label: 'Range', value: '${formatNumber(range)} m'),
        SimulationMetric(label: 'Max height', value: '${formatNumber(maxHeight)} m'),
        SimulationMetric(label: 'Flight time', value: '${formatNumber(totalFlightTime)} s'),
        SimulationMetric(label: 'Speed', value: '${formatNumber(speed)} m/s'),
      ];

  @override
  void onAdvance(double dt) {
    _sampleState(totalFlightTime == 0 ? 0 : time % totalFlightTime);
  }

  @override
  void onReset() {
    _sampleState(0);
  }

  void _sampleState(double sampleTime) {
    final velocityX = velocity * math.cos(angleRadians);
    final velocityY = velocity * math.sin(angleRadians) - gravity * sampleTime;
    positionX = velocityX * sampleTime;
    positionY = math.max(
      0.0,
      velocity * math.sin(angleRadians) * sampleTime - 0.5 * gravity * sampleTime * sampleTime,
    );
    speed = math.sqrt((velocityX * velocityX) + (velocityY * velocityY));
  }
}

class RayOpticsSimulationEngine extends SimulationEngine {
  RayOpticsSimulationEngine(super.experiment);

  double incomingPulseDistance = 0;
  double outgoingPulseDistance = 0;

  @override
  List<SimulationParameter> get controls => const <SimulationParameter>[
        SimulationParameter(
          key: 'incidentAngle',
          label: 'Incident Angle',
          unit: 'deg',
          min: 10,
          max: 80,
          divisions: 70,
        ),
        SimulationParameter(
          key: 'n1',
          label: 'Medium 1 Index',
          unit: 'n',
          min: 1.0,
          max: 1.8,
          divisions: 80,
        ),
        SimulationParameter(
          key: 'n2',
          label: 'Medium 2 Index',
          unit: 'n',
          min: 1.0,
          max: 2.2,
          divisions: 120,
        ),
      ];

  double get incidentAngle => value('incidentAngle');
  double get reflectionAngle => incidentAngle;
  double get n1 => value('n1');
  double get n2 => value('n2');
  double get _sinTheta2 => (n1 * math.sin(incidentAngle * math.pi / 180)) / n2;
  bool get isTotalInternalReflection => _sinTheta2.abs() > 1;
  double? get criticalAngle {
    if (n1 <= n2) {
      return null;
    }
    return math.asin(n2 / n1) * 180 / math.pi;
  }

  double get refractedAngle {
    if (isTotalInternalReflection) {
      return reflectionAngle;
    }
    return math.asin(_sinTheta2.clamp(-1.0, 1.0)) * 180 / math.pi;
  }

  @override
  String get chartTitle => 'Ray packet position over time';

  @override
  String get chartYAxisLabel => 'Distance';

  @override
  String get primarySeriesLabel => 'Incoming ray';

  @override
  String get secondarySeriesLabel => isTotalInternalReflection ? 'Reflected ray' : 'Refracted ray';

  @override
  Color get primarySeriesColor => Colors.amber;

  @override
  Color get secondarySeriesColor => isTotalInternalReflection ? Colors.deepOrange : Colors.lightBlue;

  @override
  double get primaryChartValue => incomingPulseDistance;

  @override
  double get secondaryChartValue => outgoingPulseDistance;

  @override
  List<SimulationMetric> get metrics => <SimulationMetric>[
        SimulationMetric(label: 'Reflection', value: '${formatNumber(reflectionAngle)} deg'),
        SimulationMetric(
          label: isTotalInternalReflection ? 'Mode' : 'Refraction',
          value: isTotalInternalReflection ? 'Total internal reflection' : '${formatNumber(refractedAngle)} deg',
        ),
        SimulationMetric(
          label: 'Critical angle',
          value: criticalAngle == null ? 'n/a' : '${formatNumber(criticalAngle!)} deg',
        ),
        SimulationMetric(label: 'Index ratio', value: formatNumber(n2 / n1)),
      ];

  @override
  void onAdvance(double dt) {
    _samplePulse();
  }

  @override
  void onReset() {
    _samplePulse();
  }

  void _samplePulse() {
    const double pathLength = 100;
    final cycleTime = time % 2.0;
    if (cycleTime < 1.0) {
      incomingPulseDistance = cycleTime * pathLength;
      outgoingPulseDistance = 0;
    } else {
      incomingPulseDistance = pathLength;
      outgoingPulseDistance = (cycleTime - 1.0) * pathLength;
    }
  }
}

class CircuitSimulationEngine extends SimulationEngine {
  CircuitSimulationEngine(super.experiment);

  @override
  List<SimulationParameter> get controls => const <SimulationParameter>[
        SimulationParameter(
          key: 'voltage',
          label: 'Battery Voltage',
          unit: 'V',
          min: 1,
          max: 24,
          divisions: 46,
        ),
        SimulationParameter(
          key: 'resistance',
          label: 'Resistance',
          unit: 'ohm',
          min: 2,
          max: 120,
          divisions: 118,
        ),
      ];

  double get voltage => value('voltage');
  double get resistance => value('resistance');
  double get current => resistance == 0 ? 0 : voltage / resistance;
  double get power => voltage * current;
  double get chargeMoved => current * time;
  double get electronPhase => (time * math.max(current, 0.1) * 0.45) % 1.0;

  @override
  String get chartTitle => 'Current and power over time';

  @override
  String get chartYAxisLabel => 'Current / Power';

  @override
  String get primarySeriesLabel => 'Current';

  @override
  String get secondarySeriesLabel => 'Power';

  @override
  Color get primarySeriesColor => Colors.teal;

  @override
  Color get secondarySeriesColor => Colors.deepPurple;

  @override
  double get primaryChartValue => current;

  @override
  double get secondaryChartValue => power;

  @override
  List<SimulationMetric> get metrics => <SimulationMetric>[
        SimulationMetric(label: 'Current', value: '${formatNumber(current)} A'),
        SimulationMetric(label: 'Power', value: '${formatNumber(power)} W'),
        SimulationMetric(label: 'Charge moved', value: '${formatNumber(chargeMoved)} C'),
        SimulationMetric(label: 'Resistance', value: '${formatNumber(resistance)} ohm'),
      ];

  @override
  void onAdvance(double dt) {}

  @override
  void onReset() {}
}

class WaveSimulationEngine extends SimulationEngine {
  WaveSimulationEngine(super.experiment);

  static const double probePosition = 1.4;

  @override
  List<SimulationParameter> get controls => const <SimulationParameter>[
        SimulationParameter(
          key: 'amplitude',
          label: 'Amplitude',
          unit: 'm',
          min: 0.5,
          max: 4.0,
          divisions: 35,
        ),
        SimulationParameter(
          key: 'frequency',
          label: 'Frequency',
          unit: 'Hz',
          min: 0.4,
          max: 3.0,
          divisions: 52,
        ),
        SimulationParameter(
          key: 'wavelength',
          label: 'Wavelength',
          unit: 'm',
          min: 2.0,
          max: 9.0,
          divisions: 70,
        ),
        SimulationParameter(
          key: 'phase',
          label: 'Phase Shift',
          unit: 'deg',
          min: 0,
          max: 180,
          divisions: 36,
        ),
      ];

  double get amplitude => value('amplitude');
  double get frequency => value('frequency');
  double get wavelength => value('wavelength');
  double get phaseDegrees => value('phase');
  double get phaseRadians => phaseDegrees * math.pi / 180;
  double get waveNumber => (2 * math.pi) / wavelength;
  double get angularFrequency => 2 * math.pi * frequency;
  double get probeDisplacement => amplitude * math.sin((waveNumber * probePosition) - (angularFrequency * time) + phaseRadians);
  double get probeVelocity => -amplitude * angularFrequency * math.cos((waveNumber * probePosition) - (angularFrequency * time) + phaseRadians);
  double get waveSpeed => frequency * wavelength;

  @override
  String get chartTitle => 'Probe motion over time';

  @override
  String get chartYAxisLabel => 'Displacement / Velocity';

  @override
  String get primarySeriesLabel => 'Displacement';

  @override
  String get secondarySeriesLabel => 'Velocity';

  @override
  Color get primarySeriesColor => Colors.indigo;

  @override
  Color get secondarySeriesColor => Colors.pink;

  @override
  double get primaryChartValue => probeDisplacement;

  @override
  double get secondaryChartValue => probeVelocity;

  @override
  List<SimulationMetric> get metrics => <SimulationMetric>[
        SimulationMetric(label: 'Wave speed', value: '${formatNumber(waveSpeed)} m/s'),
        SimulationMetric(label: 'Probe y', value: '${formatNumber(probeDisplacement)} m'),
        SimulationMetric(label: 'Probe v', value: '${formatNumber(probeVelocity)} m/s'),
        SimulationMetric(label: 'Angular freq', value: '${formatNumber(angularFrequency)} rad/s'),
      ];

  @override
  void onAdvance(double dt) {}

  @override
  void onReset() {}
}

class PhotoelectricSimulationEngine extends SimulationEngine {
  PhotoelectricSimulationEngine(super.experiment);

  static const double planckElectronVoltSeconds = 4.135667696e-15;
  static const double electronCharge = 1.602176634e-19;
  static const double electronMass = 9.1093837015e-31;

  @override
  List<SimulationParameter> get controls => const <SimulationParameter>[
        SimulationParameter(
          key: 'frequency',
          label: 'Photon Frequency',
          unit: 'Hz',
          min: 4.0e14,
          max: 1.4e15,
          divisions: 100,
        ),
        SimulationParameter(
          key: 'intensity',
          label: 'Light Intensity',
          unit: 'rel',
          min: 0.2,
          max: 2.0,
          divisions: 36,
        ),
        SimulationParameter(
          key: 'workFunction',
          label: 'Work Function',
          unit: 'eV',
          min: 1.5,
          max: 4.5,
          divisions: 60,
        ),
        SimulationParameter(
          key: 'stoppingPotential',
          label: 'Stopping Potential',
          unit: 'V',
          min: 0.0,
          max: 3.0,
          divisions: 60,
        ),
      ];

  double get frequency => value('frequency');
  double get intensity => value('intensity');
  double get workFunction => value('workFunction');
  double get stoppingPotential => value('stoppingPotential');
  double get rawKineticEnergyEv => math.max(0.0, (planckElectronVoltSeconds * frequency) - workFunction);
  double get effectiveKineticEnergyEv => math.max(0.0, rawKineticEnergyEv - stoppingPotential);
  bool get isEmission => rawKineticEnergyEv > 0;
  double get emittedCurrent {
    if (!isEmission) {
      return 0;
    }
    if (rawKineticEnergyEv == 0) {
      return 0;
    }
    final transmissionFactor = (1 - (stoppingPotential / rawKineticEnergyEv)).clamp(0.0, 1.0);
    return intensity * 4.0 * transmissionFactor;
  }

  double get electronSpeed {
    final kineticEnergyJoules = effectiveKineticEnergyEv * electronCharge;
    if (kineticEnergyJoules <= 0) {
      return 0;
    }
    return math.sqrt((2 * kineticEnergyJoules) / electronMass);
  }

  double get thresholdFrequency => workFunction / planckElectronVoltSeconds;

  @override
  String get chartTitle => 'Photoelectric output over time';

  @override
  String get chartYAxisLabel => 'Current / Kinetic Energy';

  @override
  String get primarySeriesLabel => 'Photocurrent';

  @override
  String get secondarySeriesLabel => 'Electron KE';

  @override
  Color get primarySeriesColor => Colors.cyan;

  @override
  Color get secondarySeriesColor => Colors.amber;

  @override
  double get primaryChartValue => emittedCurrent;

  @override
  double get secondaryChartValue => effectiveKineticEnergyEv;

  @override
  List<SimulationMetric> get metrics => <SimulationMetric>[
        SimulationMetric(label: 'Emission', value: isEmission ? 'Active' : 'Off'),
        SimulationMetric(label: 'Threshold f', value: formatNumber(thresholdFrequency, scientific: true)),
        SimulationMetric(label: 'Electron KE', value: '${formatNumber(effectiveKineticEnergyEv)} eV'),
        SimulationMetric(label: 'Electron speed', value: '${formatNumber(electronSpeed, scientific: true)} m/s'),
      ];

  @override
  void onAdvance(double dt) {}

  @override
  void onReset() {}
}

class SimulationEngineFactory {
  static SimulationEngine create(Experiment experiment) {
    switch (experiment.simulationType) {
      case SimulationType.projectile:
        return ProjectileSimulationEngine(experiment);
      case SimulationType.rayOptics:
        return RayOpticsSimulationEngine(experiment);
      case SimulationType.circuit:
        return CircuitSimulationEngine(experiment);
      case SimulationType.wave:
        return WaveSimulationEngine(experiment);
      case SimulationType.photoelectric:
        return PhotoelectricSimulationEngine(experiment);
    }
  }
}
