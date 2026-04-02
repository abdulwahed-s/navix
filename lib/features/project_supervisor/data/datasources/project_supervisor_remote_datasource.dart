import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ai_action.dart';
import '../../domain/entities/project_supervisor_context.dart';
import '../../domain/entities/supervisor_message.dart';

/// Abstract class for project supervisor data source.
abstract class ProjectSupervisorRemoteDataSource {
  /// Sends a message to Gemini AI and gets a supervisor response.
  Future<SupervisorMessage> sendMessage({
    required String message,
    required List<SupervisorMessage> history,
    required ProjectSupervisorContext context,
  });
}

/// Implementation of ProjectSupervisorRemoteDataSource using Gemini API.
class ProjectSupervisorRemoteDataSourceImpl
    implements ProjectSupervisorRemoteDataSource {
  final Dio dio;

  ProjectSupervisorRemoteDataSourceImpl({required this.dio});

  @override
  Future<SupervisorMessage> sendMessage({
    required String message,
    required List<SupervisorMessage> history,
    required ProjectSupervisorContext context,
  }) async {
    try {
      final prompt = _buildSupervisorPrompt(message, history, context);

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
          message: 'Failed to get AI response: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parseResponse(response.data);
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

  String _buildSupervisorPrompt(
    String message,
    List<SupervisorMessage> history,
    ProjectSupervisorContext context,
  ) {
    final project = context.project;
    final formattedDate = _formatDate(context.currentDate);

    // Build milestone summary with IDs
    final milestonesSummary = StringBuffer();
    for (final milestone in context.milestones) {
      final status = milestone.completed ? '✓ COMPLETED' : 'PENDING';
      final deadlineStr = _formatDate(milestone.deadline);
      final tasksInMilestone = context.tasks
          .where((t) => t.milestoneId == milestone.id)
          .toList();
      final completedInMilestone = tasksInMilestone
          .where((t) => t.status.name == 'completed')
          .length;
      milestonesSummary.writeln(
        '  - ID: "${milestone.id}" | ${milestone.name} [$status] (Deadline: $deadlineStr, Tasks: $completedInMilestone/${tasksInMilestone.length} completed)',
      );
    }

    // Build tasks summary grouped by status with IDs
    final tasksSummary = StringBuffer();
    final tasksByStatus = <String, List<dynamic>>{};
    for (final task in context.tasks) {
      tasksByStatus.putIfAbsent(task.status.displayName, () => []).add(task);
    }
    for (final entry in tasksByStatus.entries) {
      tasksSummary.writeln('  ${entry.key}: ${entry.value.length} tasks');
      for (final task in entry.value.take(5)) {
        final deadlineStr = task.deadline != null
            ? _formatDate(task.deadline!)
            : 'No deadline';
        final assignee = task.assignedTo != null
            ? context.memberNames[task.assignedTo] ?? 'Unknown'
            : 'Unassigned';
        final overdue = task.isOverdue ? ' [OVERDUE]' : '';
        tasksSummary.writeln(
          '    • ID: "${task.id}" | ${task.name} ($deadlineStr, $assignee)$overdue',
        );
      }
      if (entry.value.length > 5) {
        tasksSummary.writeln('    ... and ${entry.value.length - 5} more');
      }
    }

    // Build team summary
    final teamSummary = StringBuffer();
    for (final role in context.roles) {
      final assignee = role.assignedUserId != null
          ? context.memberNames[role.assignedUserId] ?? 'Unknown'
          : 'Unassigned';
      teamSummary.writeln(
        '  - ${role.roleName}: $assignee (${role.taskCount} tasks)',
      );
    }

    // Build conversation history
    final historyText = StringBuffer();
    if (history.isNotEmpty) {
      historyText.writeln('CONVERSATION HISTORY:');
      // Get last 10 messages
      final recentHistory = history.length > 10
          ? history.sublist(history.length - 10)
          : history;
      for (final msg in recentHistory) {
        final role = msg.role == SupervisorRole.user ? 'User' : 'Navix AI';
        historyText.writeln('$role: ${msg.content}');
        if (msg.executedAction != null) {
          historyText.writeln(
            '[Action Executed: ${msg.executedAction!.title}]',
          );
        }
      }
      historyText.writeln('');
    }

    return '''
You are Navix AI, an expert project supervisor and management consultant. You have complete awareness of the project and act as a smart advisor who can suggest and execute concrete actions.

TODAY'S DATE: $formattedDate

=== PROJECT OVERVIEW ===
Name: ${project.name}
Description: ${project.description}
Status: ${project.status.displayName}
Timeline: ${_formatDate(project.startDate)} → ${_formatDate(project.endDate)}
Days Until Deadline: ${context.daysUntilDeadline} days ${context.isProjectOverdue ? '[PROJECT IS OVERDUE!]' : ''}
Completion: ${context.completionPercentage.toStringAsFixed(1)}% (${context.completedTasksCount}/${context.totalTasksCount} tasks)

=== MILESTONE STATUS ===
${milestonesSummary.toString().trim()}

=== TASK BREAKDOWN ===
Total Tasks: ${context.totalTasksCount}
Completed: ${context.completedTasksCount}
Overdue: ${context.overdueTasksCount}
Blocked: ${context.blockedTasksCount}
Unassigned: ${context.unassignedTasks.length}

$tasksSummary

=== TEAM & ROLES ===
Team Size: ${context.memberNames.length} members
${teamSummary.toString().trim()}

${_buildPrdSection(context)}

$historyText
USER'S MESSAGE: $message

=== YOUR ROLE AS PROJECT SUPERVISOR ===

You are a STRATEGIC PROJECT SUPERVISOR, not just a task executor. When users mention changes, you must:
1. THINK HOLISTICALLY about the ripple effects across the entire project
2. SUGGEST COMPREHENSIVE ACTION PLANS with multiple coordinated actions
3. Consider dependencies between milestones and tasks
4. Maintain logical timeline consistency across all deadlines

=== STRATEGIC THINKING GUIDELINES ===

**When deadline changes occur:**
- Calculate the time difference (extension or compression)
- Proportionally adjust ALL milestone deadlines to maintain relative spacing
- Suggest adjusting task deadlines within each milestone
- Identify if blocked/overdue tasks can now be rescued
- Consider if additional tasks can be added with extra time

**When adding new features:**
- Create a dedicated milestone for the feature
- Generate 3-7 detailed tasks with implementation guidance
- Consider role requirements and team capacity
- Position the milestone appropriately in the timeline
- Suggest task assignments based on roles

**When team issues arise (member unavailable, etc.):**
- Identify all tasks assigned to affected member
- Suggest reassignments based on role compatibility
- Flag tasks that may become blocked
- Recommend priority adjustments for at-risk tasks
- Consider timeline impacts

**When project is behind schedule:**
- Identify critical path tasks
- Suggest scope simplification options
- Recommend priority escalations for blocking tasks
- Consider MVP approach for remaining features
- Propose deadline extensions if scope reduction isn't viable

=== RESPONSE FORMAT ===

Your response MUST be in this exact JSON format:
{
  "message": "Your strategic analysis and recommendations. Be specific, reference actual project data, explain your reasoning for each suggested action.",
  "actions": [
    {
      "type": "actionType",
      "title": "Short action title for button",
      "description": "What this action will do and why it's needed",
      "payload": { ... }
    },
    // Include MULTIPLE actions when appropriate - comprehensive plans are expected!
  ]
}

=== AVAILABLE ACTION TYPES ===

1. "changeProjectDeadline": payload = {"newDeadline": "YYYY-MM-DD"}
2. "changeMilestoneDeadline": payload = {"milestoneId": "actual_firestore_id", "milestoneName": "name", "newDeadline": "YYYY-MM-DD"}
3. "changeTaskDeadline": payload = {"taskId": "actual_firestore_id", "taskName": "name", "newDeadline": "YYYY-MM-DD"}
4. "addFeature": payload = {"featureName": "name", "description": "desc", "milestone": {"name": "milestone name", "description": "desc", "deadline": "YYYY-MM-DD"}, "tasks": [{"name": "task", "description": "brief desc", "detailedDescription": "detailed implementation guidance with technical specifics", "priority": "medium", "estimatedHours": 8, "requiredRole": "role name"}]}
5. "addMilestone": payload = {"name": "name", "description": "desc", "deadline": "YYYY-MM-DD"}
6. "addTasks": payload = {"milestoneId": "actual_firestore_id", "milestoneName": "name", "tasks": [...]}
7. "adjustTaskPriority": payload = {"taskId": "actual_firestore_id", "taskName": "name", "newPriority": "critical|high|medium|low"}
8. "simplifyScope": payload = {"recommendation": "detailed recommendation", "reason": "why this simplification helps"}
9. "noAction": payload = {} (only when giving pure advice with no actionable changes)

=== EXAMPLE: COMPREHENSIVE DEADLINE EXTENSION ===

If user says "The deadline has been extended by one month":

{
  "message": "Great news! With a one-month extension, I've analyzed your project and prepared a comprehensive replan. Currently at ${context.completionPercentage.toStringAsFixed(0)}% completion with ${context.overdueTasksCount} overdue tasks, this extension gives us breathing room. I'm adjusting the project deadline and proportionally redistributing all milestone deadlines to maintain your project's logical flow. This will also give each phase more time for quality work.",
  "actions": [
    {
      "type": "changeProjectDeadline",
      "title": "Extend project to [new date]",
      "description": "Move project deadline from current date to one month later",
      "payload": {"newDeadline": "YYYY-MM-DD"}
    },
    {
      "type": "changeMilestoneDeadline",
      "title": "Adjust [Milestone 1] deadline",
      "description": "Proportionally extend this milestone's deadline",
      "payload": {"milestoneId": "actual_id_1", "milestoneName": "Milestone 1", "newDeadline": "YYYY-MM-DD"}
    },
    {
      "type": "changeMilestoneDeadline",
      "title": "Adjust [Milestone 2] deadline",
      "description": "Proportionally extend this milestone's deadline",
      "payload": {"milestoneId": "actual_id_2", "milestoneName": "Milestone 2", "newDeadline": "YYYY-MM-DD"}
    },
    // ... include ALL milestones that need adjustment
  ]
}

=== EXAMPLE: ADDING A NEW FEATURE ===

If user says "I want to add user authentication":

{
  "message": "I'll add a comprehensive User Authentication feature. This will include login/registration, session management, and secure token handling. Based on your team roles, I'm assigning tasks to the appropriate developers. The feature will be added as a new milestone positioned before your final testing phase.",
  "actions": [
    {
      "type": "addFeature",
      "title": "Add User Authentication Feature",
      "description": "Creates milestone with 5 implementation tasks for complete auth system",
      "payload": {
        "featureName": "User Authentication",
        "description": "Complete user authentication system with login, registration, and session management",
        "milestone": {
          "name": "User Authentication",
          "description": "Implement secure user authentication for the application",
          "deadline": "YYYY-MM-DD"
        },
        "tasks": [
          {
            "name": "Design Authentication Flow",
            "description": "Create UX flow for login and registration",
            "detailedDescription": "Design the complete user authentication flow including: 1) Login screen with email/password fields, 2) Registration form with validation, 3) Password reset flow, 4) Session persistence strategy. Create wireframes and user journey diagrams.",
            "priority": "high",
            "estimatedHours": 6,
            "requiredRole": "UI/UX Designer"
          },
          {
            "name": "Implement Authentication Backend",
            "description": "Set up Firebase Auth or backend auth service",
            "detailedDescription": "Implement server-side authentication: 1) Configure Firebase Auth or custom JWT auth, 2) Set up user registration endpoint, 3) Implement login with email/password, 4) Add token refresh mechanism, 5) Secure API endpoints with auth middleware.",
            "priority": "critical",
            "estimatedHours": 12,
            "requiredRole": "Backend Developer"
          },
          // ... more detailed tasks
        ]
      }
    }
  ]
}

=== CRITICAL RULES ===

1. ALWAYS suggest MULTIPLE actions when changes affect multiple parts of the project
2. Use ACTUAL Firestore IDs from the project data (shown with "ID:" prefix) - NEVER use placeholder numbers
3. Calculate new dates properly based on current project timeline and proportional distribution
4. For deadline extensions: adjust ALL milestones, not just one
5. For new features: create comprehensive task lists with 3-7 detailed tasks
6. Provide strategic reasoning in your message explaining WHY you're suggesting each action
7. When project is behind: suggest both scope reduction AND priority adjustments
8. Always consider the full impact of changes across the entire project structure
''';
  }

  String _buildPrdSection(ProjectSupervisorContext context) {
    final prd = context.prd;
    if (prd == null) return '';

    return '''
=== PROJECT REQUIREMENTS DOCUMENT (PRD) ===
This project was created with a PRD. Use this information for context and to reference when discussing project scope or requirements.

**Problem Statement:** ${prd.problemStatement}

**Project Objective:** ${prd.projectObjective}

**Target Users:** ${prd.targetUsers}

**In Scope:**
${prd.inScope.map((s) => '- $s').join('\n')}

**Out of Scope:**
${prd.outOfScope.map((s) => '- $s').join('\n')}

**Core Features:**
${prd.coreFeatures.map((f) => '- $f').join('\n')}

**Functional Requirements:**
${prd.functionalRequirements.take(5).map((r) => '- $r').join('\n')}
${prd.functionalRequirements.length > 5 ? '... and ${prd.functionalRequirements.length - 5} more' : ''}

**Non-Functional Requirements:**
${prd.nonFunctionalRequirements.take(3).map((r) => '- $r').join('\n')}
${prd.nonFunctionalRequirements.length > 3 ? '... and ${prd.nonFunctionalRequirements.length - 3} more' : ''}

When discussing scope changes or feature requests, reference this PRD to maintain project alignment.
''';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  SupervisorMessage _parseResponse(Map<String, dynamic> responseData) {
    try {
      final textResponse = responseData['response'] as String? ?? '';
      if (textResponse.isEmpty) {
        throw const AIException(
          message: 'No response from AI',
          code: 'empty-response',
        );
      }

      // Try to parse as JSON
      try {
        // Clean up the response - remove markdown code blocks if present
        String cleanedResponse = textResponse.trim();

        // Remove <think> tags
        cleanedResponse = cleanedResponse
            .replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '')
            .trim();

        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse.substring(7);
        }
        if (cleanedResponse.startsWith('```')) {
          cleanedResponse = cleanedResponse.substring(3);
        }
        if (cleanedResponse.endsWith('```')) {
          cleanedResponse = cleanedResponse.substring(
            0,
            cleanedResponse.length - 3,
          );
        }
        cleanedResponse = cleanedResponse.trim();

        final jsonResponse =
            json.decode(cleanedResponse) as Map<String, dynamic>;
        final messageContent =
            jsonResponse['message'] as String? ?? textResponse;
        final actionsJson = jsonResponse['actions'] as List? ?? [];

        final actions = actionsJson
            .map((a) => AIAction.fromJson(a as Map<String, dynamic>))
            .toList();

        // Filter out noAction types
        final meaningfulActions = actions
            .where((a) => a.type != AIActionType.noAction)
            .toList();

        return SupervisorMessage.assistant(
          content: messageContent,
          suggestedActions: meaningfulActions.isNotEmpty
              ? meaningfulActions
              : null,
        );
      } catch (jsonError) {
        // If not valid JSON, return as plain text message
        return SupervisorMessage.assistant(content: textResponse.trim());
      }
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to parse AI response: $e',
        code: 'parse-error',
      );
    }
  }
}
