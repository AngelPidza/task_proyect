import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import '../widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _dbHelper.getAllTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _deleteTask(Task task) async {
    await _dbHelper.deleteTask(task.id!);
    _loadTasks();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea eliminada')),
    );
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      isCompleted: !task.isCompleted,
    );
    await _dbHelper.updateTask(updatedTask);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay tareas pendientes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return TaskItem(
                      task: task,
                      onDelete: () => _deleteTask(task),
                      onToggle: () => _toggleTaskStatus(task),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
