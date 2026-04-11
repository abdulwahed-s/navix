part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTask extends TaskEvent {
  final String projectId;
  final String taskId;

  const LoadTask({required this.projectId, required this.taskId});

  @override
  List<Object?> get props => [projectId, taskId];
}

class UpdateStatus extends TaskEvent {
  final TaskStatus newStatus;

  const UpdateStatus({required this.newStatus});

  @override
  List<Object?> get props => [newStatus];
}

class AddComment extends TaskEvent {
  final String comment;

  const AddComment({required this.comment});

  @override
  List<Object?> get props => [comment];
}

class ReassignTask extends TaskEvent {
  final String newAssigneeId;

  const ReassignTask({required this.newAssigneeId});

  @override
  List<Object?> get props => [newAssigneeId];
}

class DeleteTask extends TaskEvent {
  const DeleteTask();
}

class CommentsUpdated extends TaskEvent {
  final List<TaskCommentEntity> comments;

  const CommentsUpdated(this.comments);

  @override
  List<Object?> get props => [comments];
}
