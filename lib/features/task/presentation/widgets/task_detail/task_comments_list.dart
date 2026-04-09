import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/task_comment_entity.dart';
import 'task_comment_card.dart';
import 'task_empty_comments.dart';

class TaskCommentsList extends StatelessWidget {
  final List<TaskCommentEntity> comments;

  const TaskCommentsList({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (comments.isEmpty) {
      return TaskEmptyComments(message: l10n.noComments);
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Column(
      children: comments.map((comment) {
        final isCurrentUser = comment.userId == currentUserId;

        return TaskCommentCard(
          comment: comment,
          isCurrentUser: isCurrentUser,
          formattedDate: dateFormat.format(comment.createdAt),
        );
      }).toList(),
    );
  }
}
