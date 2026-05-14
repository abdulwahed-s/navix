import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../project/domain/entities/milestone_entity.dart';
import '../../../../project/domain/entities/task_entity.dart';

class WorkspaceMilestoneOverview extends StatelessWidget {
  final List<MilestoneEntity> milestones;
  final List<TaskEntity> tasks;

  const WorkspaceMilestoneOverview({
    super.key,
    required this.milestones,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (milestones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'No milestones yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < milestones.length; i++) ...[
          _buildMilestoneCard(
            context,
            milestones[i],
            tasks.where((t) => t.milestoneId == milestones[i].id).toList(),
            isFirst: i == 0,
            isLast: i == milestones.length - 1,
          ),
        ],
      ],
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    MilestoneEntity milestone,
    List<TaskEntity> milestoneTasks, {
    required bool isFirst,
    required bool isLast,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final completedTasks = milestoneTasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final totalTasks = milestoneTasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysLeft = milestone.deadline.difference(today).inDays;
    final status = _getMilestoneStatus(milestone, progress, daysLeft);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: theme.colorScheme.outlineVariant,
                  ),

                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status.color.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: status.color.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: status == _MilestoneStatus.completed
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8, bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    status.color.withValues(alpha: 0.08),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              milestone.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.tasksCompleted(
                                    completedTasks,
                                    totalTasks,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      _buildStatusBadge(l10n, status, theme),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    status.color,
                                    status.color.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: status.color.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: daysLeft < 0
                            ? Colors.red
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        daysLeft >= 0
                            ? l10n.daysLeft(daysLeft)
                            : l10n.overdueWarning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: daysLeft < 0
                              ? Colors.red
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: daysLeft < 0 ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    AppLocalizations l10n,
    _MilestoneStatus status,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label(l10n),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: status.color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _MilestoneStatus _getMilestoneStatus(
    MilestoneEntity milestone,
    double progress,
    int daysLeft,
  ) {
    if (milestone.completed || progress >= 1.0) {
      return _MilestoneStatus.completed;
    }
    if (daysLeft < 0) {
      return _MilestoneStatus.overdue;
    }

    if (daysLeft <= 3 && progress < 0.8) {
      return _MilestoneStatus.atRisk;
    }
    return _MilestoneStatus.onTrack;
  }
}

enum _MilestoneStatus {
  onTrack,
  atRisk,
  overdue,
  completed;

  Color get color {
    switch (this) {
      case _MilestoneStatus.onTrack:
        return Colors.green;
      case _MilestoneStatus.atRisk:
        return Colors.orange;
      case _MilestoneStatus.overdue:
        return Colors.red;
      case _MilestoneStatus.completed:
        return Colors.blue;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case _MilestoneStatus.onTrack:
        return l10n.onTrack;
      case _MilestoneStatus.atRisk:
        return l10n.atRiskStatus;
      case _MilestoneStatus.overdue:
        return l10n.overdueStatus;
      case _MilestoneStatus.completed:
        return l10n.statusCompleted;
    }
  }
}
