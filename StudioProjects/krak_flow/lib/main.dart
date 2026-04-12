import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(MaterialApp(home: HomeScreen(),));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _MyApp();
}

class _MyApp extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
             Text("Masz dziś ${TaskRepository.tasks.length} zadania"),
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
          itemCount: TaskRepository.tasks.length,
          itemBuilder: (context, index) {
            return TaskCard(title: TaskRepository.tasks[index].title, subtitle: TaskRepository.tasks[index].deadline, icon: TaskRepository.tasks[index].done ? Icons.check_circle : Icons.radio_button_unchecked);
          },
        ),
             ),
          ],
          ),
    ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final Task? newTask = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
            if (newTask != null) {
              setState(() {
                TaskRepository.tasks.add(newTask);
              });
            }
          },
          child: Icon(Icons.add),
        ),
      );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {final newTask = Task(
                title: titleController.text,
                deadline: deadlineController.text,
                done: false,
                priority: deadlineController.text,
              );
              Navigator.pop(context, newTask);},
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
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
