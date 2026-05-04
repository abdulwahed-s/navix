import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/refined_idea_entity.dart';
import '../repositories/ai_repository.dart';

class RefineProjectIdeaParams {
  final String ideaDescription;
  final List<String> userSkills;
  final String? additionalContext;

  const RefineProjectIdeaParams({
    required this.ideaDescription,
    required this.userSkills,
    this.additionalContext,
  });
}

class RefineProjectIdeaUseCase
    implements UseCase<RefinedIdeaEntity, RefineProjectIdeaParams> {
  final AIRepository repository;

  RefineProjectIdeaUseCase({required this.repository});

  @override
  Future<Either<Failure, RefinedIdeaEntity>> call(
    RefineProjectIdeaParams params,
  ) async {
    return await repository.refineProjectIdea(
      ideaDescription: params.ideaDescription,
      userSkills: params.userSkills,
      additionalContext: params.additionalContext,
    );
  }
}
