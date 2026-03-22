import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? const String.fromEnvironment('LEARNVIS_API_URL', defaultValue: 'http://10.0.2.2:8000');

  final String baseUrl;
  static const Duration _timeout = Duration(milliseconds: 1200);

  Future<List<Module>> getModules() async {
    final response = await http.get(Uri.parse('$baseUrl/api/modules')).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load modules');
    }
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((dynamic item) => Module.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<List<Experiment>> getExperiments(int moduleId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/experiments/$moduleId')).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Failed to load experiments');
    }
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((dynamic item) => Experiment.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }
}
