import '../../domain/entities/survey_question_entity.dart';

class SurveyQuestionModel extends SurveyQuestionEntity {
  const SurveyQuestionModel({
    required super.id,
    required super.type,
    required super.question,
    super.options,
    super.required,
    super.allowOther,
  });

  factory SurveyQuestionModel.fromMap(Map<String, dynamic> map) {
    return SurveyQuestionModel(
      id: map['id'] as String? ?? '',
      type: _parseQuestionType(map['type'] as String?),
      question: map['question'] as String? ?? '',
      options:
          (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      required: map['required'] as bool? ?? true,
      allowOther: map['allowOther'] as bool? ?? false,
    );
  }

  factory SurveyQuestionModel.fromEntity(SurveyQuestionEntity entity) {
    return SurveyQuestionModel(
      id: entity.id,
      type: entity.type,
      question: entity.question,
      options: entity.options,
      required: entity.required,
      allowOther: entity.allowOther,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'question': question,
      'options': options,
      'required': required,
      'allowOther': allowOther,
    };
  }

  static SurveyQuestionType _parseQuestionType(String? type) {
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
