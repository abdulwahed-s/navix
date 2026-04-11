import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../widgets/task_detail/task_assignee_card.dart';
import '../widgets/task_detail/task_comment_input.dart';
import '../widgets/task_detail/task_comments_section.dart';
import '../widgets/task_detail/task_due_date_card.dart';
import '../widgets/task_detail/task_header_card.dart';
import '../widgets/task_detail/task_reassign_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  final String projectId;
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(
      LoadTask(projectId: widget.projectId, taskId: widget.taskId),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskDeleted) {
          context.pop();
        } else if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.taskDetails)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TaskLoaded) {
          return _buildTaskDetail(state, l10n, theme);
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.taskDetails)),
          body: Center(child: Text(l10n.errorOccurred)),
        );
      },
    );
  }

  Widget _buildTaskDetail(
    TaskLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final task = state.task;
    final isOverdue =
        task.deadline != null &&
        task.deadline!.isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isLeader = state.leaderId == currentUserId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taskDetails)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaskHeaderCard(
                    task: task,
                    onStatusChanged: (newStatus) {
                      context.read<TaskBloc>().add(
                        UpdateStatus(newStatus: newStatus),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  if (task.deadline != null)
                    TaskDueDateCard(
                      deadline: task.deadline!,
                      isOverdue: isOverdue,
                    ),
                  const SizedBox(height: 16),

                  TaskAssigneeCard(
                    assignedTo: task.assignedTo,
                    showReassignButton: isLeader,
                    onReassign: () => _showReassignDialog(state, l10n),
                  ),
                  const SizedBox(height: 24),

                  TaskCommentsSection(comments: state.comments),
                ],
              ),
            ),
          ),

          TaskCommentInput(
            controller: _commentController,
            onSubmit: _submitComment,
          ),
        ],
      ),
    );
  }

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    context.read<TaskBloc>().add(AddComment(comment: comment));
    _commentController.clear();
  }

  void _showReassignDialog(TaskLoaded state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => TaskReassignDialog(
        memberIds: state.memberIds,
        leaderId: state.leaderId ?? '',
        currentAssignee: state.task.assignedTo,
        onReassign: (newAssigneeId) {
          context.read<TaskBloc>().add(
            ReassignTask(newAssigneeId: newAssigneeId),
          );
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.taskReassigned)));
          }
        },
      ),
    );
  }
}
