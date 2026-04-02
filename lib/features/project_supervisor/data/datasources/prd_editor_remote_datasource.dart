import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../ai/domain/entities/prd_entity.dart';
import '../../domain/entities/prd_editor_context.dart';
import '../../domain/entities/prd_editor_message.dart';

/// Abstract class for PRD editor data source.
abstract class PrdEditorRemoteDataSource {
  /// Sends a message to AI and gets a response with optional PRD updates.
  Future<PrdEditorMessage> sendMessage({
    required String message,
    required List<PrdEditorMessage> history,
    required PrdEditorContext context,
  });
}

/// Implementation using Gemini API.
class PrdEditorRemoteDataSourceImpl implements PrdEditorRemoteDataSource {
  final Dio dio;

  PrdEditorRemoteDataSourceImpl({required this.dio});

  @override
  Future<PrdEditorMessage> sendMessage({
    required String message,
    required List<PrdEditorMessage> history,
    required PrdEditorContext context,
  }) async {
    try {
      final prompt = _buildPrompt(message, history, context);

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

      return _parseResponse(response.data, context.prd);
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

  String _buildPrompt(
    String message,
    List<PrdEditorMessage> history,
    PrdEditorContext context,
  ) {
    final prd = context.prd;

    // Build conversation history
    final historyText = StringBuffer();
    if (history.isNotEmpty) {
      historyText.writeln('CONVERSATION HISTORY:');
      final recentHistory = history.length > 10
          ? history.sublist(history.length - 10)
          : history;
      for (final msg in recentHistory) {
        final role = msg.role == PrdEditorRole.user ? 'User' : 'Navix AI';
        historyText.writeln('$role: ${msg.content}');
      }
      historyText.writeln('');
    }

    return '''
You are Navix AI, a helpful project planning assistant. The user is creating a new project and you're helping them refine their Product Requirements Document (PRD).

=== CURRENT PRD ===

**Title:** ${prd.title}

**Description:** ${prd.description}

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
${prd.functionalRequirements.map((r) => '- $r').join('\n')}

**Non-Functional Requirements:**
${prd.nonFunctionalRequirements.map((r) => '- $r').join('\n')}

**Acceptance Criteria:**
${prd.acceptanceCriteria.map((c) => '- $c').join('\n')}

=== PROJECT CONTEXT ===
- Team Size: ${context.teamSize} ${context.isTeamProject ? '(Team Project)' : '(Solo Project)'}
- Duration: ${context.durationWeeks} weeks
- User Skills: ${context.userSkills.join(', ')}

$historyText
USER'S MESSAGE: $message

=== YOUR ROLE ===

You are a helpful assistant that can:
1. **Answer questions** about the PRD, explain requirements, clarify scope, etc.
2. **Suggest edits** when the user asks to change something (e.g., "make scope smaller", "focus on mobile only")

=== RESPONSE FORMAT ===

Your response MUST be valid JSON in this exact format:

{
  "message": "Your conversational response to the user. Be helpful, explain your suggestions.",
  "updatedPrd": null | {
    "title": "only include if changed",
    "description": "only include if changed",
    "problemStatement": "only include if changed",
    "projectObjective": "only include if changed",
    "targetUsers": "only include if changed",
    "inScope": ["only include if changed"],
    "outOfScope": ["only include if changed"],
    "coreFeatures": ["only include if changed"],
    "functionalRequirements": ["only include if changed"],
    "nonFunctionalRequirements": ["only include if changed"],
    "acceptanceCriteria": ["only include if changed"]
  }
}

=== GUIDELINES ===

1. For **questions/discussion**: Set updatedPrd to null. Just provide a helpful message.
2. For **edit requests**: Include ONLY the fields that need to change in updatedPrd.
3. When reducing scope: Move items from inScope/coreFeatures to outOfScope.
4. When adding features: Add to coreFeatures and corresponding requirements.
5. Be conversational and explain WHY you're suggesting changes.
6. Keep the user's original vision but help them refine it.

=== EXAMPLES ===

**User asks a question:**
{
  "message": "The functional requirements define what the system must DO. For example, 'Users can search recipes by ingredient' describes a specific capability. Non-functional requirements describe HOW it should work, like 'The app should load in under 3 seconds'. Would you like me to explain any specific requirement?",
  "updatedPrd": null
}

**User asks to reduce scope:**
{
  "message": "I'll help simplify the scope to focus on the core MVP. I'm moving the social features and advanced analytics to 'Out of Scope' so you can focus on the essential recipe search and save functionality first. You can always add these features in a later phase!",
  "updatedPrd": {
    "inScope": ["Recipe search", "User profiles", "Save favorites"],
    "outOfScope": ["Social sharing", "Advanced analytics", "Meal planning", "Payment processing"],
    "coreFeatures": ["Recipe search", "User profiles", "Save favorites"]
  }
}
''';
  }

  PrdEditorMessage _parseResponse(
    Map<String, dynamic> responseData,
    PrdEntity currentPrd,
  ) {
    try {
      final textResponse = responseData['response'] as String? ?? '';
      if (textResponse.isEmpty) {
        throw const AIException(
          message: 'No response from AI',
          code: 'empty-response',
        );
      }

      // Parse JSON response
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

      try {
        final jsonResponse =
            json.decode(cleanedResponse) as Map<String, dynamic>;
        final messageContent =
            jsonResponse['message'] as String? ?? textResponse;
        final updatedPrd = jsonResponse['updatedPrd'] as Map<String, dynamic>?;

        return PrdEditorMessage.assistant(
          content: messageContent,
          suggestedUpdates: updatedPrd,
        );
      } catch (jsonError) {
        // If not valid JSON, return as plain text
        return PrdEditorMessage.assistant(content: textResponse.trim());
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
