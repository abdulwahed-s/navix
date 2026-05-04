import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_idea_entity.dart';
import '../repositories/ai_repository.dart';

class GenerateProjectIdeasUseCase
    implements UseCase<List<ProjectIdeaEntity>, GenerateIdeasParams> {
  final AIRepository repository;

  GenerateProjectIdeasUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProjectIdeaEntity>>> call(
    GenerateIdeasParams params,
  ) {
    return repository.generateProjectIdeas(params);
  }
}
