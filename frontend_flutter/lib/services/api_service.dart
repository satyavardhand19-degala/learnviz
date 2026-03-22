import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/physics_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<List<Module>> getModules() async {
    final response = await http.get(Uri.parse('$baseUrl/modules'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((m) => Module.fromJson(m)).toList();
    }
    throw Exception('Failed to load modules');
  }

  static Future<List<Experiment>> getExperiments(int moduleId) async {
    final response = await http.get(Uri.parse('$baseUrl/experiments/$moduleId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Experiment.fromJson(e)).toList();
    }
    throw Exception('Failed to load experiments');
  }

  static Future<List<Formula>> getFormulas(int experimentId) async {
    final response = await http.get(Uri.parse('$baseUrl/formulas/$experimentId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((f) => Formula.fromJson(f)).toList();
    }
    throw Exception('Failed to load formulas');
  }

  static Future<List<Quiz>> getQuizzes(int experimentId) async {
    final response = await http.get(Uri.parse('$baseUrl/quizzes/$experimentId'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((q) => Quiz.fromJson(q)).toList();
    }
    throw Exception('Failed to load quizzes');
  }

  static Future<Map<String, dynamic>> calculate(int experimentId, Map<String, dynamic> params) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calculate/$experimentId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(params),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to calculate');
  }
}
