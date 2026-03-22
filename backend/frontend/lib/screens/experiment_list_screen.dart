import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/local_simulation_catalog.dart';
import '../models/models.dart';
import '../providers/physics_provider.dart';
import '../widgets/module_bottom_nav.dart';
import 'experiment_detail_screen.dart';

class ExperimentListScreen extends StatefulWidget {
  const ExperimentListScreen({super.key, required this.module});

  final Module module;

  @override
  State<ExperimentListScreen> createState() => _ExperimentListScreenState();
}

class _ExperimentListScreenState extends State<ExperimentListScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => context.read<PhysicsProvider>().loadExperiments(widget.module));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.name)),
      bottomNavigationBar: ModuleBottomNav(
        currentModule: widget.module,
        onSelected: (Module module) {
          if (module.name == widget.module.name) {
            return;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => ExperimentListScreen(
                module: LocalSimulationCatalog.modules.firstWhere(
                  (Module item) => item.name == module.name,
                  orElse: () => module,
                ),
              ),
            ),
          );
        },
      ),
      body: Consumer<PhysicsProvider>(
        builder: (BuildContext context, PhysicsProvider provider, Widget? child) {
          if (provider.isLoading && provider.experiments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.experiments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final Experiment experiment = provider.experiments[index];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ExperimentDetailScreen(experiment: experiment),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                experiment.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Chip(label: Text(experiment.difficultyLevel ?? simulationTypeLabel(experiment.simulationType))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(experiment.description ?? ''),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('Open interactive simulation lab')),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
