import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/prd_entity.dart';
import '../entities/project_idea_entity.dart';
import '../entities/refined_idea_entity.dart';

abstract class AIRepository {
  Future<Either<Failure, List<ProjectIdeaEntity>>> generateProjectIdeas(
    GenerateIdeasParams params,
  );

  Future<Either<Failure, RefinedIdeaEntity>> refineProjectIdea({
    required String ideaDescription,
    required List<String> userSkills,
    String? additionalContext,
  });

  Future<Either<Failure, PrdEntity>> generatePrd(GeneratePrdParams params);
}

class GenerateIdeasParams extends Equatable {
  final List<String> userSkills;

  final String goals;

  final String? preferences;

  final bool isTeamProject;

  const GenerateIdeasParams({
    required this.userSkills,
    required this.goals,
    this.preferences,
    this.isTeamProject = false,
  });

  @override
  List<Object?> get props => [userSkills, goals, preferences, isTeamProject];
}

class RefineIdeaParams extends Equatable {
  final String ideaDescription;

  final List<String> userSkills;

  final String? additionalContext;

  const RefineIdeaParams({
    required this.ideaDescription,
    required this.userSkills,
    this.additionalContext,
  });

  @override
  List<Object?> get props => [ideaDescription, userSkills, additionalContext];
}

class GeneratePrdParams extends Equatable {
  final ProjectIdeaEntity selectedIdea;

  final List<String> userSkills;

  final bool isTeamProject;

  const GeneratePrdParams({
    required this.selectedIdea,
    required this.userSkills,
    this.isTeamProject = false,
  });

  @override
  List<Object?> get props => [selectedIdea, userSkills, isTeamProject];
}
