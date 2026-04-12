import '../repositories/survey_repository.dart';

class DeleteSurveyUseCase {
  final SurveyRepository _repository;

  DeleteSurveyUseCase(this._repository);

  Future<void> call({required String projectId, required String surveyId}) {
    return _repository.deleteSurvey(projectId, surveyId);
  }
}
