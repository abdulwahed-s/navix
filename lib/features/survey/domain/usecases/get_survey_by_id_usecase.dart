import '../entities/survey_entity.dart';
import '../repositories/survey_repository.dart';

class GetSurveyByIdUseCase {
  final SurveyRepository _repository;

  GetSurveyByIdUseCase(this._repository);

  Future<SurveyEntity?> call({
    required String projectId,
    required String surveyId,
  }) {
    return _repository.getSurveyById(projectId, surveyId);
  }
}
