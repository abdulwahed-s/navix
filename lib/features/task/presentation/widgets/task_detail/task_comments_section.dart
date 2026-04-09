import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/task_comment_entity.dart';
import 'task_comments_list.dart';

class TaskCommentsSection extends StatelessWidget {
  final List<TaskCommentEntity> comments;

  const TaskCommentsSection({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.comments,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TaskCommentsList(comments: comments),
      ],
    );
  }
}
