part of 'project_creation_bloc.dart';

abstract class ProjectCreationEvent extends Equatable {
  const ProjectCreationEvent();

  @override
  List<Object?> get props => [];
}

class GenerateRoadmapRequested extends ProjectCreationEvent {
  final String projectName;
  final String projectDescription;
  final List<String> skills;
  final int teamSize;
  final DateTime startDate;
  final DateTime endDate;
  final bool isTeamProject;

  const GenerateRoadmapRequested({
    required this.projectName,
    required this.projectDescription,
    required this.skills,
    required this.teamSize,
    required this.startDate,
    required this.endDate,
    this.isTeamProject = false,
  });

  @override
  List<Object?> get props => [
    projectName,
    projectDescription,
    skills,
    teamSize,
    startDate,
    endDate,
    isTeamProject,
  ];
}

class ConfirmAndCreateProject extends ProjectCreationEvent {
  final String leaderId;
  final PrdEntity? prd;

  const ConfirmAndCreateProject({required this.leaderId, this.prd});

  @override
  List<Object?> get props => [leaderId, prd];
}

class ResetProjectCreation extends ProjectCreationEvent {
  const ResetProjectCreation();
}
