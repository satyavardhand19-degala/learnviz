import '../models/models.dart';

class LocalSimulationCatalog {
  static const List<Module> modules = [
    Module(
      id: 1,
      name: 'Mechanics',
      description: 'Motion, force, and energy experiments.',
      icon: 'science',
    ),
    Module(
      id: 2,
      name: 'Optics',
      description: 'Reflection, refraction, and light transport.',
      icon: 'light_mode',
    ),
    Module(
      id: 3,
      name: 'Electricity',
      description: 'Voltage, resistance, current, and power.',
      icon: 'bolt',
    ),
    Module(
      id: 4,
      name: 'Waves',
      description: 'Oscillation, propagation, and resonance.',
      icon: 'waves',
    ),
    Module(
      id: 5,
      name: 'Modern Physics',
      description: 'Quantum effects and energy quantization.',
      icon: 'auto_awesome',
    ),
  ];

  static List<Experiment> experimentsForModule(Module module) {
    switch (module.name.toLowerCase()) {
      case 'mechanics':
        return [
          Experiment(
            id: 101,
            moduleId: module.id ?? 1,
            name: 'Projectile Motion Lab',
            description: 'Launch a projectile and watch range, height, and speed evolve in real time.',
            formulaTemplate: r'y(t) = v_0 \sin(\theta)t - \frac{1}{2}gt^2',
            difficultyLevel: 'Beginner',
            simulationType: SimulationType.projectile,
            initialParams: <String, dynamic>{
              'velocity': 28.0,
              'angle': 48.0,
              'gravity': 9.8,
            },
          ),
        ];
      case 'optics':
        return [
          Experiment(
            id: 201,
            moduleId: module.id ?? 2,
            name: 'Ray Diagram Simulation',
            description: 'Study reflection and refraction by varying incidence angle and refractive indices.',
            formulaTemplate: r'n_1 \sin(\theta_1) = n_2 \sin(\theta_2)',
            difficultyLevel: 'Intermediate',
            simulationType: SimulationType.rayOptics,
            initialParams: <String, dynamic>{
              'incidentAngle': 35.0,
              'n1': 1.0,
              'n2': 1.52,
            },
          ),
        ];
      case 'electricity':
        return [
          Experiment(
            id: 301,
            moduleId: module.id ?? 3,
            name: 'Circuit Simulation',
            description: 'Tune voltage and resistance to see current flow and power draw update continuously.',
            formulaTemplate: r'I = \frac{V}{R}',
            difficultyLevel: 'Beginner',
            simulationType: SimulationType.circuit,
            initialParams: <String, dynamic>{
              'voltage': 12.0,
              'resistance': 20.0,
            },
          ),
        ];
      case 'waves':
        return [
          Experiment(
            id: 401,
            moduleId: module.id ?? 4,
            name: 'Wave Simulation',
            description: 'Animate a traveling wave and inspect displacement and probe velocity over time.',
            formulaTemplate: r'y(x,t) = A\sin\left(\frac{2\pi}{\lambda}x - 2\pi ft + \phi\right)',
            difficultyLevel: 'Intermediate',
            simulationType: SimulationType.wave,
            initialParams: <String, dynamic>{
              'amplitude': 1.8,
              'frequency': 1.2,
              'wavelength': 4.5,
              'phase': 0.0,
            },
          ),
        ];
      case 'modern physics':
        return [
          Experiment(
            id: 501,
            moduleId: module.id ?? 5,
            name: 'Photoelectric Effect Lab',
            description: 'Observe photon-driven electron emission as frequency, intensity, and stopping potential change.',
            formulaTemplate: r'K_{max} = hf - \phi - eV_s',
            difficultyLevel: 'Advanced',
            simulationType: SimulationType.photoelectric,
            initialParams: <String, dynamic>{
              'frequency': 7.5e14,
              'intensity': 1.0,
              'workFunction': 2.2,
              'stoppingPotential': 0.4,
            },
          ),
        ];
      default:
        return const [];
    }
  }
}
