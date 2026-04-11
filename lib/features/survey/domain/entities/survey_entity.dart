import 'package:equatable/equatable.dart';

import 'survey_question_entity.dart';

enum SurveyStatus { draft, active, closed }

class SurveyEntity extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String projectDescription;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SurveyStatus status;
  final int responseCount;
  final List<SurveyQuestionEntity> questions;

  const SurveyEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.projectDescription,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.status = SurveyStatus.draft,
    this.responseCount = 0,
    this.questions = const [],
  });

  bool get isAcceptingResponses => status == SurveyStatus.active;

  bool get hasResponses => responseCount > 0;

  SurveyEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? projectDescription,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    SurveyStatus? status,
    int? responseCount,
    List<SurveyQuestionEntity>? questions,
  }) {
    return SurveyEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      projectDescription: projectDescription ?? this.projectDescription,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      responseCount: responseCount ?? this.responseCount,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    title,
    description,
    projectDescription,
    createdBy,
    createdAt,
    updatedAt,
    status,
    responseCount,
    questions,
  ];
}
