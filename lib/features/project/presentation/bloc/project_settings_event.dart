import 'package:equatable/equatable.dart';

abstract class ProjectSettingsEvent extends Equatable {
  const ProjectSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectSettings extends ProjectSettingsEvent {
  final String projectId;

  const LoadProjectSettings({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class AssignRoleToMember extends ProjectSettingsEvent {
  final String projectId;
  final String roleName;
  final String userId;
  final String userName;

  const AssignRoleToMember({
    required this.projectId,
    required this.roleName,
    required this.userId,
    required this.userName,
  });

  @override
  List<Object?> get props => [projectId, roleName, userId, userName];
}

class UnassignRole extends ProjectSettingsEvent {
  final String projectId;
  final String roleName;

  const UnassignRole({required this.projectId, required this.roleName});

  @override
  List<Object?> get props => [projectId, roleName];
}
