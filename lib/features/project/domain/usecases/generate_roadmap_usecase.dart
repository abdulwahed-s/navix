import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_roadmap_entity.dart';
import '../repositories/project_repository.dart';

abstract class RoadmapRepository {
  Future<Either<Failure, ProjectRoadmapEntity>> generateRoadmap(
    GenerateRoadmapParams params,
  );
}

class GenerateRoadmapUseCase
    implements UseCase<ProjectRoadmapEntity, GenerateRoadmapParams> {
  final RoadmapRepository repository;

  GenerateRoadmapUseCase(this.repository);

  @override
  Future<Either<Failure, ProjectRoadmapEntity>> call(
    GenerateRoadmapParams params,
  ) {
    return repository.generateRoadmap(params);
  }
}
