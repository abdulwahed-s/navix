import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ai/domain/entities/prd_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/project_roadmap_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/generate_roadmap_usecase.dart';

part 'project_creation_event.dart';
part 'project_creation_state.dart';

class ProjectCreationBloc
    extends Bloc<ProjectCreationEvent, ProjectCreationState> {
  final GenerateRoadmapUseCase generateRoadmapUseCase;
  final CreateProjectUseCase createProjectUseCase;

  ProjectRoadmapEntity? _roadmap;
  String _projectName = '';
  String _projectDescription = '';
  DateTime? _startDate;
  DateTime? _endDate;
  int _teamSize = 1;

  ProjectCreationBloc({
    required this.generateRoadmapUseCase,
    required this.createProjectUseCase,
  }) : super(const ProjectCreationInitial()) {
    on<GenerateRoadmapRequested>(_onGenerateRoadmapRequested);
    on<ConfirmAndCreateProject>(_onConfirmAndCreateProject);
    on<ResetProjectCreation>(_onResetProjectCreation);
  }

  Future<void> _onGenerateRoadmapRequested(
    GenerateRoadmapRequested event,
    Emitter<ProjectCreationState> emit,
  ) async {
    emit(const GeneratingRoadmap());

    _projectName = event.projectName;
    _projectDescription = event.projectDescription;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _teamSize = event.teamSize;

    final result = await generateRoadmapUseCase(
      GenerateRoadmapParams(
        projectName: event.projectName,
        projectDescription: event.projectDescription,
        skills: event.skills,
        teamSize: event.teamSize,
        startDate: event.startDate,
        endDate: event.endDate,
        isTeamProject: event.isTeamProject,
      ),
    );

    result.fold(
      (failure) => emit(
        ProjectCreationError(message: failure.message, code: failure.code),
      ),
      (roadmap) {
        _roadmap = roadmap;
        emit(
          RoadmapGenerated(
            roadmap: roadmap,
            projectName: event.projectName,
            projectDescription: event.projectDescription,
            startDate: event.startDate,
            endDate: event.endDate,
            teamSize: event.teamSize,
          ),
        );
      },
    );
  }

  Future<void> _onConfirmAndCreateProject(
    ConfirmAndCreateProject event,
    Emitter<ProjectCreationState> emit,
  ) async {
    if (_roadmap == null || _startDate == null || _endDate == null) {
      emit(
        const ProjectCreationError(
          message: 'Please generate a roadmap first',
          code: 'no-roadmap',
        ),
      );
      return;
    }

    emit(const SavingProject());

    final project = ProjectEntity(
      id: '',
      name: _projectName,
      description: _projectDescription,
      leaderId: event.leaderId,
      memberIds: [],
      status: ProjectStatus.active,
      startDate: _startDate!,
      endDate: _endDate!,
      createdAt: DateTime.now(),
    );

    final durationDays = _endDate!.difference(_startDate!).inDays;
    final durationWeeks = (durationDays / 7).round();

    final updatedPrd = event.prd?.copyWith(
      teamSize: _teamSize,
      estimatedDurationWeeks: durationWeeks > 0 ? durationWeeks : 1,
    );

    final result = await createProjectUseCase(
      CreateProjectParams(
        project: project,
        roadmap: _roadmap!,
        prd: updatedPrd,
      ),
    );

    result.fold(
      (failure) => emit(
        ProjectCreationError(message: failure.message, code: failure.code),
      ),
      (createdProject) => emit(ProjectCreated(createdProject)),
    );
  }

  void _onResetProjectCreation(
    ResetProjectCreation event,
    Emitter<ProjectCreationState> emit,
  ) {
    _roadmap = null;
    _projectName = '';
    _projectDescription = '';
    _startDate = null;
    _endDate = null;
    _teamSize = 1;
    emit(const ProjectCreationInitial());
  }
}
