import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../project/domain/entities/project_roadmap_entity.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../../domain/entities/risk_prediction_entity.dart';

abstract class PredictionRemoteDataSource {
  Future<RiskPredictionEntity> analyzeProject({
    required String projectId,
    required String projectName,
    required ProjectRoadmapEntity roadmap,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class PredictionRemoteDataSourceImpl implements PredictionRemoteDataSource {
  final Dio dio;

  PredictionRemoteDataSourceImpl({required this.dio});

  @override
  Future<RiskPredictionEntity> analyzeProject({
    required String projectId,
    required String projectName,
    required ProjectRoadmapEntity roadmap,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final projectData = _buildProjectDataString(
        projectName: projectName,
        roadmap: roadmap,
        startDate: startDate,
        endDate: endDate,
      );

      final prompt =
          '''
You are a project management AI assistant analyzing project health and predicting risks.

Analyze this project data and provide a risk assessment:

$projectData

Analyze:
1. Task completion status and overdue items
2. Workload distribution 
3. Deadline feasibility
4. Potential blockers
5. Delay probability

Respond ONLY with valid JSON in this exact format:
{
  "riskLevel": "low" | "medium" | "high",
  "delayProbability": <number 0-100>,
  "blockedTasks": ["task name 1", "task name 2"],
  "atRiskTasks": ["task that might be delayed"],
  "affectedMilestones": ["milestone names that might be affected"],
  "recommendations": [
    "Specific actionable recommendation 1",
    "Specific actionable recommendation 2",
    "Specific actionable recommendation 3"
  ]
}
''';

      final response = await dio.post(
        ApiConstants.ollamaGenerateEndpoint,
        data: {
          'model': 'navix-ai',
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.3},
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to analyze project: ${response.statusCode}',
          code: 'prediction-api-error',
        );
      }

      final data = response.data as Map<String, dynamic>;
      final text = data['response'] as String? ?? '';
      if (text.isEmpty) {
        throw const AIException(
          message: 'No analysis generated',
          code: 'empty-analysis',
        );
      }

      final prediction = _parsePredictionResponse(text, projectId);
      return prediction;
    } on DioException catch (e) {
      throw AIException(
        message: e.message ?? 'Failed to analyze project',
        code: 'prediction-network-error',
      );
    }
  }

  String _buildProjectDataString({
    required String projectName,
    required ProjectRoadmapEntity roadmap,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final now = DateTime.now();
    final totalDays = endDate.difference(startDate).inDays;
    final elapsed = now.difference(startDate).inDays;
    final progressPercent = totalDays > 0
        ? (elapsed / totalDays * 100).clamp(0, 100)
        : 0;

    final completedTasks = roadmap.tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final totalTasks = roadmap.tasks.length;
    final taskCompletionPercent = totalTasks > 0
        ? (completedTasks / totalTasks * 100)
        : 0;

    final overdueTasks = roadmap.tasks.where((t) {
      return t.deadline != null &&
          t.deadline!.isBefore(now) &&
          t.status != TaskStatus.completed;
    }).toList();

    final buffer = StringBuffer();
    buffer.writeln('PROJECT: $projectName');
    buffer.writeln(
      'Timeline: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
    );
    buffer.writeln(
      'Progress: ${progressPercent.toStringAsFixed(1)}% time elapsed',
    );
    buffer.writeln(
      'Task Completion: $completedTasks/$totalTasks (${taskCompletionPercent.toStringAsFixed(1)}%)',
    );
    buffer.writeln();

    buffer.writeln('MILESTONES (${roadmap.milestones.length}):');
    for (final m in roadmap.milestones) {
      final status = m.completed
          ? '✓'
          : (m.deadline.isBefore(now) ? 'OVERDUE' : 'pending');
      buffer.writeln(
        '- ${m.name} | Deadline: ${m.deadline.toIso8601String()} | Status: $status',
      );
    }
    buffer.writeln();

    buffer.writeln('TASKS (${roadmap.tasks.length}):');
    for (final t in roadmap.tasks) {
      final deadline = t.deadline?.toIso8601String() ?? 'No deadline';
      buffer.writeln(
        '- ${t.name} | Priority: ${t.priority.name} | Status: ${t.status.name} | Deadline: $deadline',
      );
    }
    buffer.writeln();

    if (overdueTasks.isNotEmpty) {
      buffer.writeln('OVERDUE TASKS (${overdueTasks.length}):');
      for (final t in overdueTasks) {
        buffer.writeln(
          '- ${t.name} (was due: ${t.deadline?.toIso8601String()})',
        );
      }
    }

    return buffer.toString();
  }

  RiskPredictionEntity _parsePredictionResponse(String text, String projectId) {
    try {
      String jsonStr = text;

      jsonStr = jsonStr
          .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
          .trim();

      if (jsonStr.contains('```json')) {
        jsonStr = jsonStr.split('```json')[1].split('```')[0].trim();
      } else if (jsonStr.contains('```')) {
        jsonStr = jsonStr.split('```')[1].split('```')[0].trim();
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return RiskPredictionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        riskLevel: _parseRiskLevel(json['riskLevel'] as String?),
        delayProbability: (json['delayProbability'] as num?)?.toInt() ?? 0,
        blockedTasks: _parseStringList(json['blockedTasks']),
        atRiskTasks: _parseStringList(json['atRiskTasks']),
        affectedMilestones: _parseStringList(json['affectedMilestones']),
        recommendations: _parseStringList(json['recommendations']),
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      return RiskPredictionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: projectId,
        riskLevel: RiskLevel.medium,
        delayProbability: 50,
        recommendations: [
          'Unable to fully analyze project data. Please review task statuses.',
        ],
        analyzedAt: DateTime.now(),
      );
    }
  }

  RiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.medium;
    }
  }

  List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}
