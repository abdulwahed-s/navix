import '../entities/survey_entity.dart';
import '../repositories/survey_repository.dart';

class WatchSurveysUseCase {
  final SurveyRepository _repository;

  WatchSurveysUseCase(this._repository);

  Stream<List<SurveyEntity>> call(String projectId) {
    return _repository.watchSurveys(projectId);
  }
}
