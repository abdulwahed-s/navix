import 'package:equatable/equatable.dart';

import '../../domain/entities/project_role_entity.dart';

abstract class ProjectSettingsState extends Equatable {
  const ProjectSettingsState();

  @override
  List<Object?> get props => [];
}

class ProjectSettingsInitial extends ProjectSettingsState {
  const ProjectSettingsInitial();
}

class ProjectSettingsLoading extends ProjectSettingsState {
  const ProjectSettingsLoading();
}

class ProjectSettingsLoaded extends ProjectSettingsState {
  final List<ProjectRoleEntity> roles;

  const ProjectSettingsLoaded({required this.roles});

  @override
  List<Object?> get props => [roles];
}

class ProjectSettingsError extends ProjectSettingsState {
  final String message;
  final String code;

  const ProjectSettingsError({required this.message, required this.code});

  @override
  List<Object?> get props => [message, code];
}

class RoleAssignedSuccess extends ProjectSettingsState {
  final List<ProjectRoleEntity> roles;

  const RoleAssignedSuccess({required this.roles});

  @override
  List<Object?> get props => [roles];
}
