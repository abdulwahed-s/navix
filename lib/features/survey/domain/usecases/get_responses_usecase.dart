import '../entities/survey_response_entity.dart';
import '../repositories/survey_repository.dart';

class GetSurveyResponsesUseCase {
  final SurveyRepository _repository;

  GetSurveyResponsesUseCase(this._repository);

  Future<List<SurveyResponseEntity>> call({
    required String projectId,
    required String surveyId,
  }) {
    return _repository.getResponses(projectId, surveyId);
  }
}
