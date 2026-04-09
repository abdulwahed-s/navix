import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../project/domain/entities/task_entity.dart';

class TaskPriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const TaskPriorityChip({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(priority).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: _getColor(priority),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.riskLow;
      case TaskPriority.medium:
        return AppColors.riskMedium;
      case TaskPriority.high:
        return AppColors.riskHigh;
      case TaskPriority.critical:
        return AppColors.riskCritical;
    }
  }
}
