import 'dart:convert';

enum SimulationType {
  projectile,
  rayOptics,
  circuit,
  wave,
  photoelectric,
}

SimulationType inferSimulationType(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('projectile')) {
    return SimulationType.projectile;
  }
  if (normalized.contains('ray') || normalized.contains('optics') || normalized.contains('reflection') || normalized.contains('refraction')) {
    return SimulationType.rayOptics;
  }
  if (normalized.contains('circuit') || normalized.contains('ohm') || normalized.contains('electric')) {
    return SimulationType.circuit;
  }
  if (normalized.contains('wave')) {
    return SimulationType.wave;
  }
  return SimulationType.photoelectric;
}

String simulationTypeLabel(SimulationType type) {
  switch (type) {
    case SimulationType.projectile:
      return 'Mechanics';
    case SimulationType.rayOptics:
      return 'Optics';
    case SimulationType.circuit:
      return 'Electricity';
    case SimulationType.wave:
      return 'Waves';
    case SimulationType.photoelectric:
      return 'Modern Physics';
  }
}

class Module {
  final int? id;
  final String name;
  final String? description;
  final String? icon;

  const Module({
    this.id,
    required this.name,
    this.description,
    this.icon,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }
}

class Experiment {
  final int? id;
  final int moduleId;
  final String name;
  final String? description;
  final String? formulaTemplate;
  final Map<String, dynamic> initialParams;
  final String? difficultyLevel;
  final SimulationType simulationType;

  const Experiment({
    this.id,
    required this.moduleId,
    required this.name,
    this.description,
    this.formulaTemplate,
    required this.initialParams,
    this.difficultyLevel,
    required this.simulationType,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      id: json['id'] as int?,
      moduleId: json['module_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      formulaTemplate: json['formula_template'] as String?,
      initialParams: jsonDecode(json['initial_params_json'] as String? ?? '{}') as Map<String, dynamic>,
      difficultyLevel: json['difficulty_level'] as String?,
      simulationType: inferSimulationType(json['name'] as String),
    );
  }

  Experiment copyWith({
    int? id,
    int? moduleId,
    String? name,
    String? description,
    String? formulaTemplate,
    Map<String, dynamic>? initialParams,
    String? difficultyLevel,
    SimulationType? simulationType,
  }) {
    return Experiment(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      name: name ?? this.name,
      description: description ?? this.description,
      formulaTemplate: formulaTemplate ?? this.formulaTemplate,
      initialParams: initialParams ?? this.initialParams,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      simulationType: simulationType ?? this.simulationType,
    );
  }
}

class Formula {
  final int? id;
  final String name;
  final String latexString;
  final String? explanation;

  const Formula({
    this.id,
    required this.name,
    required this.latexString,
    this.explanation,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    return Formula(
      id: json['id'] as int?,
      name: json['name'] as String,
      latexString: json['latex_string'] as String,
      explanation: json['explanation'] as String?,
    );
  }
}

class Quiz {
  final int? id;
  final String question;
  final List<String> options;
  final int correctOption;

  const Quiz({
    this.id,
    required this.question,
    required this.options,
    required this.correctOption,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int?,
      question: json['question'] as String,
      options: List<String>.from(jsonDecode(json['options_json'] as String? ?? '[]') as List<dynamic>),
      correctOption: json['correct_option'] as int,
    );
  }
}
