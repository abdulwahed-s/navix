import '../entities/survey_entity.dart';
import '../repositories/survey_repository.dart';

class GetSurveysUseCase {
  final SurveyRepository _repository;

  GetSurveysUseCase(this._repository);

  Future<List<SurveyEntity>> call(String projectId) {
    return _repository.getSurveys(projectId);
  }
}
