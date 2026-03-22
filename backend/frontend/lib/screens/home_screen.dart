import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/physics_provider.dart';
import 'experiment_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => context.read<PhysicsProvider>().loadModules());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Physics Lab')),
      body: Consumer<PhysicsProvider>(
        builder: (BuildContext context, PhysicsProvider provider, Widget? child) {
          if (provider.isLoading && provider.modules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: <Widget>[
              if (provider.infoMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(provider.infoMessage!),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: provider.modules.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Module module = provider.modules[index];
                    return _ModuleCard(
                      module: module,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => ExperimentListScreen(module: module),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onTap});

  final Module module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(_iconForModule(module.name), size: 34, color: theme.colorScheme.primary),
              const Spacer(),
              Text(module.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                module.description ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForModule(String name) {
    switch (name.toLowerCase()) {
      case 'mechanics':
        return Icons.sports_baseball;
      case 'optics':
        return Icons.light_mode;
      case 'electricity':
        return Icons.bolt;
      case 'waves':
        return Icons.graphic_eq;
      case 'modern physics':
        return Icons.auto_awesome;
      default:
        return Icons.science;
    }
  }
}
