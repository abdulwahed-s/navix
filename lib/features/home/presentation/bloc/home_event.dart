part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends HomeEvent {
  final String userId;

  const LoadProjects({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshProjects extends HomeEvent {
  final String userId;

  const RefreshProjects({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProjectsUpdated extends HomeEvent {
  final List<ProjectEntity> projects;

  const ProjectsUpdated(this.projects);

  @override
  List<Object?> get props => [projects];
}

class SelectProject extends HomeEvent {
  final String projectId;

  const SelectProject({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}
