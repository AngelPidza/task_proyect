import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const TaskItem({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: task.isCompleted ? Colors.green : Colors.grey,
                  ),
                  onPressed: onToggle,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
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
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(task.date)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
