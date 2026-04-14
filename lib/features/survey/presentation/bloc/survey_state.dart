import 'package:equatable/equatable.dart';

import '../../domain/entities/survey_entity.dart';
import '../../domain/entities/survey_response_entity.dart';

abstract class SurveyState extends Equatable {
  const SurveyState();

  @override
  List<Object?> get props => [];
}

class SurveyInitial extends SurveyState {
  const SurveyInitial();
}

class SurveyLoading extends SurveyState {
  const SurveyLoading();
}

class SurveysLoaded extends SurveyState {
  final List<SurveyEntity> surveys;
  final String projectId;

  const SurveysLoaded({required this.surveys, required this.projectId});

  @override
  List<Object?> get props => [surveys, projectId];
}

class SurveyDetailLoaded extends SurveyState {
  final SurveyEntity survey;
  final List<SurveyResponseEntity> responses;
  final bool hasUserResponded;

  const SurveyDetailLoaded({
    required this.survey,
    this.responses = const [],
    this.hasUserResponded = false,
  });

  @override
  List<Object?> get props => [survey, responses, hasUserResponded];
}

class SurveyCreating extends SurveyState {
  const SurveyCreating();
}

class SurveyCreated extends SurveyState {
  final SurveyEntity survey;

  const SurveyCreated({required this.survey});

  @override
  List<Object?> get props => [survey];
}

class SurveyGenerating extends SurveyState {
  const SurveyGenerating();
}

class SurveyGenerated extends SurveyState {
  final SurveyEntity survey;

  const SurveyGenerated({required this.survey});

  @override
  List<Object?> get props => [survey];
}

class SurveyUpdated extends SurveyState {
  final SurveyEntity survey;

  const SurveyUpdated({required this.survey});

  @override
  List<Object?> get props => [survey];
}

class SurveyDeleted extends SurveyState {
  const SurveyDeleted();
}

class ResponseSubmitted extends SurveyState {
  const ResponseSubmitted();
}

class SurveyError extends SurveyState {
  final String message;

  const SurveyError({required this.message});

  @override
  List<Object?> get props => [message];
}
