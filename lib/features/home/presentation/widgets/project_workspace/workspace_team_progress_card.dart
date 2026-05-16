import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class WorkspaceTeamProgressCard extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final int completedTasks;
  final int totalTasks;
  final bool isLeader;
  final bool isLoading;

  const WorkspaceTeamProgressCard({
    super.key,
    required this.userName,
    this.avatarUrl,
    required this.completedTasks,
    required this.totalTasks,
    this.isLeader = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isLeader
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? (isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        : Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: isLeader
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                  : null,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isLeader)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.roleLeader,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tasksCompleted(completedTasks, totalTasks),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progress, theme),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getProgressColor(progress, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    if (progress > 0) return theme.colorScheme.primary;
    return theme.colorScheme.outline;
  }
}
