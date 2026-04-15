import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/chat_entities.dart';

abstract class AIChatRemoteDataSource {
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  });

  Stream<String> streamMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  });
}

class AIChatRemoteDataSourceImpl implements AIChatRemoteDataSource {
  final Dio dio;

  AIChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  }) async {
    try {
      final prompt = _buildPrompt(message, chatHistory, context);

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

  @override
  Stream<String> streamMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  }) async* {
    try {
      final response = await sendMessage(
        message: message,
        chatHistory: chatHistory,
        context: context,
      );
      yield response;
    } catch (e) {
      rethrow;
    }
  }

  String _buildPrompt(
    String message,
    List<ChatMessage> chatHistory,
    ChatContext context,
  ) {
    final contextInfo = StringBuffer();
    contextInfo.writeln('PROJECT CONTEXT:');
    contextInfo.writeln('Project: ${context.projectName}');
    contextInfo.writeln('Description: ${context.projectDescription}');
    contextInfo.writeln('Skills: ${context.skills.join(', ')}');

    if (context.taskId != null) {
      contextInfo.writeln('\\nTASK CONTEXT:');
      contextInfo.writeln('Task: ${context.taskName}');
      if (context.taskDescription != null) {
        contextInfo.writeln('Summary: ${context.taskDescription}');
      }
      if (context.taskDetailedDescription != null) {
        contextInfo.writeln('Details: ${context.taskDetailedDescription}');
      }
    }

    final historyText = StringBuffer();
    if (chatHistory.isNotEmpty) {
      historyText.writeln('\\nCONVERSATION HISTORY:');
      for (final msg in chatHistory) {
        final role = msg.role == ChatRole.user ? 'User' : 'Assistant';
        historyText.writeln('$role: ${msg.content}');
      }
    }

    return '''
You are Navix AI, an expert project management assistant helping users with their projects.

$contextInfo
$historyText

USER'S QUESTION: $message

Provide a helpful, concise, and actionable response. Focus on:
1. Answering the user's specific question
2. Providing practical guidance related to the project/task context
3. Suggesting next steps or best practices when relevant
4. Being encouraging and supportive

Keep your response clear and to the point. If the question is about a specific task, reference the task details in your answer.
''';
  }

  String _parseResponse(Map<String, dynamic> responseData) {
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

      return textResponse;
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException(
        message: 'Failed to parse AI response: $e',
        code: 'parse-error',
      );
    }
  }
}
