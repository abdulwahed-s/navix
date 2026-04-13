import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/survey_response_entity.dart';

class SurveyResponseModel extends SurveyResponseEntity {
  const SurveyResponseModel({
    required super.id,
    required super.surveyId,
    required super.respondentId,
    required super.respondentName,
    required super.submittedAt,
    required super.answers,
  });

  factory SurveyResponseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SurveyResponseModel.fromMap(data, doc.id);
  }

  factory SurveyResponseModel.fromMap(Map<String, dynamic> map, String id) {
    return SurveyResponseModel(
      id: id,
      surveyId: map['surveyId'] as String? ?? '',
      respondentId: map['respondentId'] as String? ?? '',
      respondentName: map['respondentName'] as String? ?? '',
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answers: Map<String, dynamic>.from(map['answers'] as Map? ?? {}),
    );
  }

  factory SurveyResponseModel.fromEntity(SurveyResponseEntity entity) {
    return SurveyResponseModel(
      id: entity.id,
      surveyId: entity.surveyId,
      respondentId: entity.respondentId,
      respondentName: entity.respondentName,
      submittedAt: entity.submittedAt,
      answers: entity.answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surveyId': surveyId,
      'respondentId': respondentId,
      'respondentName': respondentName,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'answers': answers,
    };
  }
}
