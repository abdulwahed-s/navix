import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/skill_test_model.dart';

abstract class SkillRemoteDataSource {
  Future<SkillValidationResult> validateCustomSkill(String skillName);

  Future<SkillTestModel> generateSkillTest(List<String> skillNames);

  Future<SkillTestResult> evaluateSkillTest({
    required SkillTestModel test,
    required Map<String, String> answers,
  });
}

class SkillRemoteDataSourceImpl implements SkillRemoteDataSource {
  final Dio dio;

  SkillRemoteDataSourceImpl({required this.dio});

  @override
  Future<SkillValidationResult> validateCustomSkill(String skillName) async {
    try {
      final prompt = _buildValidationPrompt(skillName);

      final response = await dio.post(
        ApiConstants.ollamaGenerateEndpoint,
        data: {
          'model': 'navix-ai',
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.3, 'top_k': 40, 'top_p': 0.95},
        },
      );

      if (response.statusCode != 200) {
        throw AIException(
          message: 'Failed to validate skill: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parseValidationResponse(response.data, skillName);
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
  Future<SkillTestModel> generateSkillTest(List<String> skillNames) async {
    try {
      final prompt = _buildTestGenerationPrompt(skillNames);

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
          message: 'Failed to generate test: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parseTestGenerationResponse(response.data, skillNames);
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
  Future<SkillTestResult> evaluateSkillTest({
    required SkillTestModel test,
    required Map<String, String> answers,
  }) async {
    try {
      final prompt = _buildEvaluationPrompt(test, answers);

      final response = await dio.post(
        ApiConstants.ollamaGenerateEndpoint,
        data: {
          'model': 'navix-ai',
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.3, 'top_k': 40, 'top_p': 0.95},
        },
      );

      if (response.statusCode != 200) {
        throw AIException(
          message: 'Failed to evaluate test: ${response.statusMessage}',
          code: response.statusCode.toString(),
        );
      }

      return _parseEvaluationResponse(response.data);
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

  String _buildValidationPrompt(String skillName) {
    return '''
You are an expert skill validator. Determine if the following term represents a real, testable skill, technology, profession, or domain of knowledge.

SKILL TO VALIDATE: "$skillName"

Requirements for a VALID skill:
1. It must be a real skill, technology, programming language, framework, tool, or professional domain
2. It must be something that can be tested with questions
3. It should not be random characters, nonsense words, or inappropriate content

IMPORTANT: Respond ONLY with valid JSON. No markdown, no explanation.

Response format:
{
  "isValid": true or false,
  "reason": "Brief explanation of why this is valid/invalid"
}

Examples:
- "Kotlin" → VALID (programming language)
- "GraphQL" → VALID (technology/query language)
- "Project Management" → VALID (professional skill)
- "iaoshduhfsa" → INVALID (random characters)
- "asdkj123" → INVALID (meaningless)
''';
  }

  String _buildTestGenerationPrompt(List<String> skillNames) {
    final skillsList = skillNames.join(', ');
    const questionsPerSkill = 6;

    return '''
You are an expert skill assessor. Generate a skill verification test for the following skills.

SKILLS TO TEST: $skillsList

Requirements:
1. Generate EXACTLY $questionsPerSkill questions PER skill (total: ${skillNames.length * questionsPerSkill} questions)
2. Mix of difficulty levels per skill: 2 easy, 2 medium, 2 hard
3. Question types:
   - multipleChoice: 4 options, one correct answer
   - shortAnswer: requires 1-2 sentence answer
   - longAnswer: requires detailed explanation
4. Questions should accurately assess proficiency
5. Make questions practical and relevant

IMPORTANT - MARKDOWN FORMATTING:
- Use markdown in the "question" field for better readability
- Use code blocks with language syntax for code examples: \`\`\`python, \`\`\`kotlin, etc.
- Use **bold** for emphasis
- Use bullet points for lists
- This helps display programming questions beautifully

IMPORTANT: Respond ONLY with valid JSON. No markdown outside the question field.

Response format:
{
  "questions": [
    {
      "id": "q1",
      "skillName": "Kotlin",
      "question": "What is the difference between `val` and `var` in Kotlin?\\n\\n- `val` declares a **read-only** variable\\n- `var` declares a **mutable** variable",
      "questionType": "shortAnswer",
      "options": null,
      "difficulty": "easy"
    },
    {
      "id": "q2",
      "skillName": "Python",
      "question": "What will the following code output?\\n\\n\`\`\`python\\nprint([x*2 for x in range(3)])\\n\`\`\`",
      "questionType": "multipleChoice",
      "options": ["[0, 2, 4]", "[2, 4, 6]", "[1, 2, 3]", "[0, 1, 2]"],
      "difficulty": "medium"
    }
  ]
}
''';
  }

  String _buildEvaluationPrompt(
    SkillTestModel test,
    Map<String, String> answers,
  ) {
    final questionsAndAnswers = <String>[];

    for (final question in test.questions) {
      var answer = answers[question.id] ?? 'No answer provided';

      if (answer == '__SKIPPED__') {
        answer = '[USER SKIPPED - Did not know the answer]';
      }
      questionsAndAnswers.add('''
Question (${question.skillName} - ${question.difficulty}): ${question.question}
${question.isMultipleChoice ? 'Options: ${question.options?.join(", ")}' : ''}
User Answer: $answer
''');
    }

    return '''
You are a STRICT skill evaluator. Evaluate the following test answers and determine if the user actually knows the skill.

${questionsAndAnswers.join('\n---\n')}

STRICT EVALUATION RULES:
1. "[USER SKIPPED]" = user did NOT know the answer = counts as WRONG
2. Random characters, gibberish, or off-topic answers = WRONG
3. Incorrect answers = WRONG
4. Only CORRECT and RELEVANT answers count toward passing

SCORING:
- To PASS a skill, user must answer AT LEAST ONE question correctly for that skill
- If ALL answers for a skill are wrong/skipped/gibberish = FAILED (passed: false)
- Do NOT be lenient - only real knowledge counts

Skill Level Criteria (only if passed):
- beginner: Got 1-2 easy questions right, basic understanding
- intermediate: Got most questions right including some medium ones
- advanced: Got most questions right including hard ones
- expert: Near-perfect with insightful answers

IMPORTANT: Respond ONLY with valid JSON. No markdown, no explanation.

Response format:
{
  "skillLevels": {
    "Kotlin": "intermediate"
  },
  "passedSkills": {
    "Kotlin": true,
    "Flutter": false
  },
  "feedback": "Overall assessment"
}

NOTE: If a skill is NOT passed, you can still include it in skillLevels as "none" or omit it entirely.
''';
  }

  SkillValidationResult _parseValidationResponse(
    Map<String, dynamic> responseData,
    String skillName,
  ) {
    try {
      final textContent = _extractTextContent(responseData);
      final jsonData = _parseJsonFromText(textContent);

      return SkillValidationResult(
        isValid: jsonData['isValid'] as bool? ?? false,
        reason: jsonData['reason'] as String? ?? 'Unable to determine',
        skillName: skillName,
      );
    } catch (e) {
      throw AIException(
        message: 'Failed to parse validation response: $e',
        code: 'parse-error',
      );
    }
  }

  SkillTestModel _parseTestGenerationResponse(
    Map<String, dynamic> responseData,
    List<String> skillNames,
  ) {
    try {
      print(responseData);
      final textContent = _extractTextContent(responseData);
      final jsonData = _parseJsonFromText(textContent);

      final questions = (jsonData['questions'] as List? ?? [])
          .map((q) => SkillTestQuestion.fromJson(q as Map<String, dynamic>))
          .toList();

      return SkillTestModel(
        questions: questions,
        skillsCovered: skillNames,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw AIException(
        message: 'Failed to parse test generation response: $e',
        code: 'parse-error',
      );
    }
  }

  SkillTestResult _parseEvaluationResponse(Map<String, dynamic> responseData) {
    try {
      final textContent = _extractTextContent(responseData);
      final jsonData = _parseJsonFromText(textContent);

      return SkillTestResult.fromJson(jsonData);
    } catch (e) {
      throw AIException(
        message: 'Failed to parse evaluation response: $e',
        code: 'parse-error',
      );
    }
  }

  String _extractTextContent(Map<String, dynamic> responseData) {
    final textResponse = responseData['response'] as String? ?? '';
    if (textResponse.isEmpty) {
      throw const AIException(
        message: 'No response from AI',
        code: 'empty-response',
      );
    }
    return textResponse;
  }

  Map<String, dynamic> _parseJsonFromText(String text) {
    String jsonString = text.trim();

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

    return json.decode(jsonString) as Map<String, dynamic>;
  }

  static String? performLocalValidation(String skillName) {
    final trimmed = skillName.trim();

    if (trimmed.length < 2) {
      return 'Skill name is too short (minimum 2 characters)';
    }
    if (trimmed.length > 50) {
      return 'Skill name is too long (maximum 50 characters)';
    }

    final numbers = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length > trimmed.length * 0.5) {
      return 'Skill name contains too many numbers';
    }

    final specialChars = trimmed.replaceAll(
      RegExp(r'[a-zA-Z0-9\s\-\+\#\.]'),
      '',
    );
    if (specialChars.length > 3) {
      return 'Skill name contains too many special characters';
    }

    final vowelCount = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^aeiou]'), '')
        .length;
    if (trimmed.length > 4 && vowelCount == 0) {
      return 'Skill name appears to be random characters';
    }

    return null;
  }
}
