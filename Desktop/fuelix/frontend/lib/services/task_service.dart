import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class TaskService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  Future<List<Map<String, dynamic>>> getDailyTasks() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tasks/today'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  Future<bool> completeTask(int taskId) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/tasks/$taskId/complete'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
