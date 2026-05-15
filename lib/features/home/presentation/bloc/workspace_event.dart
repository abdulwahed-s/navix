part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkspace extends WorkspaceEvent {
  final String projectId;
  final String userId;

  const LoadWorkspace({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

class UpdateTaskStatus extends WorkspaceEvent {
  final String taskId;
  final TaskStatus newStatus;

  const UpdateTaskStatus({required this.taskId, required this.newStatus});

  @override
  List<Object?> get props => [taskId, newStatus];
}

class SendChatMessage extends WorkspaceEvent {
  final String content;
  final String senderName;

  const SendChatMessage({required this.content, required this.senderName});

  @override
  List<Object?> get props => [content, senderName];
}

class UpdateMessages extends WorkspaceEvent {
  final List<ChatMessageEntity> messages;

  const UpdateMessages(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChangeTaskGrouping extends WorkspaceEvent {
  final TaskGrouping grouping;

  const ChangeTaskGrouping(this.grouping);

  @override
  List<Object?> get props => [grouping];
}

class FilterByRole extends WorkspaceEvent {
  final String? role;

  const FilterByRole(this.role);

  @override
  List<Object?> get props => [role];
}

class FilterByTime extends WorkspaceEvent {
  final String? timeGroup;

  const FilterByTime(this.timeGroup);

  @override
  List<Object?> get props => [timeGroup];
}

class RefreshWorkspace extends WorkspaceEvent {
  const RefreshWorkspace();
}

enum TaskGrouping { none, byRole, byTime }

enum TaskSortOrder {
  none,
  priorityHighToLow,
  priorityLowToHigh,
  deadlineAsc,
  deadlineDesc,
}

class ChangeSortOrder extends WorkspaceEvent {
  final TaskSortOrder sortOrder;

  const ChangeSortOrder(this.sortOrder);

  @override
  List<Object?> get props => [sortOrder];
}
