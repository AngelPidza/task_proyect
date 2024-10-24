import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import '../widgets/task_item.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'pending', 'completed'

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
    // Imprimimos el número de tareas para verificar
    print('Número de tareas cargadas: ${tasks.length}');
    // Imprimimos los detalles de cada tarea
    for (var task in tasks) {
      print(
          'ID: ${task.id}, Título: ${task.title}, Completada: ${task.isCompleted}');
    }
  }

  List<Task> get _filteredTasks {
    switch (_selectedFilter) {
      case 'pending':
        return _tasks.where((task) => !task.isCompleted).toList();
      case 'completed':
        return _tasks.where((task) => task.isCompleted).toList();
      default:
        return _tasks;
    }
  }

  Future<void> _deleteTask(Task task) async {
    await _dbHelper.deleteTask(task.id!);
    _loadTasks();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarea eliminada'),
        backgroundColor: Colors.redAccent,
      ),
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
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // Centra el título
              title: const Text('Mis Tareas',
                  style: TextStyle(color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.blue, Colors.indigo],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Tienes ${_filteredTasks.where((task) => !task.isCompleted).length} tareas pendientes',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 60.0,
              maxHeight: 60.0,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'Todas',
                                selected: _selectedFilter == 'all',
                                onSelected: (selected) {
                                  setState(() => _selectedFilter = 'all');
                                },
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Pendientes',
                                selected: _selectedFilter == 'pending',
                                onSelected: (selected) {
                                  setState(() => _selectedFilter = 'pending');
                                },
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Completadas',
                                selected: _selectedFilter == 'completed',
                                onSelected: (selected) {
                                  setState(() => _selectedFilter = 'completed');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredTasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay tareas',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añade una nueva tarea tocando el botón +',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = _filteredTasks[index];
                    return TaskItem(
                      task: task,
                      onDelete: () => _deleteTask(task),
                      onToggle: () async {
                        await _toggleTaskStatus(task);
                      },
                      onLoad: () => _loadTasks(),
                    );
                  },
                  childCount: _filteredTasks.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          _loadTasks(); // Recargar la lista después de agregar una tarea
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
