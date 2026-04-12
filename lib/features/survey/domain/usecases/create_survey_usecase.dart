import '../entities/survey_entity.dart';
import '../repositories/survey_repository.dart';

class CreateSurveyUseCase {
  final SurveyRepository _repository;

  CreateSurveyUseCase(this._repository);

  Future<SurveyEntity> call(SurveyEntity survey) {
    return _repository.createSurvey(survey);
  }
}
