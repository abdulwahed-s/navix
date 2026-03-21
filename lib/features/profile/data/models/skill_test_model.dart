import 'package:equatable/equatable.dart';

class SkillTestQuestion extends Equatable {
  final String id;

  final String skillName;

  final String question;

  final String questionType;

  final List<String>? options;

  final String difficulty;

  const SkillTestQuestion({
    required this.id,
    required this.skillName,
    required this.question,
    required this.questionType,
    this.options,
    required this.difficulty,
  });

  factory SkillTestQuestion.fromJson(Map<String, dynamic> json) {
    return SkillTestQuestion(
      id: json['id'] as String? ?? '',
      skillName: json['skillName'] as String? ?? '',
      question: json['question'] as String? ?? '',
      questionType: json['questionType'] as String? ?? 'shortAnswer',
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
      difficulty: json['difficulty'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillName': skillName,
      'question': question,
      'questionType': questionType,
      'options': options,
      'difficulty': difficulty,
    };
  }

  bool get isMultipleChoice => questionType == 'multipleChoice';
  bool get isShortAnswer => questionType == 'shortAnswer';
  bool get isLongAnswer => questionType == 'longAnswer';

  @override
  List<Object?> get props => [
    id,
    skillName,
    question,
    questionType,
    options,
    difficulty,
  ];
}

class SkillTestModel extends Equatable {
  final List<SkillTestQuestion> questions;

  final List<String> skillsCovered;

  final DateTime generatedAt;

  const SkillTestModel({
    required this.questions,
    required this.skillsCovered,
    required this.generatedAt,
  });

  factory SkillTestModel.fromJson(Map<String, dynamic> json) {
    return SkillTestModel(
      questions: (json['questions'] as List? ?? [])
          .map((q) => SkillTestQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      skillsCovered: List<String>.from(json['skillsCovered'] as List? ?? []),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'skillsCovered': skillsCovered,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  List<SkillTestQuestion> questionsForSkill(String skillName) {
    return questions.where((q) => q.skillName == skillName).toList();
  }

  @override
  List<Object?> get props => [questions, skillsCovered, generatedAt];
}

class SkillValidationResult extends Equatable {
  final bool isValid;

  final String reason;

  final String skillName;

  const SkillValidationResult({
    required this.isValid,
    required this.reason,
    required this.skillName,
  });

  @override
  List<Object?> get props => [isValid, reason, skillName];
}

class SkillTestResult extends Equatable {
  final Map<String, String> skillLevels;

  final Map<String, bool> passedSkills;

  final String feedback;

  const SkillTestResult({
    required this.skillLevels,
    required this.passedSkills,
    required this.feedback,
  });

  factory SkillTestResult.fromJson(Map<String, dynamic> json) {
    final skillLevels = Map<String, String>.from(
      json['skillLevels'] as Map? ?? {},
    );
    final rawPassedSkills = Map<String, bool>.from(
      json['passedSkills'] as Map? ?? {},
    );

    final passedSkills = <String, bool>{};

    for (final entry in rawPassedSkills.entries) {
      passedSkills[entry.key] = entry.value;
    }

    for (final entry in skillLevels.entries) {
      final hasValidLevel =
          entry.value.isNotEmpty &&
          [
            'beginner',
            'intermediate',
            'advanced',
            'expert',
          ].contains(entry.value.toLowerCase());

      if (!passedSkills.containsKey(entry.key) && hasValidLevel) {
        passedSkills[entry.key] = true;
      }
    }

    return SkillTestResult(
      skillLevels: skillLevels,
      passedSkills: passedSkills,
      feedback: json['feedback'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [skillLevels, passedSkills, feedback];
}
