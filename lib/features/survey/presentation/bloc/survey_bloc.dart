import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/survey_entity.dart';
import '../../domain/usecases/create_survey_usecase.dart';
import '../../domain/usecases/delete_survey_usecase.dart';
import '../../domain/usecases/generate_survey_usecase.dart';
import '../../domain/usecases/get_responses_usecase.dart';
import '../../domain/usecases/get_survey_by_id_usecase.dart';
import '../../domain/usecases/get_surveys_usecase.dart';
import '../../domain/usecases/submit_response_usecase.dart';
import '../../domain/usecases/update_survey_usecase.dart';
import '../../domain/usecases/watch_surveys_usecase.dart';
import 'survey_event.dart';
import 'survey_state.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  final GetSurveysUseCase _getSurveysUseCase;
  final GetSurveyByIdUseCase _getSurveyByIdUseCase;
  final CreateSurveyUseCase _createSurveyUseCase;
  final UpdateSurveyUseCase _updateSurveyUseCase;
  final DeleteSurveyUseCase _deleteSurveyUseCase;
  final GetSurveyResponsesUseCase _getResponsesUseCase;
  final SubmitSurveyResponseUseCase _submitResponseUseCase;
  final GenerateSurveyWithAIUseCase _generateSurveyUseCase;
  final WatchSurveysUseCase _watchSurveysUseCase;

  StreamSubscription<List<SurveyEntity>>? _surveysSubscription;

  SurveyBloc({
    required GetSurveysUseCase getSurveysUseCase,
    required GetSurveyByIdUseCase getSurveyByIdUseCase,
    required CreateSurveyUseCase createSurveyUseCase,
    required UpdateSurveyUseCase updateSurveyUseCase,
    required DeleteSurveyUseCase deleteSurveyUseCase,
    required GetSurveyResponsesUseCase getResponsesUseCase,
    required SubmitSurveyResponseUseCase submitResponseUseCase,
    required GenerateSurveyWithAIUseCase generateSurveyUseCase,
    required WatchSurveysUseCase watchSurveysUseCase,
  }) : _getSurveysUseCase = getSurveysUseCase,
       _getSurveyByIdUseCase = getSurveyByIdUseCase,
       _createSurveyUseCase = createSurveyUseCase,
       _updateSurveyUseCase = updateSurveyUseCase,
       _deleteSurveyUseCase = deleteSurveyUseCase,
       _getResponsesUseCase = getResponsesUseCase,
       _submitResponseUseCase = submitResponseUseCase,
       _generateSurveyUseCase = generateSurveyUseCase,
       _watchSurveysUseCase = watchSurveysUseCase,
       super(const SurveyInitial()) {
    on<LoadSurveys>(_onLoadSurveys);
    on<WatchSurveys>(_onWatchSurveys);
    on<SurveysUpdated>(_onSurveysUpdated);
    on<LoadSurveyDetail>(_onLoadSurveyDetail);
    on<CreateSurvey>(_onCreateSurvey);
    on<UpdateSurvey>(_onUpdateSurvey);
    on<DeleteSurvey>(_onDeleteSurvey);
    on<LoadSurveyResponses>(_onLoadResponses);
    on<SubmitSurveyResponse>(_onSubmitResponse);
    on<GenerateSurveyWithAI>(_onGenerateSurvey);
  }

  Future<void> _onLoadSurveys(
    LoadSurveys event,
    Emitter<SurveyState> emit,
  ) async {
    emit(const SurveyLoading());
    try {
      final surveys = await _getSurveysUseCase(event.projectId);
      emit(SurveysLoaded(surveys: surveys, projectId: event.projectId));
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  Future<void> _onWatchSurveys(
    WatchSurveys event,
    Emitter<SurveyState> emit,
  ) async {
    emit(const SurveyLoading());
    await _surveysSubscription?.cancel();
    _surveysSubscription = _watchSurveysUseCase(event.projectId).listen(
      (surveys) => add(SurveysUpdated(surveys: surveys)),
      onError: (error) => add(SurveysUpdated(surveys: const [])),
    );
  }

  void _onSurveysUpdated(SurveysUpdated event, Emitter<SurveyState> emit) {
    final currentState = state;
    final projectId = currentState is SurveysLoaded
        ? currentState.projectId
        : '';
    emit(SurveysLoaded(surveys: event.surveys, projectId: projectId));
  }

  Future<void> _onLoadSurveyDetail(
    LoadSurveyDetail event,
    Emitter<SurveyState> emit,
  ) async {
    emit(const SurveyLoading());
    try {
      final survey = await _getSurveyByIdUseCase(
        projectId: event.projectId,
        surveyId: event.surveyId,
      );
      if (survey == null) {
        emit(const SurveyError(message: 'Survey not found'));
        return;
      }

      final responses = await _getResponsesUseCase(
        projectId: event.projectId,
        surveyId: event.surveyId,
      );

      emit(SurveyDetailLoaded(survey: survey, responses: responses));
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  Future<void> _onCreateSurvey(
    CreateSurvey event,
    Emitter<SurveyState> emit,
  ) async {
    emit(const SurveyCreating());
    try {
      final survey = await _createSurveyUseCase(event.survey);
      emit(SurveyCreated(survey: survey));
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSurvey(
    UpdateSurvey event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      await _updateSurveyUseCase(event.survey);
      emit(SurveyUpdated(survey: event.survey));
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  Future<void> _onDeleteSurvey(
    DeleteSurvey event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      await _deleteSurveyUseCase(
        projectId: event.projectId,
        surveyId: event.surveyId,
      );
      emit(const SurveyDeleted());
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  Future<void> _onLoadResponses(
    LoadSurveyResponses event,
    Emitter<SurveyState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SurveyDetailLoaded) return;

    try {
      final responses = await _getResponsesUseCase(
        projectId: event.projectId,
        surveyId: event.surveyId,
      );
      emit(
        SurveyDetailLoaded(
          survey: currentState.survey,
          responses: responses,
          hasUserResponded: currentState.hasUserResponded,
        ),
      );
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  Future<void> _onSubmitResponse(
    SubmitSurveyResponse event,
    Emitter<SurveyState> emit,
  ) async {
    try {
      await _submitResponseUseCase(
        projectId: event.projectId,
        surveyId: event.surveyId,
        response: event.response,
      );
      emit(const ResponseSubmitted());
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  Future<void> _onGenerateSurvey(
    GenerateSurveyWithAI event,
    Emitter<SurveyState> emit,
  ) async {
    emit(const SurveyGenerating());
    try {
      final generatedSurvey = await _generateSurveyUseCase(
        GenerateSurveyParams(
          projectId: event.projectId,
          projectName: event.projectName,
          projectDescription: event.projectDescription,
          userPrompt: event.userPrompt,
          creatorId: event.creatorId,
          templateType: event.templateType,
        ),
      );

      final savedSurvey = await _createSurveyUseCase(generatedSurvey);
      emit(SurveyCreated(survey: savedSurvey));
    } catch (e) {
      emit(SurveyError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _surveysSubscription?.cancel();
    return super.close();
  }
}
