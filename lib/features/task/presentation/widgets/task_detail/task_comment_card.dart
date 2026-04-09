import 'package:flutter/material.dart';

import '../../../domain/entities/task_comment_entity.dart';

class TaskCommentCard extends StatelessWidget {
  final TaskCommentEntity comment;
  final bool isCurrentUser;
  final String formattedDate;

  const TaskCommentCard({
    super.key,
    required this.comment,
    required this.isCurrentUser,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = comment.userName.isNotEmpty
        ? comment.userName
        : 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isCurrentUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      backgroundImage:
                          comment.userProfilePicUrl != null &&
                              comment.userProfilePicUrl!.isNotEmpty
                          ? NetworkImage(comment.userProfilePicUrl!)
                          : null,
                      child:
                          comment.userProfilePicUrl == null ||
                              comment.userProfilePicUrl!.isEmpty
                          ? Text(
                              displayName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isCurrentUser
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.comment),
          ],
        ),
      ),
    );
  }
}
