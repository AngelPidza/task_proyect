import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task/screens/task_detail_screen.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onLoad;

  const TaskItem({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggle,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // Sombra principal según el estado
          BoxShadow(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          // Sombra secundaria para profundidad
          BoxShadow(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.05)
                : Colors.orange.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            width: 1,
          ),
        ),
        elevation: 0, // Quitamos la elevación predeterminada
        color: task.isCompleted ? Colors.green.withOpacity(0.02) : Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailTaskScreen(task: task),
              ),
            ).then((_) => onLoad());
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                      ),
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            key: ValueKey<bool>(task.isCompleted),
                            color:
                                task.isCompleted ? Colors.green : Colors.grey,
                          ),
                        ),
                        onPressed: onToggle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(task.date),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle_outline
                                : Icons.access_time,
                            size: 12,
                            color:
                                task.isCompleted ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.isCompleted ? 'Completada' : 'Pendiente',
                            style: TextStyle(
                              color: task.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
