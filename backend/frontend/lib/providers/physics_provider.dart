import 'package:flutter/foundation.dart';

import '../data/local_simulation_catalog.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PhysicsProvider with ChangeNotifier {
  PhysicsProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<Module> modules = const <Module>[];
  List<Experiment> experiments = const <Experiment>[];
  bool isLoading = false;
  String? infoMessage;

  Future<void> loadModules() async {
    isLoading = true;
    modules = LocalSimulationCatalog.modules;
    infoMessage = 'Built-in interactive labs loaded.';
    notifyListeners();

    try {
      final remoteModules = await _apiService.getModules();
      modules = _mergeModules(remoteModules);
    } catch (_) {
      modules = LocalSimulationCatalog.modules;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExperiments(Module module) async {
    isLoading = true;
    experiments = LocalSimulationCatalog.experimentsForModule(module);
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }

  List<Module> _mergeModules(List<Module> remoteModules) {
    final Map<String, Module> byName = <String, Module>{
      for (final Module module in LocalSimulationCatalog.modules) module.name.toLowerCase(): module,
    };

    for (final Module remoteModule in remoteModules) {
      final key = remoteModule.name.toLowerCase();
      final local = byName[key];
      byName[key] = Module(
        id: remoteModule.id ?? local?.id,
        name: remoteModule.name,
        description: remoteModule.description ?? local?.description,
        icon: remoteModule.icon ?? local?.icon,
      );
    }

    return LocalSimulationCatalog.modules
        .map((Module module) => byName[module.name.toLowerCase()] ?? module)
        .toList(growable: false);
  }
}
