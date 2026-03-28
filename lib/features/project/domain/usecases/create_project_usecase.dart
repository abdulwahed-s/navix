import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../ai/domain/entities/prd_entity.dart';
import '../entities/project_entity.dart';
import '../entities/project_roadmap_entity.dart';
import '../repositories/project_repository.dart';

class CreateProjectUseCase
    implements UseCase<ProjectEntity, CreateProjectParams> {
  final ProjectRepository repository;

  CreateProjectUseCase(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(CreateProjectParams params) {
    return repository.createProject(
      project: params.project,
      roadmap: params.roadmap,
      prd: params.prd,
    );
  }
}

class CreateProjectParams extends Equatable {
  final ProjectEntity project;
  final ProjectRoadmapEntity roadmap;
  final PrdEntity? prd;

  const CreateProjectParams({
    required this.project,
    required this.roadmap,
    this.prd,
  });

  @override
  List<Object?> get props => [project, roadmap, prd];
}
