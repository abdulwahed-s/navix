import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/survey_entity.dart';
import '../../domain/entities/survey_response_entity.dart';
import '../models/survey_model.dart';
import '../models/survey_response_model.dart';

abstract class SurveyRemoteDatasource {
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
}

class SurveyRemoteDatasourceImpl implements SurveyRemoteDatasource {
  final FirebaseFirestore _firestore;

  SurveyRemoteDatasourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _surveysCollection(
    String projectId,
  ) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('surveys');
  }

  CollectionReference<Map<String, dynamic>> _responsesCollection(
    String projectId,
    String surveyId,
  ) {
    return _surveysCollection(projectId).doc(surveyId).collection('responses');
  }

  @override
  Future<List<SurveyEntity>> getSurveys(String projectId) async {
    final snapshot = await _surveysCollection(
      projectId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => SurveyModel.fromDocument(doc, projectId))
        .toList();
  }

  @override
  Future<SurveyEntity?> getSurveyById(String projectId, String surveyId) async {
    final doc = await _surveysCollection(projectId).doc(surveyId).get();

    if (!doc.exists) return null;
    return SurveyModel.fromDocument(doc, projectId);
  }

  @override
  Future<SurveyEntity> createSurvey(SurveyEntity survey) async {
    final model = SurveyModel.fromEntity(survey);
    final docRef = await _surveysCollection(
      survey.projectId,
    ).add(model.toMap());

    return survey.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateSurvey(SurveyEntity survey) async {
    final model = SurveyModel.fromEntity(survey);
    await _surveysCollection(
      survey.projectId,
    ).doc(survey.id).update(model.toMap());
  }

  @override
  Future<void> deleteSurvey(String projectId, String surveyId) async {
    final responses = await _responsesCollection(projectId, surveyId).get();
    for (final doc in responses.docs) {
      await doc.reference.delete();
    }

    await _surveysCollection(projectId).doc(surveyId).delete();
  }

  @override
  Stream<List<SurveyEntity>> watchSurveys(String projectId) {
    return _surveysCollection(projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SurveyModel.fromDocument(doc, projectId))
              .toList(),
        );
  }

  @override
  Future<List<SurveyResponseEntity>> getResponses(
    String projectId,
    String surveyId,
  ) async {
    final snapshot = await _responsesCollection(
      projectId,
      surveyId,
    ).orderBy('submittedAt', descending: true).get();

    return snapshot.docs
        .map((doc) => SurveyResponseModel.fromDocument(doc))
        .toList();
  }

  @override
  Future<void> submitResponse(
    String projectId,
    String surveyId,
    SurveyResponseEntity response,
  ) async {
    final model = SurveyResponseModel.fromEntity(response);

    await _responsesCollection(projectId, surveyId).add(model.toMap());

    await _surveysCollection(
      projectId,
    ).doc(surveyId).update({'responseCount': FieldValue.increment(1)});
  }

  @override
  Future<bool> hasUserResponded(
    String projectId,
    String surveyId,
    String userId,
  ) async {
    final snapshot = await _responsesCollection(
      projectId,
      surveyId,
    ).where('respondentId', isEqualTo: userId).limit(1).get();

    return snapshot.docs.isNotEmpty;
  }
}
