import 'package:flutter/material.dart';
import 'task_repository.dart';
import '../services/task_api_service.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../services/task_sync_service.dart';
import '../services/task_local_database.dart';
import 'dart:math';

void main() async {
  await Hive.initFlutter(); // inicjalizacja
  await Hive.openBox("tasks"); // otwarcie kontenera
  runApp(MaterialApp(home: HomeScreen(),));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _MyApp();
}

class TaskListScreen extends StatefulWidget {
  final String currentFilter;
  final ValueChanged<List<Task>> onTasksLoaded;
  const TaskListScreen({super.key, required this.currentFilter, required this.onTasksLoaded});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _MyApp extends State<HomeScreen>{
  String filter = "wszystkie";
  String selectedFilter = "wszystkie";
  bool pressedAll = true;
  bool pressedDone = false;
  bool pressedUndone = false;
  int allTasksCount = 0;
  int doneTasksCount = 0;
  int todoTasksCount = 0;

  // tworzymy funkcję aktualizującą
  void updateCounters(List<Task> tasks) {
    setState(() {
      allTasksCount = tasks.length;
      doneTasksCount = tasks.where((task) => task.done).length;
      todoTasksCount = tasks.where((task) => !task.done).length;
    });
  }

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
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Potwierdzenie"),
                      content: Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Anuluj"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              TaskLocalDatabase.deleteAllTasks();
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Wszystkie zadania zostały usunięte"),
                              ),
                            );
                          },
                          child: Text("Usuń"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
           children: [
             Text("Masz dziś $allTasksCount zadań."),
             SizedBox(height: 8),
             Row(
               children: [
                 TextButton(
                   onPressed: () {
                     setState(() {
                       selectedFilter = "wszystkie";
                       pressedAll = true;
                       pressedDone = false;
                       pressedUndone = false;
                     });
                   },
                   child: Text(
                     "Wszystkie",
                     style: TextStyle(
                       color: pressedAll
                           ? Colors.blueAccent
                           : Colors.black,
                     ),
                   ),
                 ),
                 TextButton(
                   onPressed: () {
                     setState(() {
                       selectedFilter = "do zrobienia";
                       pressedUndone = true;
                       pressedAll = false;
                       pressedDone = false;
                     });
                   },
                   child: Text(
                     "Do zrobienia",
                     style: TextStyle(
                       color: pressedUndone
                           ? Colors.blueAccent
                           : Colors.black,
                     ),
                   ),
                 ),
                 TextButton(
                   onPressed: () {
                     setState(() {
                       selectedFilter = "wykonane";
                       pressedDone = true;
                       pressedAll = false;
                       pressedUndone = false;
                     });
                   },
                   child: Text(
                     "Wykonane",
                     style: TextStyle(
                       color: pressedDone
                           ? Colors.blueAccent
                           : Colors.black,
                     ),
                   ),
                 ),
               ],
             ),
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
               child: TaskListScreen(
                 currentFilter: selectedFilter,
                 onTasksLoaded: updateCounters,
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
              await TaskLocalDatabase.addTask(newTask);

              setState(() {
                TaskLocalDatabase.addTask(newTask);
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
                id: Random().nextInt(1000000),
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

class EditTaskScreen extends StatelessWidget{
  final Task task;
  EditTaskScreen({
    required this.task
  });

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edytuj zadanie"),
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
              onPressed: () {final updatedTask = Task(
                id: Random().nextInt(1000000),
                title: titleController.text,
                deadline: deadlineController.text,
                done: false,
                priority: deadlineController.text,
              );
              Navigator.pop(context, updatedTask);},
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
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: done
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: done
                ? Colors.grey
                : Colors.black
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
              color: done
                  ? Colors.grey
                  : Colors.black
          ),
        ),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> tasksFuture;
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    "Wystąpił błąd: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tasksFuture = loadTasks();
                      });
                    },
                    child: const Text("Spróbuj ponownie"),
                  )
                ],
              ),
            );
          }

          List<Task> filteredTasks = TaskLocalDatabase.getTasks();
          if (widget.currentFilter == "wykonane") {
            filteredTasks = TaskLocalDatabase.doneTasks();
          } else if (widget.currentFilter == "do zrobienia") {
            filteredTasks = TaskLocalDatabase.undoneTasks();
          }

          final tasks = snapshot.data ?? [];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onTasksLoaded(tasks);
          });

          if (filteredTasks.isEmpty) {
            return const Center(child: Text("Brak zadań do wyświetlenia"));
          }

          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              // widget TaskCard dla każdego elementu
              final task = filteredTasks[index];
              return Dismissible(
                key: ValueKey(task.title),
                onDismissed: (direction) {
                  setState(() {
                    TaskLocalDatabase.deleteTask(task.id);
                    tasksFuture = loadTasks();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Zadanie usunięte"),
                    ),
                  );
                  },
                child: TaskCard(
                    title: task.title,
                    subtitle: "termin: ${task.deadline} | piorytet: ${task.priority}",
                    done: task.done,
                    onChanged: (value) async {
                      final updatedTask = Task(
                        id: task.id,
                        title: task.title,
                        deadline: task.deadline,
                        priority: task.priority,
                        done: value ?? false,
                      );
                      await TaskLocalDatabase.updateTask(updatedTask);
                      setState(() {
                        tasksFuture = loadTasks();
                      });
                      },
                    onTap: () async {
                      final Task? updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                      if (updatedTask != null) {
                        await TaskLocalDatabase.updateTask(updatedTask);
                        setState(() {
                          tasksFuture = loadTasks();
                        });
                      }
                    }),
                );
              },
            );
        }
    );
  }
}
