import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class WorkspaceTeamMemberCard extends StatelessWidget {
  final String userName;
  final bool isLoading;
  final bool isLeader;
  final int assignedTasksCount;

  const WorkspaceTeamMemberCard({
    super.key,
    required this.userName,
    required this.isLoading,
    required this.isLeader,
    required this.assignedTasksCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLeader
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isLeader
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSecondaryContainer,
                  ),
                )
              : Text(
                  userName[0].toUpperCase(),
                  style: TextStyle(
                    color: isLeader
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(userName)),
            if (isLeader)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
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
        subtitle: Text(l10n.tasksAssigned(assignedTasksCount)),
      ),
    );
  }
}
