import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/prd_entity.dart';
import '../../domain/entities/refined_idea_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../models/prd_model.dart';
import '../models/project_idea_model.dart';

abstract class AIRemoteDataSource {
  Future<List<ProjectIdeaModel>> generateProjectIdeas(
    GenerateIdeasParams params,
  );

  Future<RefinedIdeaEntity> refineProjectIdea({
    required String ideaDescription,
    required List<String> userSkills,
    String? additionalContext,
  });

  Future<PrdEntity> generatePrd(GeneratePrdParams params);
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final Dio dio;

  AIRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProjectIdeaModel>> generateProjectIdeas(
    GenerateIdeasParams params,
  ) async {
    try {
      final prompt = _buildPrompt(params);

      final response = await dio.post(
        ApiConstants.ollamaGenerateEndpoint,
        data: {
          'model': 'navix-ai',
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.8, 'top_k': 40, 'top_p': 0.95},
        },
      );

      if (response.statusCode != 200) {
        throw AIException(
          message: 'Failed to generate ideas: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parseResponse(response.data, params.isTeamProject);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AIException(
          message: 'Rate limit exceeded. Please wait a moment.',
          code: 'rate-limit',
        );
      }
      throw AIException(
        message: 'Network error: ${e.message}',
        code: e.type.name,
      );
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'An unexpected error occurred: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<RefinedIdeaEntity> refineProjectIdea({
    required String ideaDescription,
    required List<String> userSkills,
    String? additionalContext,
  }) async {
    try {
      final prompt = _buildRefinePrompt(
        ideaDescription: ideaDescription,
        userSkills: userSkills,
        additionalContext: additionalContext,
      );

      final response = await dio.post(
        ApiConstants.ollamaGenerateEndpoint,
        data: {
          'model': 'navix-ai',
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.7, 'top_k': 40, 'top_p': 0.95},
        },
      );

      if (response.statusCode != 200) {
        throw AIException(
          message: 'Failed to refine idea: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parseRefineResponse(
        response.data,
        ideaDescription: ideaDescription,
        userSkills: userSkills,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AIException(
          message: 'Rate limit exceeded. Please wait a moment.',
          code: 'rate-limit',
        );
      }
      throw AIException(
        message: 'Network error: ${e.message}',
        code: e.type.name,
      );
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'An unexpected error occurred: $e',
        code: 'unknown',
      );
    }
  }

  String _buildRefinePrompt({
    required String ideaDescription,
    required List<String> userSkills,
    String? additionalContext,
  }) {
    final skillsList = userSkills.isNotEmpty
        ? userSkills.join(', ')
        : 'general programming';

    final contextText = additionalContext != null
        ? '\n\nADDITIONAL CONTEXT: $additionalContext'
        : '';

    return '''
You are an expert project advisor. Analyze and refine the following project idea.

USER'S IDEA: $ideaDescription

USER'S SKILLS: $skillsList$contextText

Please provide:
1. An improved, clearer description of the idea
2. Scope clarification (what's in/out of scope)
3. Suggested features (5-8 key features)
4. Feasibility assessment (score 1-10 with explanation)
5. Required skills to build this project

IMPORTANT: Respond ONLY with valid JSON. No markdown, no explanation.

Response format:
{
  "improvedDescription": "A clearer, more detailed description of the project",
  "scopeClarification": "What is in scope and out of scope for this project",
  "suggestedFeatures": ["feature1", "feature2", "feature3", "feature4", "feature5"],
  "feasibilityScore": 7,
  "feasibilityExplanation": "Why this score was given",
  "requiredSkills": ["skill1", "skill2", "skill3"]
}
''';
  }

  RefinedIdeaEntity _parseRefineResponse(
    Map<String, dynamic> responseData, {
    required String ideaDescription,
    required List<String> userSkills,
  }) {
    try {
      final textResponse = responseData['response'] as String? ?? '';
      if (textResponse.isEmpty) {
        throw const AIException(
          message: 'No response from AI',
          code: 'empty-response',
        );
      }

      String jsonString = textResponse.trim();

      jsonString = jsonString
          .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
          .trim();

      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      final Map<String, dynamic> refinedJson = json.decode(jsonString);

      final requiredSkills = List<String>.from(
        refinedJson['requiredSkills'] ?? [],
      );
      final userSkillsLower = userSkills.map((s) => s.toLowerCase()).toSet();

      final matchingSkills = <String>[];
      final missingSkills = <String>[];

      for (final skill in requiredSkills) {
        if (userSkillsLower.contains(skill.toLowerCase())) {
          matchingSkills.add(skill);
        } else {
          missingSkills.add(skill);
        }
      }

      return RefinedIdeaEntity(
        originalIdea: ideaDescription,
        improvedDescription:
            refinedJson['improvedDescription'] as String? ?? '',
        scopeClarification: refinedJson['scopeClarification'] as String? ?? '',
        suggestedFeatures: List<String>.from(
          refinedJson['suggestedFeatures'] ?? [],
        ),
        feasibilityScore: refinedJson['feasibilityScore'] as int? ?? 5,
        feasibilityExplanation:
            refinedJson['feasibilityExplanation'] as String? ?? '',
        requiredSkills: requiredSkills,
        userMatchingSkills: matchingSkills,
        missingSkills: missingSkills,
      );
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to parse AI response: $e',
        code: 'parse-error',
      );
    }
  }

  String _buildPrompt(GenerateIdeasParams params) {
    final teamContext = params.isTeamProject
        ? 'This is for a TEAM project with 2-5 members collaborating.'
        : 'This is for a SOLO project by a single developer.';

    final skillsList = params.userSkills.isNotEmpty
        ? params.userSkills.join(', ')
        : 'general programming';

    return '''
You are an expert project advisor. Generate exactly 3 diverse and creative project ideas based on the following inputs.

USER SKILLS: $skillsList

USER GOALS: ${params.goals}

PREFERENCES: ${params.preferences ?? 'No specific preferences'}

PROJECT TYPE: $teamContext

Generate 3 unique project ideas that:
1. Match the user's skill level
2. Help achieve their stated goals
3. Are feasible and well-scoped
4. Provide learning opportunities

IMPORTANT: Respond ONLY with a valid JSON array. No markdown, no explanation, just the JSON array.

Response format (JSON array only):
[
  {
    "title": "Project Title",
    "description": "Detailed description of the project (2-3 sentences)",
    "skills": ["skill1", "skill2", "skill3"],
    "estimatedDurationWeeks": 4,
    "complexity": "low|medium|high",
    "feasibilityScore": 8
  }
]

Generate exactly 3 ideas with varying complexity levels. feasibilityScore is 1-10.
''';
  }

  List<ProjectIdeaModel> _parseResponse(
    Map<String, dynamic> responseData,
    bool isTeamProject,
  ) {
    try {
      final textResponse = responseData['response'] as String? ?? '';
      if (textResponse.isEmpty) {
        throw const AIException(
          message: 'No response from AI',
          code: 'empty-response',
        );
      }

      String jsonString = textResponse.trim();

      jsonString = jsonString
          .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
          .trim();

      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      final List<dynamic> ideasJson = json.decode(jsonString);

      return ideasJson.map((ideaJson) {
        final model = ProjectIdeaModel.fromJson(
          ideaJson as Map<String, dynamic>,
        );
        return ProjectIdeaModel(
          title: model.title,
          description: model.description,
          skills: model.skills,
          estimatedDurationWeeks: model.estimatedDurationWeeks,
          complexity: model.complexity,
          feasibilityScore: model.feasibilityScore,
          isTeamProject: isTeamProject,
        );
      }).toList();
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to parse AI response: $e',
        code: 'parse-error',
      );
    }
  }

  @override
  Future<PrdEntity> generatePrd(GeneratePrdParams params) async {
    try {
      final prompt = _buildPrdPrompt(params);

      final response = await dio.post(
        ApiConstants.ollamaGenerateEndpoint,
        data: {
          'model': 'navix-ai',
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.7, 'top_k': 40, 'top_p': 0.95},
        },
      );

      if (response.statusCode != 200) {
        throw AIException(
          message: 'Failed to generate PRD: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parsePrdResponse(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AIException(
          message: 'Rate limit exceeded. Please wait a moment.',
          code: 'rate-limit',
        );
      }
      throw AIException(
        message: 'Network error: ${e.message}',
        code: e.type.name,
      );
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'An unexpected error occurred: $e',
        code: 'unknown',
      );
    }
  }

  String _buildPrdPrompt(GeneratePrdParams params) {
    final idea = params.selectedIdea;
    final skillsList = params.userSkills.isNotEmpty
        ? params.userSkills.join(', ')
        : 'general programming';
    final teamContext = params.isTeamProject
        ? 'This is for a TEAM project.'
        : 'This is for a SOLO project.';

    return '''
You are an expert product manager. Generate a comprehensive Product Requirements Document (PRD) for the following project idea.

PROJECT IDEA:
Title: ${idea.title}
Description: ${idea.description}
Complexity: ${idea.complexity.displayName}
Estimated Duration: ${idea.estimatedDurationWeeks} weeks

USER SKILLS: $skillsList
PROJECT TYPE: $teamContext

Generate a detailed PRD with the following structure:

IMPORTANT: Respond ONLY with valid JSON. No markdown, no explanation.

Response format:
{
  "title": "Project title",
  "description": "Detailed project description (2-4 sentences)",
  "problemStatement": "Clear problem statement this project solves",
  "projectObjective": "Main objective and goals of the project",
  "targetUsers": "Description of target users/audience",
  "inScope": ["Item 1 in scope", "Item 2 in scope", "Item 3 in scope"],
  "outOfScope": ["Item 1 out of scope", "Item 2 out of scope"],
  "coreFeatures": ["Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5"],
  "functionalRequirements": ["FR1: description", "FR2: description", "FR3: description"],
  "nonFunctionalRequirements": ["NFR1: performance requirement", "NFR2: security requirement"],
  "detailedRequirementsPerFeature": {
    "Feature 1": ["Requirement 1.1", "Requirement 1.2"],
    "Feature 2": ["Requirement 2.1", "Requirement 2.2"]
  },
  "acceptanceCriteria": ["Criteria 1 for completion", "Criteria 2 for completion"],
  "estimatedDurationWeeks": ${idea.estimatedDurationWeeks},
  "teamSize": ${params.isTeamProject ? 3 : 1}
}

Generate 5-7 core features, 5-8 functional requirements, 3-5 non-functional requirements, and detailed requirements for each feature.
''';
  }

  PrdModel _parsePrdResponse(Map<String, dynamic> responseData) {
    try {
      final textResponse = responseData['response'] as String? ?? '';
      if (textResponse.isEmpty) {
        throw const AIException(
          message: 'No response from AI',
          code: 'empty-response',
        );
      }

      String jsonString = textResponse.trim();

      jsonString = jsonString
          .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
          .trim();

      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      final Map<String, dynamic> prdJson = json.decode(jsonString);
      return PrdModel.fromJson(prdJson);
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to parse PRD response: $e',
        code: 'parse-error',
      );
    }
  }
}
