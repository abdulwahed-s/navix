import 'package:flutter/material.dart';

import '../../../../project/domain/entities/task_entity.dart';
import 'task_priority_chip.dart';
import 'task_status_chip.dart';

class TaskHeaderCard extends StatelessWidget {
  final TaskEntity task;
  final void Function(TaskStatus newStatus) onStatusChanged;

  const TaskHeaderCard({
    super.key,
    required this.task,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              task.description.isNotEmpty ? task.description : 'No description',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                TaskPriorityChip(priority: task.priority),
                const SizedBox(width: 8),
                TaskStatusChip(
                  status: task.status,
                  onStatusChanged: onStatusChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
