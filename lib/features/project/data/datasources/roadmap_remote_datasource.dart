import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/project_roadmap_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/milestone_model.dart';
import '../models/task_model.dart';

abstract class RoadmapRemoteDataSource {
  Future<ProjectRoadmapEntity> generateRoadmap(GenerateRoadmapParams params);
}

class RoadmapRemoteDataSourceImpl implements RoadmapRemoteDataSource {
  final Dio dio;

  RoadmapRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProjectRoadmapEntity> generateRoadmap(
    GenerateRoadmapParams params,
  ) async {
    try {
      final prompt = _buildPrompt(params);

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
          message: 'Failed to generate roadmap: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parseResponse(response.data, params);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AIException(
          message: 'Rate limit exceeded. Please wait.',
          code: 'rate-limit',
        );
      }
      throw AIException(
        message: 'Network error: ${e.message}',
        code: e.type.name,
      );
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(message: 'Unexpected error: $e', code: 'unknown');
    }
  }

  String _buildPrompt(GenerateRoadmapParams params) {
    final durationDays = params.endDate.difference(params.startDate).inDays;
    final teamContext = params.isTeamProject
        ? 'Team of ${params.teamSize} members'
        : 'Solo developer';

    final roleInstructions = params.isTeamProject && params.teamSize > 1
        ? '''

IMPORTANT - ROLE-BASED TASK ASSIGNMENT:
Since this is a team project, analyze the project requirements and generate appropriate roles based on the skills needed.
Common roles might include:
- UI/UX Designer (for design, mockups, user experience)
- Frontend Developer (for client-side development, UI implementation)
- Backend Developer (for server-side logic, APIs, databases)
- Full Stack Developer (for both frontend and backend)
- DevOps Engineer (for deployment, CI/CD, infrastructure)
- QA Engineer (for testing, quality assurance)
- Mobile Developer (for mobile app development)
- Data Scientist (for data analysis, ML models)

For EACH task, assign it to a specific role using the "requiredRole" field.
Distribute tasks evenly across roles based on the project needs.
Use clear, professional role names.
'''
        : '';

    return '''
You are an expert project manager. Generate a detailed project roadmap.

PROJECT: ${params.projectName}
DESCRIPTION: ${params.projectDescription}
TEAM: $teamContext
SKILLS: ${params.skills.join(', ')}
DURATION: $durationDays days (${params.startDate.toIso8601String()} to ${params.endDate.toIso8601String()})
$roleInstructions
Generate a roadmap with EXACTLY:
- 3-5 milestones evenly distributed across the timeline
- 2-4 tasks per milestone
- Realistic deadlines within the project dates
- Tasks should specify estimated hours (1-16 hours each)

CRITICAL: Every task MUST include BOTH "description" AND "detailedDescription" fields:
- "description": A brief 1-sentence summary of the task
- "detailedDescription": A comprehensive 3-5 sentence explanation including:
  * What specifically needs to be accomplished
  * Key technical considerations and challenges
  * Required skills/technologies for this specific task
  * Step-by-step implementation guidance or suggested approach
  * Dependencies on other tasks (if any)

${params.isTeamProject && params.teamSize > 1 ? 'CRITICAL: Each task MUST have a "requiredRole" field specifying which role should handle it' : ''}

RESPOND ONLY WITH VALID JSON (no markdown, no code blocks, no explanations):
{
  "milestones": [
    {
      "id": "m1",
      "name": "Milestone Name",
      "description": "What this milestone achieves",
      "deadline": "YYYY-MM-DD",
      "order": 0
    }
  ],
  "tasks": [
    {
      "id": "t1",
      "milestoneId": "m1",
      "name": "Task Name",
      "description": "Brief one-sentence task summary",
      "detailedDescription": "Detailed explanation: This task involves [what needs to be done]. Technical considerations include [key challenges]. Required skills are [technologies/skills]. Implementation approach: [step-by-step guidance]. Dependencies: [other tasks if any].",
      "deadline": "YYYY-MM-DD",
      "priority": "low|medium|high|critical",
      "estimatedHours": 8,
      "order": 0${params.isTeamProject && params.teamSize > 1 ? ',\n      "requiredRole": "Role Name (e.g., UI/UX Designer, Backend Developer)"' : ''}
    }
  ]
}
''';
  }

  ProjectRoadmapEntity _parseResponse(
    Map<String, dynamic> responseData,
    GenerateRoadmapParams params,
  ) {
    try {
      String textResponse = responseData['response'] as String? ?? '';
      if (textResponse.isEmpty) {
        throw const AIException(
          message: 'No response from AI',
          code: 'empty-response',
        );
      }

      textResponse = textResponse
          .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
          .trim();

      print('=== RAW AI RESPONSE ===');
      print(textResponse);
      print('=== END RAW RESPONSE ===');

      if (textResponse.contains('```json')) {
        textResponse = textResponse
            .replaceAll('```json', '')
            .replaceAll('```', '');
      }
      if (textResponse.contains('```')) {
        textResponse = textResponse.replaceAll('```', '');
      }
      textResponse = textResponse.trim();

      final Map<String, dynamic> roadmapJson = json.decode(textResponse);

      print('=== PARSED JSON ===');
      print(json.encode(roadmapJson));
      print('=== END PARSED JSON ===');

      final milestonesJson = roadmapJson['milestones'] as List? ?? [];
      final tasksJson = roadmapJson['tasks'] as List? ?? [];

      if (tasksJson.isNotEmpty) {
        print('=== FIRST TASK DATA ===');
        print('Task JSON: ${json.encode(tasksJson[0])}');
        final firstTask = tasksJson[0] as Map<String, dynamic>;
        print(
          'Has detailedDescription: ${firstTask.containsKey('detailedDescription')}',
        );
        print('detailedDescription value: ${firstTask['detailedDescription']}');
        print('=== END FIRST TASK ===');
      }

      final milestones = milestonesJson
          .map((m) => MilestoneModel.fromJson(m as Map<String, dynamic>, ''))
          .toList();

      final tasks = tasksJson
          .map((t) => TaskModel.fromJson(t as Map<String, dynamic>, ''))
          .toList();

      if (tasks.isNotEmpty) {
        print('=== FIRST PARSED TASK MODEL ===');
        print('Task name: ${tasks[0].name}');
        print('Task description: ${tasks[0].description}');
        print('Task detailedDescription: ${tasks[0].detailedDescription}');
        print('=== END PARSED TASK MODEL ===');
      }

      return ProjectRoadmapEntity(
        projectName: params.projectName,
        projectDescription: params.projectDescription,
        milestones: milestones,
        tasks: tasks,
      );
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to parse roadmap: $e',
        code: 'parse-error',
      );
    }
  }
}
