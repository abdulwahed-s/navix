import '../entities/survey_entity.dart';
import '../repositories/survey_repository.dart';

class UpdateSurveyUseCase {
  final SurveyRepository _repository;

  UpdateSurveyUseCase(this._repository);

  Future<void> call(SurveyEntity survey) {
    return _repository.updateSurvey(survey);
  }
}
