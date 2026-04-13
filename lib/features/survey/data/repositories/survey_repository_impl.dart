import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/survey_entity.dart';
import '../../domain/entities/survey_question_entity.dart';
import '../../domain/entities/survey_response_entity.dart';
import '../../domain/repositories/survey_repository.dart';
import '../datasources/survey_remote_datasource.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  final SurveyRemoteDatasource _remoteDatasource;
  final Dio _dio;

  SurveyRepositoryImpl({
    required SurveyRemoteDatasource remoteDatasource,
    required Dio dio,
  }) : _remoteDatasource = remoteDatasource,
       _dio = dio;

  @override
  Future<List<SurveyEntity>> getSurveys(String projectId) {
    return _remoteDatasource.getSurveys(projectId);
  }

  @override
  Future<SurveyEntity?> getSurveyById(String projectId, String surveyId) {
    return _remoteDatasource.getSurveyById(projectId, surveyId);
  }

  @override
  Future<SurveyEntity> createSurvey(SurveyEntity survey) {
    return _remoteDatasource.createSurvey(survey);
  }

  @override
  Future<void> updateSurvey(SurveyEntity survey) {
    return _remoteDatasource.updateSurvey(survey);
  }

  @override
  Future<void> deleteSurvey(String projectId, String surveyId) {
    return _remoteDatasource.deleteSurvey(projectId, surveyId);
  }

  @override
  Stream<List<SurveyEntity>> watchSurveys(String projectId) {
    return _remoteDatasource.watchSurveys(projectId);
  }

  @override
  Future<List<SurveyResponseEntity>> getResponses(
    String projectId,
    String surveyId,
  ) {
    return _remoteDatasource.getResponses(projectId, surveyId);
  }

  @override
  Future<void> submitResponse(
    String projectId,
    String surveyId,
    SurveyResponseEntity response,
  ) {
    return _remoteDatasource.submitResponse(projectId, surveyId, response);
  }

  @override
  Future<bool> hasUserResponded(
    String projectId,
    String surveyId,
    String userId,
  ) {
    return _remoteDatasource.hasUserResponded(projectId, surveyId, userId);
  }

  @override
  Future<SurveyEntity> generateSurveyWithAI({
    required String projectId,
    required String projectName,
    required String projectDescription,
    required String userPrompt,
    required String creatorId,
    String? templateType,
  }) async {
    final prompt = _buildSurveyPrompt(
      projectName: projectName,
      projectDescription: projectDescription,
      userPrompt: userPrompt,
      templateType: templateType,
    );

    try {
      final response = await _dio.post(
        ApiConstants.ollamaGenerateEndpoint,
        data: {
          'model': 'navix-ai',
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.7, 'top_k': 40, 'top_p': 0.95},
        },
      );

      final survey = _parseSurveyResponse(
        response.data as Map<String, dynamic>,
        projectId: projectId,
        projectName: projectName,
        projectDescription: projectDescription,
        creatorId: creatorId,
      );

      return survey;
    } catch (e) {
      throw Exception('Failed to generate survey with AI: $e');
    }
  }

  String _buildSurveyPrompt({
    required String projectName,
    required String projectDescription,
    required String userPrompt,
    String? templateType,
  }) {
    final templateContext = _getTemplateContext(templateType);

    return '''
You are a survey design expert. Generate a user survey for the following project.

PROJECT NAME: $projectName
PROJECT DESCRIPTION: $projectDescription

USER REQUEST: $userPrompt
$templateContext

Generate a survey with 5-8 questions that will help validate the project idea and gather user feedback.
Include a mix of question types:
- radio: Single choice questions with 2-5 options
- checkbox: Multiple choice questions with 3-6 options
- text: Open-ended text questions
- rating: 1-5 star rating questions

IMPORTANT: Respond ONLY with valid JSON in this exact format:
{
  "title": "Survey title",
  "description": "Brief survey description",
  "questions": [
    {
      "id": "q1",
      "type": "radio",
      "question": "Question text?",
      "options": ["Option 1", "Option 2", "Option 3"],
      "required": true,
      "allowOther": false
    },
    {
      "id": "q2",
      "type": "checkbox",
      "question": "Question text?",
      "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
      "required": true,
      "allowOther": true
    },
    {
      "id": "q3",
      "type": "text",
      "question": "Open-ended question?",
      "options": [],
      "required": false,
      "allowOther": false
    },
    {
      "id": "q4",
      "type": "rating",
      "question": "How would you rate this?",
      "options": [],
      "required": true,
      "allowOther": false
    }
  ]
}

Generate thoughtful, relevant questions that will provide actionable insights.
''';
  }

  String _getTemplateContext(String? templateType) {
    switch (templateType) {
      case 'fyp':
        return '''
TEMPLATE: Final Year Project Survey
Focus on:
- Problem validation (has the user experienced this problem?)
- Current solutions they use
- Pain points with existing solutions
- Interest in proposed features
- Willingness to try new solutions
''';
      case 'feature':
        return '''
TEMPLATE: Feature Feedback Survey
Focus on:
- Feature usage frequency
- Satisfaction with current features
- Desired improvements
- Feature priorities
- Missing functionality
''';
      case 'user_testing':
        return '''
TEMPLATE: User Testing Survey
Focus on:
- Usability rating
- Task completion ease
- UI/UX feedback
- Confusion points
- Overall satisfaction
- Recommendations
''';
      default:
        return '';
    }
  }

  SurveyEntity _parseSurveyResponse(
    Map<String, dynamic> responseData, {
    required String projectId,
    required String projectName,
    required String projectDescription,
    required String creatorId,
  }) {
    try {
      final text = responseData['response'] as String? ?? '';
      if (text.isEmpty) {
        throw Exception('No response from AI');
      }

      final cleanedText = text
          .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
          .trim();

      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanedText);
      if (jsonMatch == null) {
        throw Exception('No JSON found in response');
      }

      final jsonStr = jsonMatch.group(0)!;
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      final questions = (data['questions'] as List<dynamic>)
          .map((q) => _parseQuestion(q as Map<String, dynamic>))
          .toList();

      final now = DateTime.now();

      return SurveyEntity(
        id: '',
        projectId: projectId,
        title: data['title'] as String? ?? 'Survey for $projectName',
        description: data['description'] as String? ?? '',
        projectDescription: projectDescription,
        createdBy: creatorId,
        createdAt: now,
        updatedAt: now,
        status: SurveyStatus.draft,
        responseCount: 0,
        questions: questions,
      );
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }

  SurveyQuestionEntity _parseQuestion(Map<String, dynamic> data) {
    return SurveyQuestionEntity(
      id: data['id'] as String? ?? '',
      type: _parseQuestionType(data['type'] as String?),
      question: data['question'] as String? ?? '',
      options:
          (data['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      required: data['required'] as bool? ?? true,
      allowOther: data['allowOther'] as bool? ?? false,
    );
  }

  SurveyQuestionType _parseQuestionType(String? type) {
    switch (type) {
      case 'radio':
        return SurveyQuestionType.radio;
      case 'checkbox':
        return SurveyQuestionType.checkbox;
      case 'text':
        return SurveyQuestionType.text;
      case 'rating':
        return SurveyQuestionType.rating;
      default:
        return SurveyQuestionType.text;
    }
  }
}
