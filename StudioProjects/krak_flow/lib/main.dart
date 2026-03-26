import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  List<Task> tasks = [
    Task(title: "Projekt Flutter", deadline: "do jutra", priority:  "wysoki", done: false),
    Task(title: "Ćwiczenia z matematyki", deadline: "nigdy", priority:  "średni", done: false),
    Task(title: "Przeczytać o widgetach", deadline: "w tym miesiącu", priority:  "niski", done: true),
    Task(title: "Spać", deadline: "do jutra", priority:  "wysoki", done: false),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Lista zadań",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
           children: [
             Text("Masz dziś ${tasks.length} zadania"),
             SizedBox(height: 16),
             Text(
               "Dzisiejsze zadania",
               style: TextStyle(
                 fontSize: 22,
                 fontWeight: FontWeight.bold,
                 color: Colors.blue[700]!,
               ),
             ),
             Expanded (
               child:  ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskCard(title: tasks[index].title, subtitle: tasks[index].deadline, icon: tasks[index].done ? Icons.check_circle : Icons.radio_button_unchecked);
          },
        ),
             ),
          ],
          ),
    ),
        ),
      );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({required this.title, required this.deadline, required this.priority, required this.done});
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
