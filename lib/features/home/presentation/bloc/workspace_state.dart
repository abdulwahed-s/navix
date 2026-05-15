part of 'workspace_bloc.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {
  const WorkspaceInitial();
}

class WorkspaceLoading extends WorkspaceState {
  const WorkspaceLoading();
}

class WorkspaceLoaded extends WorkspaceState {
  final ProjectEntity project;
  final ProjectRoadmapEntity roadmap;
  final ProjectMemberRole userRole;
  final List<ChatMessageEntity> messages;
  final String currentUserName;
  final TaskGrouping grouping;
  final String? selectedRoleFilter;
  final String? selectedTimeFilter;
  final TaskSortOrder sortOrder;

  const WorkspaceLoaded({
    required this.project,
    required this.roadmap,
    required this.userRole,
    this.messages = const [],
    this.currentUserName = 'User',
    this.grouping = TaskGrouping.none,
    this.selectedRoleFilter,
    this.selectedTimeFilter,
    this.sortOrder = TaskSortOrder.none,
  });

  List<TaskEntity> getMyTasks(String userId) {
    return roadmap.tasks.where((t) => t.assignedTo == userId).toList();
  }

  List<TaskEntity> getTasksByRole(String? role) {
    if (role == null) return roadmap.tasks;
    return roadmap.tasks.where((t) => t.requiredRole == role).toList();
  }

  List<TaskEntity> getTasksByTimeGroup(String timeGroup) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekFromNow = today.add(const Duration(days: 7));

    switch (timeGroup) {
      case 'overdue':
        return roadmap.tasks.where((t) => t.isOverdue).toList();
      case 'today':
        return roadmap.tasks.where((t) {
          if (t.deadline == null || t.status == TaskStatus.completed) {
            return false;
          }
          final deadline = DateTime(
            t.deadline!.year,
            t.deadline!.month,
            t.deadline!.day,
          );
          return deadline.isAtSameMomentAs(today);
        }).toList();
      case 'thisWeek':
        return roadmap.tasks.where((t) {
          if (t.deadline == null || t.status == TaskStatus.completed) {
            return false;
          }
          return t.deadline!.isAfter(today) &&
              t.deadline!.isBefore(weekFromNow);
        }).toList();
      case 'later':
        return roadmap.tasks.where((t) {
          if (t.deadline == null) return true;
          if (t.status == TaskStatus.completed) return false;
          return t.deadline!.isAfter(weekFromNow);
        }).toList();
      default:
        return roadmap.tasks;
    }
  }

  List<TaskEntity> getOverdueTasks() {
    return roadmap.tasks.where((t) => t.isOverdue).toList();
  }

  List<String> getUniqueRoles() {
    final roles = roadmap.tasks
        .where((t) => t.requiredRole != null)
        .map((t) => t.requiredRole!)
        .toSet()
        .toList();
    roles.sort();
    return roles;
  }

  double get overallProgress {
    if (roadmap.tasks.isEmpty) return 0;
    final completed = roadmap.tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    return completed / roadmap.tasks.length;
  }

  WorkspaceLoaded copyWith({
    ProjectEntity? project,
    ProjectRoadmapEntity? roadmap,
    ProjectMemberRole? userRole,
    List<ChatMessageEntity>? messages,
    String? currentUserName,
    TaskGrouping? grouping,
    String? selectedRoleFilter,
    String? selectedTimeFilter,
    TaskSortOrder? sortOrder,
    bool clearRoleFilter = false,
    bool clearTimeFilter = false,
  }) {
    return WorkspaceLoaded(
      project: project ?? this.project,
      roadmap: roadmap ?? this.roadmap,
      userRole: userRole ?? this.userRole,
      messages: messages ?? this.messages,
      currentUserName: currentUserName ?? this.currentUserName,
      grouping: grouping ?? this.grouping,
      selectedRoleFilter: clearRoleFilter
          ? null
          : (selectedRoleFilter ?? this.selectedRoleFilter),
      selectedTimeFilter: clearTimeFilter
          ? null
          : (selectedTimeFilter ?? this.selectedTimeFilter),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    project,
    roadmap,
    userRole,
    messages,
    currentUserName,
    grouping,
    selectedRoleFilter,
    selectedTimeFilter,
    sortOrder,
  ];
}

class WorkspaceError extends WorkspaceState {
  final String message;

  const WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}
