import 'package:equatable/equatable.dart';

class ProjectRoleEntity extends Equatable {
  final String roleName;

  final String? assignedUserId;

  final String? assignedUserName;

  final int taskCount;

  const ProjectRoleEntity({
    required this.roleName,
    this.assignedUserId,
    this.assignedUserName,
    required this.taskCount,
  });

  ProjectRoleEntity copyWith({
    String? roleName,
    String? assignedUserId,
    String? assignedUserName,
    int? taskCount,
  }) {
    return ProjectRoleEntity(
      roleName: roleName ?? this.roleName,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  @override
  List<Object?> get props => [
    roleName,
    assignedUserId,
    assignedUserName,
    taskCount,
  ];
}
