import 'package:flutter/material.dart';

import '../data/local_simulation_catalog.dart';
import '../models/models.dart';

class ModuleBottomNav extends StatelessWidget {
  const ModuleBottomNav({
    super.key,
    required this.currentModule,
    required this.onSelected,
  });

  final Module currentModule;
  final ValueChanged<Module> onSelected;

  @override
  Widget build(BuildContext context) {
    final currentIndex = LocalSimulationCatalog.modules.indexWhere(
      (Module module) => module.name == currentModule.name,
    );
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex < 0 ? 0 : currentIndex,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.7),
      items: LocalSimulationCatalog.modules.map((Module module) {
        return BottomNavigationBarItem(
          icon: Icon(_iconForModule(module.name)),
          label: module.name,
        );
      }).toList(growable: false),
      onTap: (int index) {
        onSelected(LocalSimulationCatalog.modules[index]);
      },
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
