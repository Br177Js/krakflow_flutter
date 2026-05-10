import 'dart:convert';
import 'package:http/http.dart' as http;
import '/task_repository.dart';
import 'dart:math';

class TaskApiService {
  static const String baseUrl = "https://dummyjson.com";
  static Future<List<Task>> fetchTasks() async {
    final random = Random();
    final priorities = ["niski", "średni", "wysoki"];
    final deadlines = ["do jutra", "w tym miesiącu", "za 2 tygodnie", "nigdy"];
    final response = await http.get(
      Uri.parse("$baseUrl/todos"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todos = data["todos"];
      return todos.map((todo) {
        return Task(
          title: todo["todo"],
          deadline: deadlines[random.nextInt(deadlines.length)], // brak w API → mockujemy
          done: todo["completed"],
          priority: priorities[random.nextInt(priorities.length)], // brak w API → mockujemy
        );
      }).toList();
    } else {
      throw Exception("Błąd pobierania danych");
    }
  }
}