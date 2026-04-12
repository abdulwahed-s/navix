import '../entities/survey_response_entity.dart';
import '../repositories/survey_repository.dart';

class SubmitSurveyResponseUseCase {
  final SurveyRepository _repository;

  SubmitSurveyResponseUseCase(this._repository);

  Future<void> call({
    required String projectId,
    required String surveyId,
    required SurveyResponseEntity response,
  }) {
    return _repository.submitResponse(projectId, surveyId, response);
  }
}
