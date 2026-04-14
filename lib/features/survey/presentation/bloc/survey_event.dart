import 'package:equatable/equatable.dart';

import '../../domain/entities/survey_entity.dart';
import '../../domain/entities/survey_response_entity.dart';

abstract class SurveyEvent extends Equatable {
  const SurveyEvent();

  @override
  List<Object?> get props => [];
}

class LoadSurveys extends SurveyEvent {
  final String projectId;

  const LoadSurveys({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class WatchSurveys extends SurveyEvent {
  final String projectId;

  const WatchSurveys({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class LoadSurveyDetail extends SurveyEvent {
  final String projectId;
  final String surveyId;

  const LoadSurveyDetail({required this.projectId, required this.surveyId});

  @override
  List<Object?> get props => [projectId, surveyId];
}

class CreateSurvey extends SurveyEvent {
  final SurveyEntity survey;

  const CreateSurvey({required this.survey});

  @override
  List<Object?> get props => [survey];
}

class UpdateSurvey extends SurveyEvent {
  final SurveyEntity survey;

  const UpdateSurvey({required this.survey});

  @override
  List<Object?> get props => [survey];
}

class DeleteSurvey extends SurveyEvent {
  final String projectId;
  final String surveyId;

  const DeleteSurvey({required this.projectId, required this.surveyId});

  @override
  List<Object?> get props => [projectId, surveyId];
}

class LoadSurveyResponses extends SurveyEvent {
  final String projectId;
  final String surveyId;

  const LoadSurveyResponses({required this.projectId, required this.surveyId});

  @override
  List<Object?> get props => [projectId, surveyId];
}

class SubmitSurveyResponse extends SurveyEvent {
  final String projectId;
  final String surveyId;
  final SurveyResponseEntity response;

  const SubmitSurveyResponse({
    required this.projectId,
    required this.surveyId,
    required this.response,
  });

  @override
  List<Object?> get props => [projectId, surveyId, response];
}

class GenerateSurveyWithAI extends SurveyEvent {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final String userPrompt;
  final String creatorId;
  final String? templateType;

  const GenerateSurveyWithAI({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.userPrompt,
    required this.creatorId,
    this.templateType,
  });

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    projectDescription,
    userPrompt,
    creatorId,
    templateType,
  ];
}

class SurveysUpdated extends SurveyEvent {
  final List<SurveyEntity> surveys;

  const SurveysUpdated({required this.surveys});

  @override
  List<Object?> get props => [surveys];
}
