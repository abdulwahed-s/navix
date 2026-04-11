part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final TaskEntity task;
  final List<TaskCommentEntity> comments;
  final bool isUpdating;
  final String? leaderId;
  final List<String> memberIds;

  const TaskLoaded({
    required this.task,
    this.comments = const [],
    this.isUpdating = false,
    this.leaderId,
    this.memberIds = const [],
  });

  TaskLoaded copyWith({
    TaskEntity? task,
    List<TaskCommentEntity>? comments,
    bool? isUpdating,
    String? leaderId,
    List<String>? memberIds,
  }) {
    return TaskLoaded(
      task: task ?? this.task,
      comments: comments ?? this.comments,
      isUpdating: isUpdating ?? this.isUpdating,
      leaderId: leaderId ?? this.leaderId,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  @override
  List<Object?> get props => [task, comments, isUpdating, leaderId, memberIds];
}

class TaskOperationSuccess extends TaskState {
  final String message;
  final TaskLoaded previousState;

  const TaskOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

class TaskDeleted extends TaskState {
  const TaskDeleted();
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
