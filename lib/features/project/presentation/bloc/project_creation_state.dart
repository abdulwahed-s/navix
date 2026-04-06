part of 'project_creation_bloc.dart';

abstract class ProjectCreationState extends Equatable {
  const ProjectCreationState();

  @override
  List<Object?> get props => [];
}

class ProjectCreationInitial extends ProjectCreationState {
  const ProjectCreationInitial();
}

class GeneratingRoadmap extends ProjectCreationState {
  const GeneratingRoadmap();
}

class RoadmapGenerated extends ProjectCreationState {
  final ProjectRoadmapEntity roadmap;
  final String projectName;
  final String projectDescription;
  final DateTime startDate;
  final DateTime endDate;
  final int teamSize;

  const RoadmapGenerated({
    required this.roadmap,
    required this.projectName,
    required this.projectDescription,
    required this.startDate,
    required this.endDate,
    required this.teamSize,
  });

  @override
  List<Object?> get props => [
    roadmap,
    projectName,
    projectDescription,
    startDate,
    endDate,
    teamSize,
  ];
}

class SavingProject extends ProjectCreationState {
  const SavingProject();
}

class ProjectCreated extends ProjectCreationState {
  final ProjectEntity project;

  const ProjectCreated(this.project);

  @override
  List<Object?> get props => [project];
}

class ProjectCreationError extends ProjectCreationState {
  final String message;
  final String? code;

  const ProjectCreationError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}
