import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../project/domain/entities/milestone_entity.dart';

class WorkspaceMilestoneItem extends StatelessWidget {
  final MilestoneEntity milestone;

  const WorkspaceMilestoneItem({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d');
    final isOverdue =
        milestone.deadline.isBefore(DateTime.now()) && !milestone.completed;

    Color statusColor = milestone.completed
        ? AppColors.success
        : isOverdue
        ? AppColors.riskHigh
        : AppColors.accentGold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: 0.2),
                statusColor.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            milestone.completed ? Icons.check : Icons.flag,
            color: statusColor,
            size: 20,
          ),
        ),
        title: Text(
          milestone.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: milestone.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              dateFormat.format(milestone.deadline),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverdue ? AppColors.riskHigh : null,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            milestone.completed
                ? 'Done'
                : isOverdue
                ? 'Overdue'
                : 'Pending',
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
