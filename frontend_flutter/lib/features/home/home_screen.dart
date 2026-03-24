import '../../data/experiments.dart';
import 'package:flutter/material.dart';
import '../../models/physics_models.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_card.dart';

import '../mechanics/projectile_simulation_screen.dart';
import '../optics/ray_simulation_screen.dart';
import '../electricity/circuit_simulation_screen.dart';
import '../waves/wave_simulation_screen.dart';
import '../modern_physics/photoelectric_simulation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Module>> modulesFuture;
  Module? selectedModule;
  List<Experiment> experiments = [];
  bool isLoadingExperiments = false;

  @override
  void initState() {
    super.initState();
    modulesFuture = ApiService.getModules();
  }

  // ✅ FIXED FUNCTION
  void _onModuleSelected(Module module) async {
    setState(() {
      selectedModule = module;
      experiments = [];
    });
  
    try {
      final exps = await ApiService.getExperiments(module.id);
  
      if (exps.isEmpty) {
        final local = moduleExperiments[module.name] ?? [];
  
        setState(() {
          experiments = local.map((e) {
            return Experiment(
              id: 0,
              name: e.title,
              description: e.description,
              difficultyLevel: "Basic",
              moduleId: module.id,
            );
          }).toList();
        });
      } else {
        setState(() {
          experiments = exps;
        });
      }
    } catch (e) {
      final local = moduleExperiments[module.name] ?? [];
  
      setState(() {
        experiments = local.map((e) {
          return Experiment(
            id: 0,
            name: e.title,
            description: e.description,
            difficultyLevel: "Basic",
            moduleId: module.id,
          );
        }).toList();
      });
    }
  }

  // ✅ LOCAL FALLBACK
  void _loadLocalExperiments(Module module) {
    final local = moduleExperiments[module.name] ?? [];

    setState(() {
      experiments = local.map<Experiment>((e) {
        return Experiment(
          id: 0,
          name: e.title,
          description: e.description,
          difficultyLevel: "Basic",
          moduleId: module.id,
          initialParams: {}, // ✅ REQUIRED FIX
        );
      }).toList();
    });
  }

  // ✅ NAVIGATION
  void _openSimulation(String name) {
    switch (name) {
      case "Projectile Motion":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProjectileSimulationScreen()),
        );
        break;

      case "Ray Diagram":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RaySimulationScreen()),
        );
        break;

      case "Simple Circuit":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CircuitSimulationScreen()),
        );
        break;

      case "Wave Simulation":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WaveSimulationScreen()),
        );
        break;

      case "Photoelectric Effect":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const PhotoelectricSimulationScreen()),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name simulation coming soon!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // 🔷 SIDEBAR
              Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Learnvis",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "MODULES",
                      style: TextStyle(
                        letterSpacing: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: FutureBuilder<List<Module>>(
                        future: modulesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("No modules found",
                                  style: TextStyle(color: Colors.white54)),
                            );
                          }

                          final modules = snapshot.data!;

                          return ListView.builder(
                            itemCount: modules.length,
                            itemBuilder: (context, index) {
                              final m = modules[index];
                              bool isSelected =
                                  selectedModule?.id == m.id;

                              return ListTile(
                                leading: Icon(
                                  _getIcon(m.icon),
                                  color: isSelected
                                      ? Colors.cyan
                                      : Colors.white70,
                                ),
                                title: Text(
                                  m.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.cyan
                                        : Colors.white,
                                  ),
                                ),
                                selected: isSelected,
                                onTap: () => _onModuleSelected(m),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 🔷 MAIN CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedModule?.name ?? "Select a Module",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedModule?.description ??
                            "Explore physics simulations",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),

                      Expanded(
                        child: isLoadingExperiments
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : experiments.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No experiments available",
                                      style:
                                          TextStyle(color: Colors.white54),
                                    ),
                                  )
                                : GridView.builder(
                                    itemCount: experiments.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 1.2,
                                    ),
                                    itemBuilder: (context, index) {
                                      final exp = experiments[index];

                                      return GestureDetector(
                                        onTap: () =>
                                            _openSimulation(exp.name),
                                        child: GlassCard(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Icon(Icons.science,
                                                    color: Colors.cyan,
                                                    size: 40),
                                                const SizedBox(height: 15),
                                                Text(
                                                  exp.name,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  exp.description ?? "",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.white70),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  exp.difficultyLevel,
                                                  style: const TextStyle(
                                                      color: Colors.white54),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'physics':
        return Icons.architecture;
      case 'light_mode':
        return Icons.light_mode;
      case 'bolt':
        return Icons.bolt;
      case 'waves':
        return Icons.waves;
      case 'science':
        return Icons.science;
      default:
        return Icons.category;
    }
  }
}
