class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Projekt Flutter", deadline: "do jutra", priority:  "wysoki", done: false),
    Task(title: "Ćwiczenia z matematyki", deadline: "nigdy", priority:  "średni", done: false),
    Task(title: "Przeczytać o widgetach", deadline: "w tym miesiącu", priority:  "niski", done: true),
    Task(title: "Spać", deadline: "do jutra", priority:  "wysoki", done: false),
  ];
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({required this.title, required this.deadline, required this.priority, required this.done});
}
