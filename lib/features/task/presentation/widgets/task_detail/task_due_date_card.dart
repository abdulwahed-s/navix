import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class TaskDueDateCard extends StatelessWidget {
  final DateTime deadline;
  final bool isOverdue;

  const TaskDueDateCard({
    super.key,
    required this.deadline,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final now = DateTime.now();
    final daysUntil = deadline.difference(now).inDays;

    String dueDateText;
    if (isOverdue) {
      dueDateText = l10n.overdueTask;
    } else if (daysUntil == 0) {
      dueDateText = l10n.dueToday;
    } else {
      dueDateText = l10n.dueIn(daysUntil);
    }

    return Card(
      color: isOverdue ? AppColors.riskHigh.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: Icon(
          Icons.event,
          color: isOverdue ? AppColors.riskHigh : theme.colorScheme.primary,
        ),
        title: Text(l10n.dueDate),
        subtitle: Text(dateFormat.format(deadline)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOverdue
                ? AppColors.riskHigh.withValues(alpha: 0.2)
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            dueDateText,
            style: TextStyle(
              color: isOverdue
                  ? AppColors.riskHigh
                  : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
