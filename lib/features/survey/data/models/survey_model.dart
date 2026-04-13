import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/survey_entity.dart';
import 'survey_question_model.dart';

class SurveyModel extends SurveyEntity {
  const SurveyModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.projectDescription,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.status,
    super.responseCount,
    super.questions,
  });

  factory SurveyModel.fromDocument(DocumentSnapshot doc, String projectId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SurveyModel.fromMap(data, doc.id, projectId);
  }

  factory SurveyModel.fromMap(
    Map<String, dynamic> map,
    String id,
    String projectId,
  ) {
    return SurveyModel(
      id: id,
      projectId: projectId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      projectDescription: map['projectDescription'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(map['status'] as String?),
      responseCount: map['responseCount'] as int? ?? 0,
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map(
                (q) => SurveyQuestionModel.fromMap(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  factory SurveyModel.fromEntity(SurveyEntity entity) {
    return SurveyModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      projectDescription: entity.projectDescription,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      status: entity.status,
      responseCount: entity.responseCount,
      questions: entity.questions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'projectDescription': projectDescription,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.name,
      'responseCount': responseCount,
      'questions': questions
          .map((q) => SurveyQuestionModel.fromEntity(q).toMap())
          .toList(),
    };
  }

  static SurveyStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return SurveyStatus.active;
      case 'closed':
        return SurveyStatus.closed;
      case 'draft':
      default:
        return SurveyStatus.draft;
    }
  }
}
