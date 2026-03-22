class Module {
  final int id;
  final String name;
  final String? description;
  final String? icon;

  Module({required this.id, required this.name, this.description, this.icon});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class Experiment {
  final int id;
  final int moduleId;
  final String name;
  final String? description;
  final String? formulaTemplate;
  final Map<String, dynamic> initialParams;
  final String difficultyLevel;

  Experiment({
    required this.id,
    required this.moduleId,
    required this.name,
    this.description,
    this.formulaTemplate,
    required this.initialParams,
    this.difficultyLevel = 'Beginner',
  });

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      id: json['id'],
      moduleId: json['module_id'],
      name: json['name'],
      description: json['description'],
      formulaTemplate: json['formula_template'],
      initialParams: json['initial_params'] ?? {},
      difficultyLevel: json['difficulty_level'] ?? 'Beginner',
    );
  }
}

class Formula {
  final int id;
  final int experimentId;
  final String name;
  final String latexString;
  final String? explanation;

  Formula({
    required this.id,
    required this.experimentId,
    required this.name,
    required this.latexString,
    this.explanation,
  });

  factory Formula.fromJson(Map<String, dynamic> json) {
    return Formula(
      id: json['id'],
      experimentId: json['experiment_id'],
      name: json['name'],
      latexString: json['latex_string'],
      explanation: json['explanation'],
    );
  }
}

class Quiz {
  final int id;
  final int experimentId;
  final String question;
  final List<String> options;
  final int correctOption;

  Quiz({
    required this.id,
    required this.experimentId,
    required this.question,
    required this.options,
    required this.correctOption,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      experimentId: json['experiment_id'],
      question: json['question'],
      options: List<String>.from(json['options'] ?? []),
      correctOption: json['correct_option'],
    );
  }
}
