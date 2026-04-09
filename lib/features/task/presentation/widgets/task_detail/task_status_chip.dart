import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../project/domain/entities/task_entity.dart';

class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;
  final void Function(TaskStatus) onStatusChanged;

  const TaskStatusChip({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaskStatus>(
      initialValue: status,
      onSelected: onStatusChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getColor(status).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status.displayName,
              style: TextStyle(
                color: _getColor(status),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: _getColor(status)),
          ],
        ),
      ),
      itemBuilder: (context) => TaskStatus.values.map((s) {
        return PopupMenuItem(
          value: s,
          child: Row(
            children: [
              Icon(
                s == TaskStatus.completed
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 16,
                color: _getColor(s),
              ),
              const SizedBox(width: 8),
              Text(s.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.grey;
      case TaskStatus.started:
        return AppColors.info;
      case TaskStatus.inProgress:
        return AppColors.info;
      case TaskStatus.fixing:
        return AppColors.warning;
      case TaskStatus.blocked:
        return AppColors.riskHigh;
      case TaskStatus.inReview:
        return AppColors.warning;
      case TaskStatus.completed:
        return AppColors.success;
    }
  }
}
