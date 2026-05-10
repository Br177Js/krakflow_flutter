class TaskRepository {
  static List<Task> tasks = [];
}

class Task {
  final String title;
  final String deadline;
  bool done;
  final String priority;
  Task({required this.title, required this.deadline, required this.priority, required this.done});
}
