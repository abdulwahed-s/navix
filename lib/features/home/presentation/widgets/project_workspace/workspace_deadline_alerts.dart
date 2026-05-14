import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../profile/domain/entities/profile_entity.dart';
import '../../../../project/domain/entities/task_entity.dart';

class WorkspaceDeadlineAlerts extends StatelessWidget {
  final List<TaskEntity> tasks;
  final Future<String> Function(String userId) fetchUserName;
  final Future<ProfileEntity?> Function(String userId) fetchUserProfile;

  const WorkspaceDeadlineAlerts({
    super.key,
    required this.tasks,
    required this.fetchUserName,
    required this.fetchUserProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nearDeadlineTasks = tasks.where((task) {
      if (task.deadline == null) return false;
      if (task.status == TaskStatus.completed) return false;
      final daysLeft = task.deadline!.difference(today).inDays;
      return daysLeft >= 0 && daysLeft <= 7;
    }).toList()..sort((a, b) => a.deadline!.compareTo(b.deadline!));

    if (nearDeadlineTasks.isEmpty) {
      return _buildEmptyState(l10n, theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nearDeadlineTasks.map((task) {
        final daysLeft = task.deadline!.difference(today).inDays;
        return _buildAlertCard(context, task, daysLeft);
      }).toList(),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.12),
            Colors.green.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noNearingDeadlines,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All tasks are on track!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, TaskEntity task, int daysLeft) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final alertColor = _getAlertColor(daysLeft);
    final isUrgent = daysLeft <= 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            alertColor.withValues(alpha: 0.12),
            alertColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.35),
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: isUrgent
            ? [
                BoxShadow(
                  color: alertColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUrgent ? Icons.warning_rounded : Icons.schedule,
                color: alertColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (task.assignedTo != null)
                    FutureBuilder<ProfileEntity?>(
                      future: fetchUserProfile(task.assignedTo!),
                      builder: (context, snapshot) {
                        final profile = snapshot.data;
                        return Row(
                          children: [
                            if (profile?.profilePicUrl != null)
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: CachedNetworkImageProvider(
                                  profile!.profilePicUrl!,
                                ),
                              )
                            else
                              CircleAvatar(
                                radius: 10,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Text(
                                  (profile?.name ?? '?')[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                profile?.name ?? '...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 16,
                          color: theme.colorScheme.error.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.unassigned,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: alertColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: alertColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                daysLeft == 0 ? l10n.dueToday : l10n.daysLeft(daysLeft),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(int daysLeft) {
    if (daysLeft <= 1) return Colors.red.shade600;
    if (daysLeft <= 3) return Colors.orange.shade600;
    return Colors.amber.shade700;
  }
}
