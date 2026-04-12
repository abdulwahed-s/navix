import '../entities/survey_entity.dart';
import '../repositories/survey_repository.dart';

class GenerateSurveyParams {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final String userPrompt;
  final String creatorId;
  final String? templateType;

  const GenerateSurveyParams({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.userPrompt,
    required this.creatorId,
    this.templateType,
  });
}

class GenerateSurveyWithAIUseCase {
  final SurveyRepository _repository;

  GenerateSurveyWithAIUseCase(this._repository);

  Future<SurveyEntity> call(GenerateSurveyParams params) {
    return _repository.generateSurveyWithAI(
      projectId: params.projectId,
      projectName: params.projectName,
      projectDescription: params.projectDescription,
      userPrompt: params.userPrompt,
      creatorId: params.creatorId,
      templateType: params.templateType,
    );
  }
}
