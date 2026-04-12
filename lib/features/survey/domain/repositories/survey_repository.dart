import '../../domain/entities/survey_entity.dart';
import '../../domain/entities/survey_response_entity.dart';

abstract class SurveyRepository {
  Future<List<SurveyEntity>> getSurveys(String projectId);

  Future<SurveyEntity?> getSurveyById(String projectId, String surveyId);

  Future<SurveyEntity> createSurvey(SurveyEntity survey);

  Future<void> updateSurvey(SurveyEntity survey);

  Future<void> deleteSurvey(String projectId, String surveyId);

  Stream<List<SurveyEntity>> watchSurveys(String projectId);

  Future<List<SurveyResponseEntity>> getResponses(
    String projectId,
    String surveyId,
  );

  Future<void> submitResponse(
    String projectId,
    String surveyId,
    SurveyResponseEntity response,
  );

  Future<bool> hasUserResponded(
    String projectId,
    String surveyId,
    String userId,
  );

  Future<SurveyEntity> generateSurveyWithAI({
    required String projectId,
    required String projectName,
    required String projectDescription,
    required String userPrompt,
    required String creatorId,
    String? templateType,
  });
}
