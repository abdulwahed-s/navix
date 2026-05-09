import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/team_analysis_entity.dart';
import '../models/team_analysis_model.dart';

class AnalyzeTeamParams {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final List<TaskRoleInfo> tasks;
  final List<TeamMemberSkillInfo> members;
  final List<String> assignedRoles;

  const AnalyzeTeamParams({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.tasks,
    required this.members,
    required this.assignedRoles,
  });
}

class TaskRoleInfo {
  final String taskId;
  final String taskName;
  final String? requiredRole;
  final List<String> dependsOn;

  const TaskRoleInfo({
    required this.taskId,
    required this.taskName,
    this.requiredRole,
    this.dependsOn = const [],
  });
}

class TeamMemberSkillInfo {
  final String memberId;
  final String memberName;
  final String? currentRole;
  final List<SkillInfo> skills;

  const TeamMemberSkillInfo({
    required this.memberId,
    required this.memberName,
    this.currentRole,
    required this.skills,
  });
}

class SkillInfo {
  final String skillName;
  final String level;
  final bool isVerified;

  const SkillInfo({
    required this.skillName,
    required this.level,
    this.isVerified = false,
  });
}

abstract class TeamAnalysisDataSource {
  Future<TeamAnalysisEntity> analyzeTeamRoles(AnalyzeTeamParams params);

  Future<TeamAnalysisEntity?> getCachedAnalysis(String projectId);

  Future<void> saveAnalysis(TeamAnalysisEntity analysis);
}

class TeamAnalysisDataSourceImpl implements TeamAnalysisDataSource {
  final Dio dio;
  final FirebaseFirestore firestore;

  TeamAnalysisDataSourceImpl({required this.dio, required this.firestore});

  @override
  Future<TeamAnalysisEntity> analyzeTeamRoles(AnalyzeTeamParams params) async {
    try {
      final prompt = _buildAnalysisPrompt(params);

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
          message: 'Failed to analyze team: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      final analysis = _parseAnalysisResponse(response.data, params);

      await saveAnalysis(analysis);

      return analysis;
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

  String _buildAnalysisPrompt(AnalyzeTeamParams params) {
    final membersInfo = params.members
        .map((m) {
          final skillsStr = m.skills
              .map(
                (s) =>
                    '${s.skillName} (${s.level}${s.isVerified ? ', verified' : ''})',
              )
              .join(', ');
          return '- ${m.memberName}: Current role: ${m.currentRole ?? 'None'}, Skills: $skillsStr';
        })
        .join('\n');

    final roleTaskCount = <String, int>{};
    final tasksByRole = <String, List<String>>{};
    for (final task in params.tasks) {
      if (task.requiredRole != null && task.requiredRole!.isNotEmpty) {
        roleTaskCount[task.requiredRole!] =
            (roleTaskCount[task.requiredRole!] ?? 0) + 1;
        tasksByRole
            .putIfAbsent(task.requiredRole!, () => [])
            .add(task.taskName);
      }
    }

    final rolesInfo = roleTaskCount.entries
        .map(
          (e) =>
              '- ${e.key}: ${e.value} task(s) - ${tasksByRole[e.key]!.take(3).join(", ")}${tasksByRole[e.key]!.length > 3 ? "..." : ""}',
        )
        .join('\n');

    final dependencyInfo = <String>[];
    for (final task in params.tasks) {
      if (task.dependsOn.isNotEmpty && task.requiredRole != null) {
        final depRoles = <String>{};
        for (final depId in task.dependsOn) {
          final depTask = params.tasks
              .where((t) => t.taskId == depId)
              .firstOrNull;
          if (depTask?.requiredRole != null) {
            depRoles.add(depTask!.requiredRole!);
          }
        }
        if (depRoles.isNotEmpty) {
          dependencyInfo.add(
            '- "${task.taskName}" (${task.requiredRole}) depends on: ${depRoles.join(", ")}',
          );
        }
      }
    }
    final dependencyStr = dependencyInfo.isNotEmpty
        ? dependencyInfo.take(10).join('\n')
        : 'No explicit dependencies';

    final unassignedRoles = roleTaskCount.keys
        .where((role) => !params.assignedRoles.contains(role))
        .toList();
    final unassignedStr = unassignedRoles.isNotEmpty
        ? unassignedRoles
              .map((r) => '$r (${roleTaskCount[r]} tasks)')
              .join(', ')
        : 'None';

    return '''
You are an expert project manager and team analyst. Analyze the following project team and provide role suggestions.

PROJECT: ${params.projectName}
DESCRIPTION: ${params.projectDescription}

ROLES AND TASK COUNTS:
$rolesInfo

TASK DEPENDENCIES (shows which roles depend on output from other roles):
$dependencyStr

CURRENTLY ASSIGNED ROLES: ${params.assignedRoles.join(', ')}

UNASSIGNED ROLES: $unassignedStr

TEAM MEMBERS:
$membersInfo

Based on each member's skills, suggest the BEST role for them from the project's required roles.
For unassigned roles:
- Count the direct tasks for that role
- ALSO count tasks that DEPEND on that role's output (e.g., if UI/UX design is needed before frontend work, count frontend tasks too)
- This gives the true "impact count" of how many tasks are blocked without this role

IMPORTANT: Respond ONLY with valid JSON. No markdown, no explanation.

Response format:
{
  "memberSuggestions": {
    "memberId1": {
      "suggestedRole": "Role Name",
      "reasoning": "Why this role suits them based on their skills",
      "confidence": 0.85
    }
  },
  "missingRoles": [
    {
      "roleName": "Unassigned Role Name",
      "priority": "high|medium|low",
      "taskCount": 5,
      "requiredSkills": [
        {"skillName": "Skill Name", "level": "beginner|intermediate|advanced", "isCritical": true}
      ]
    }
  ],
  "projectRoles": ["Role1", "Role2", "Role3"]
}

For taskCount: Include BOTH direct tasks AND dependent tasks that would be blocked.
For each member, suggest one role from the project roles. Be concise in reasoning (1-2 sentences).
''';
  }

  TeamAnalysisEntity _parseAnalysisResponse(
    Map<String, dynamic> responseData,
    AnalyzeTeamParams params,
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

      final Map<String, dynamic> analysisJson = json.decode(jsonString);

      final suggestionsMap = <String, RoleSuggestion>{};
      final rawSuggestions =
          analysisJson['memberSuggestions'] as Map<String, dynamic>? ?? {};
      for (final entry in rawSuggestions.entries) {
        final data = entry.value as Map<String, dynamic>;
        suggestionsMap[entry.key] = RoleSuggestion(
          suggestedRole: data['suggestedRole'] as String? ?? '',
          reasoning: data['reasoning'] as String? ?? '',
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.8,
        );
      }

      final missingRolesList = <MissingRoleInfo>[];
      final rawMissingRoles =
          analysisJson['missingRoles'] as List<dynamic>? ?? [];
      for (final roleData in rawMissingRoles) {
        final role = roleData as Map<String, dynamic>;
        final skillsList = <SkillRequirement>[];
        final rawSkills = role['requiredSkills'] as List<dynamic>? ?? [];
        for (final skillData in rawSkills) {
          final skill = skillData as Map<String, dynamic>;
          skillsList.add(
            SkillRequirement(
              skillName: skill['skillName'] as String? ?? '',
              level: skill['level'] as String? ?? 'intermediate',
              isCritical: skill['isCritical'] as bool? ?? false,
            ),
          );
        }
        missingRolesList.add(
          MissingRoleInfo(
            roleName: role['roleName'] as String? ?? '',
            requiredSkills: skillsList,
            priority: role['priority'] as String? ?? 'medium',
            taskCount: role['taskCount'] as int? ?? 0,
          ),
        );
      }

      final projectRoles =
          (analysisJson['projectRoles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [];

      return TeamAnalysisEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: params.projectId,
        analyzedAt: DateTime.now(),
        memberSuggestions: suggestionsMap,
        missingRoles: missingRolesList,
        projectRoles: projectRoles,
      );
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to parse AI response: $e',
        code: 'parse-error',
      );
    }
  }

  @override
  Future<TeamAnalysisEntity?> getCachedAnalysis(String projectId) async {
    try {
      final snapshot = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('teamAnalysis')
          .orderBy('analyzedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final analysis = TeamAnalysisModel.fromFirestore(snapshot.docs.first);

      if (analysis.isStale) return null;

      return analysis;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAnalysis(TeamAnalysisEntity analysis) async {
    try {
      final model = TeamAnalysisModel.fromEntity(analysis);
      await firestore
          .collection('projects')
          .doc(analysis.projectId)
          .collection('teamAnalysis')
          .doc(analysis.id)
          .set(model.toJson());
    } catch (e) {}
  }
}
