class LocalExperiment {
  final String title;
  final String description;
  final String route;

  LocalExperiment({
    required this.title,
    required this.description,
    required this.route,
  });
}

Map<String, List<LocalExperiment>> moduleExperiments = {
  "Mechanics": [
    LocalExperiment(
      title: "Projectile Motion",
      description: "Trajectory of a moving object",
      route: "/projectile",
    ),
  ],
  "Optics": [
    LocalExperiment(
      title: "Ray Diagram",
      description: "Reflection & refraction",
      route: "/optics",
    ),
  ],
  "Electricity": [
    LocalExperiment(
      title: "Simple Circuit",
      description: "Voltage & current",
      route: "/electricity",
    ),
  ],
  "Waves": [
    LocalExperiment(
      title: "Wave Simulation",
      description: "Frequency & amplitude",
      route: "/waves",
    ),
  ],
  "Modern Physics": [
    LocalExperiment(
      title: "Photoelectric Effect",
      description: "Light & electrons",
      route: "/modern",
    ),
  ],
};
