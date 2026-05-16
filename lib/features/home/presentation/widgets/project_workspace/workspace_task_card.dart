import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../project/domain/entities/task_entity.dart';

class WorkspaceTaskCard extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<TaskStatus> onStatusChanged;
  final VoidCallback onAIChatPressed;
  final VoidCallback? onTap;

  const WorkspaceTaskCard({
    super.key,
    required this.task,
    required this.onStatusChanged,
    required this.onAIChatPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final urgency = task.urgency;
    final isOverdue = task.isOverdue;
    final isCompleted = task.status == TaskStatus.completed;

    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? AppColors.riskHigh.withValues(alpha: 0.5)
              : isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isOverdue ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOverdue ? AppColors.riskHigh : Colors.black).withValues(
              alpha: isDark ? 0.15 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusButton(context, l10n, theme),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (isOverdue) _buildOverdueBadge(l10n),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildPriorityBadge(task.priority, priorityColor),
                              _buildUrgencyBadge(urgency),
                              if (task.estimatedHours > 0)
                                _buildTimeBadge(task.estimatedHours, theme),
                              if (task.deadline != null)
                                _buildDeadlineBadge(
                                  task.deadline!,
                                  theme,
                                  l10n,
                                ),
                            ],
                          ),

                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    if (task.requiredRole != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.requiredRole!,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ] else
                      const Spacer(),

                    TextButton.icon(
                      onPressed: onAIChatPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.smart_toy, size: 16),
                      label: Text(
                        l10n.chatWithNavixAI,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return PopupMenuButton<TaskStatus>(
      initialValue: task.status,
      onSelected: onStatusChanged,
      tooltip: l10n.status,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getStatusColor(task.status).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _getStatusIcon(task.status),
      ),
      itemBuilder: (context) => TaskStatus.values.map((s) {
        return PopupMenuItem(
          value: s,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatusColor(s).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _getStatusIcon(s, size: 18),
              ),
              const SizedBox(width: 12),
              Text(s.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverdueBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.riskHigh,
            AppColors.riskHigh.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.riskHigh.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            l10n.overdueWarning,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPriorityIcon(priority), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            priority.displayName,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge(TaskUrgency urgency) {
    final color = _getUrgencyColor(urgency);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getUrgencyIcon(urgency), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            urgency.displayName,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(double hours, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: theme.colorScheme.tertiary),
          const SizedBox(width: 4),
          Text(
            '${hours.toStringAsFixed(0)}h',
            style: TextStyle(
              color: theme.colorScheme.tertiary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineBadge(
    DateTime deadline,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;
    final isUrgent = daysLeft <= 3 && daysLeft >= 0;

    final color = isUrgent ? Colors.orange : theme.colorScheme.secondary;
    final dateStr = '${deadline.day}/${deadline.month}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            dateStr,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.critical:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
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

  Color _getUrgencyColor(TaskUrgency urgency) {
    switch (urgency) {
      case TaskUrgency.low:
        return AppColors.riskLow;
      case TaskUrgency.medium:
        return AppColors.riskMedium;
      case TaskUrgency.high:
        return AppColors.riskHigh;
      case TaskUrgency.critical:
        return AppColors.riskCritical;
    }
  }

  IconData _getUrgencyIcon(TaskUrgency urgency) {
    switch (urgency) {
      case TaskUrgency.low:
        return Icons.trending_down;
      case TaskUrgency.medium:
        return Icons.trending_flat;
      case TaskUrgency.high:
        return Icons.trending_up;
      case TaskUrgency.critical:
        return Icons.local_fire_department;
    }
  }

  Color _getStatusColor(TaskStatus status) {
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

  Icon _getStatusIcon(TaskStatus status, {double size = 20}) {
    switch (status) {
      case TaskStatus.notStarted:
        return Icon(Icons.circle_outlined, color: Colors.grey[400], size: size);
      case TaskStatus.started:
        return Icon(
          Icons.radio_button_checked,
          color: AppColors.info,
          size: size,
        );
      case TaskStatus.inProgress:
        return Icon(Icons.play_circle, color: AppColors.info, size: size);
      case TaskStatus.fixing:
        return Icon(Icons.build_circle, color: AppColors.warning, size: size);
      case TaskStatus.blocked:
        return Icon(Icons.block, color: AppColors.riskHigh, size: size);
      case TaskStatus.inReview:
        return Icon(Icons.rate_review, color: AppColors.warning, size: size);
      case TaskStatus.completed:
        return Icon(Icons.check_circle, color: AppColors.success, size: size);
    }
  }
}
